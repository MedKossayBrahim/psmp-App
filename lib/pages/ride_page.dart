import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_colors.dart';
import '../models/user.dart';
import '../models/sessionManager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Map + location packages
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';

class RidePage extends StatefulWidget {
  const RidePage({super.key});

  @override
  State<RidePage> createState() => _RidePageState();
}

class _RidePageState extends State<RidePage> {
  // --- Original data lists and filter fields (kept) ---
  List<User> drivers = [];
  List<User> filteredDrivers = [];

  final Map<String, double> _distanceCache = {}; // city ➜ km

  String selectedCity = 'All';
  int? selectedSeats;
  // NOTE: we keep the UI for selectedServiceAreas if you want, but per request
  // the new pickup->serviceArea automatic filtering will be used. Manual service-area-based
  // filtering is not applied in the new logic (only pickup-derived matching).
  List<String> selectedServiceAreas = [];
  String? selectedWorkingHours;
  bool isLoading = true;
  String? errorMessage;

  // --- New: pickup & drop-off location states ---
  LatLng? pickupLocation;
  LatLng? dropoffLocation;

  // Human-readable addresses shown in the UI (keeps page style)
  String pickupAddress = 'Select Pickup Location';
  String dropoffAddress = 'Select Drop-off Location';

  // City derived from pickupLocation via reverse geocoding.
  // We'll use this to filter drivers by their serviceAreas (string match).
  String? pickupCity;

  // Distance and pricing
  double? routeDistance; // in kilometers
  double?
      estimatedPrice; // header estimate based on min pricePerKm among drivers
  bool isCalculatingDistance = false;

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  /// Fetch drivers from API and keep only users with role == "driver".
  Future<void> _fetchDrivers() async {
    try {
      final response = await http.get(
        Uri.parse(dotenv.env['API_URL']! + '/api/users'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          drivers = jsonData
              .map((json) => User.fromJson(json))
              .where((u) => u.role == "driver")
              .toList();
          filteredDrivers = List.from(drivers);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load drivers');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  /// Calculate road distance between two points using OSRM routing service
  Future<double?> _calculateRoadDistance(LatLng from, LatLng to) async {
    try {
      final url = 'http://router.project-osrm.org/route/v1/driving/'
          '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
          '?overview=false&geometries=geojson';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          // Distance is returned in meters, convert to kilometers
          final distanceInMeters = data['routes'][0]['distance'];
          return distanceInMeters / 1000.0;
        }
      }
    } catch (e) {
      print('Error calculating distance: $e');
    }
    return null;
  }

  /// Calculate and update route distance and price
  Future<void> _updateRouteInfo() async {
    if (pickupLocation == null || dropoffLocation == null) {
      setState(() {
        routeDistance = null;
        estimatedPrice = null;
      });
      return;
    }

    setState(() {
      isCalculatingDistance = true;
    });

    final distance =
        await _calculateRoadDistance(pickupLocation!, dropoffLocation!);

    // Compute header estimated price using the minimum pricePerKm among filtered drivers
    double? headerEstimate;
    if (distance != null) {
      final sourceList = filteredDrivers.isNotEmpty ? filteredDrivers : drivers;
      double minPricePerKm = double.infinity;
      for (final d in sourceList) {
        final p = d.driverDetails?.pricePerKm;
        if (p != null && p < minPricePerKm) {
          minPricePerKm = p;
        }
      }
      if (minPricePerKm != double.infinity) {
        headerEstimate = distance * minPricePerKm;
      }
    }

    setState(() {
      routeDistance = distance;
      estimatedPrice = headerEstimate;
      isCalculatingDistance = false;
    });
  }

  /// Reset filters and pickup/drop-off selections.
  void _resetFilters() {
    setState(() {
      selectedCity = 'All';
      selectedSeats = null;
      selectedServiceAreas = [];
      selectedWorkingHours = null;

      // Clear pickup/drop state
      pickupLocation = null;
      dropoffLocation = null;
      pickupAddress = 'Select Pickup Location';
      dropoffAddress = 'Select Drop-off Location';
      pickupCity = null;

      // Clear route info
      routeDistance = null;
      estimatedPrice = null;

      // Restore full driver list
      filteredDrivers = List.from(drivers);
    });
  }

  /// Apply filters. Important: we include pickupCity-based filtering here.
  /// We intentionally DO NOT apply manual service-area filtering (selectedServiceAreas),
  /// because the requested behavior is automatic pickup-based matching.
  void _applyFilters() {
    setState(() {
      filteredDrivers = drivers.where((driver) {
        final details = driver.driverDetails;
        if (details == null) return false;

        // City filter (top-level city selector) - unchanged
        final matchesCity =
            selectedCity == "All" || details.city == selectedCity;

        // Seats filter - unchanged
        final matchesSeats =
            selectedSeats == null || details.numberOfSeats == selectedSeats;

        // Working hours - unchanged
        final matchesWorkingHours = selectedWorkingHours == null ||
            details.preferredWorkingHours == selectedWorkingHours;

        // NEW: Pickup-derived service area filter:
        // If user selected a pickup and we were able to extract pickupCity,
        // only return drivers whose serviceAreas contains that pickupCity.
        bool matchesPickupServiceArea = true;
        if (pickupCity != null && pickupCity!.isNotEmpty) {
          // serviceAreas in driver data is assumed comma-separated string of exact city names.
          final driverAreas = details.serviceAreas
              .split(',')
              .map((s) => s.trim().toLowerCase())
              .toList();

          matchesPickupServiceArea =
              driverAreas.contains(pickupCity!.toLowerCase());
        }

        return matchesCity &&
            matchesSeats &&
            matchesWorkingHours &&
            matchesPickupServiceArea;
      }).toList();

      // Recompute header estimated price if we have a distance
      if (routeDistance != null) {
        double minPricePerKm = double.infinity;
        for (final d
            in filteredDrivers.isNotEmpty ? filteredDrivers : drivers) {
          final p = d.driverDetails?.pricePerKm;
          if (p != null && p < minPricePerKm) {
            minPricePerKm = p;
          }
        }
        estimatedPrice = minPricePerKm != double.infinity
            ? routeDistance! * minPricePerKm
            : null;
      }
    });
  }

  /// Launch MapPickerPage to get coordinates for pickup or dropoff.
  /// After picking, use geocoding to obtain an approximate city/locality and update state.
  Future<void> _selectLocation(bool isPickup) async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerPage(
            initialLocation: isPickup ? pickupLocation : dropoffLocation),
      ),
    );

    if (result == null) return; // user cancelled

    // Reverse geocode to get a nearby placemark (locality/city)
    String address =
        '${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)}';
    String? cityFromPlacemark;

    try {
      final placemarks =
          await placemarkFromCoordinates(result.latitude, result.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        // Prefer locality (city), fall back to administrativeArea or country
        cityFromPlacemark = p.locality ??
            p.subAdministrativeArea ??
            p.administrativeArea ??
            p.country;
        // Build a nice address for display (locality + country if available)
        final locality = p.locality ?? '';
        final country = p.country ?? '';
        if (locality.isNotEmpty && country.isNotEmpty) {
          address = '$locality, $country';
        } else if (locality.isNotEmpty) {
          address = locality;
        } else if (p.name != null && p.name!.isNotEmpty) {
          address = p.name!;
        }
      }
    } catch (e) {
      // Geocoding can fail; fallback to lat/lng display already assigned above.
      // We purposely do not crash on reverse-geocode failure.
    }

    setState(() {
      if (isPickup) {
        pickupLocation = result;
        pickupAddress = address;
        pickupCity = cityFromPlacemark; // may be null if geocoding failed
      } else {
        dropoffLocation = result;
        dropoffAddress = address;
      }
      // Re-apply filters so drivers matching pickupCity are shown.
      _applyFilters();
    });

    // Calculate route distance and price when both locations are set
    _updateRouteInfo();
  }

  // -------------------------- UI --------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER + location pickers (keeps same padding/style as original)
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 0, 23, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: back button + filter button (unchanged)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.textDark,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),

                  // Title remains unchanged
                  const Text(
                    'Available',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ),
                  const Text(
                    'Drivers',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // New: Pickup & Drop cards inserted here, same look as page
                  GestureDetector(
                    onTap: () => _selectLocation(true),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location,
                              color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              pickupAddress,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.keyboard_arrow_down,
                              color: AppColors.textMedium),
                        ],
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () => _selectLocation(false),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              dropoffAddress,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.keyboard_arrow_down,
                              color: AppColors.textMedium),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Route info card (distance and price)
                  if (pickupLocation != null && dropoffLocation != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.route, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: isCalculatingDistance
                                ? const Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Calculating distance...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textMedium,
                                        ),
                                      ),
                                    ],
                                  )
                                : routeDistance != null
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Distance: ${routeDistance!.toStringAsFixed(1)} km',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          Text(
                                            'Estimated cost: ${estimatedPrice!.toStringAsFixed(2)} TND',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textMedium,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        'Unable to calculate distance',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textMedium,
                                        ),
                                      ),
                          ),
                        ],
                      ),
                    ),

                  // Driver count text (keeps original logic but now reflects filteredDrivers)
                  Text(
                    '${filteredDrivers.length} drivers found${pickupCity != null ? " near $pickupCity" : selectedCity != "All" ? " in $selectedCity" : ""}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // DRIVER LIST (kept intact)
            Expanded(
              child: _buildDriverList(),
            ),
          ],
        ),
      ),
      // Floating reset button to clear selections quickly (optional but useful)
      floatingActionButton: FloatingActionButton(
        onPressed: _resetFilters,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildDriverList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (filteredDrivers.isEmpty) {
      return const Center(
        child: Text('No drivers found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      itemCount: filteredDrivers.length,
      itemBuilder: (context, index) {
        final driver = filteredDrivers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _DriverCard(
            driver: driver,
            routeDistance: routeDistance,
            pickupLocation: pickupLocation,
            dropoffLocation: dropoffLocation,
          ),
        );
      },
    );
  }
}

/// --- Updated Driver card with distance and pricing info. ---
class _DriverCard extends StatelessWidget {
  final User driver;
  final double? routeDistance;
  final LatLng? pickupLocation;
  final LatLng? dropoffLocation;

  const _DriverCard({
    required this.driver,
    this.routeDistance,
    this.pickupLocation,
    this.dropoffLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Driver info
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.lightGray,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    driver.photoURL,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary,
                        child: Center(
                          child: Text(
                            driver.fullName
                                .split(' ')
                                .map((e) => e[0])
                                .join(''),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      driver.driverDetails!.city,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Distance and Price Info (NEW)
          if (routeDistance != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.route, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip Distance: ${routeDistance!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Builder(builder: (context) {
                          final perKm = driver.driverDetails?.pricePerKm ?? 1.2;
                          final price = routeDistance! * perKm;
                          return Text(
                            'Estimated Cost: ${price.toStringAsFixed(2)} TND',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Vehicle info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.directions_car,
                      color: AppColors.textMedium,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${driver.driverDetails?.vehicleMake} ${driver.driverDetails?.vehicleModel} (${driver.driverDetails?.vehicleYear})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      color: AppColors.textMedium,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      driver.driverDetails!.licensePlate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.people_outline,
                      color: AppColors.textMedium,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${driver.driverDetails?.numberOfSeats} seats',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Service areas + working hours (kept display-only)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service Areas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      driver.driverDetails!.serviceAreas,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Working Hours',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      driver.driverDetails!.preferredWorkingHours,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Book button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                // Confirm first
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Confirm Booking"),
                    content: Text(
                      "Do you want to book ${driver.fullName} for this trip?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text("Confirm"),
                      ),
                    ],
                  ),
                );

                if (confirmed != true) return;

                // Build payload
                final currentUser = SessionManager().getUser();
                final payload = {
                  "driverId": driver.id,
                  if (currentUser != null) "clientId": currentUser.id,
                  if (pickupLocation != null)
                    "pickupLocation": {
                      "lat": pickupLocation!.latitude,
                      "lon": pickupLocation!.longitude,
                    }.toString(),
                  if (dropoffLocation != null)
                    "dropoffLocation": {
                      "lat": dropoffLocation!.latitude,
                      "lon": dropoffLocation!.longitude,
                    }.toString(),
                  if (routeDistance != null)
                    "distanceKm":
                        double.parse(routeDistance!.toStringAsFixed(2)),
                  // Use driver-specific price if available
                  if (routeDistance != null)
                    "estimatedPrice": double.parse(
                      (routeDistance! *
                              (driver.driverDetails?.pricePerKm ?? 1.2))
                          .toStringAsFixed(2),
                    ),
                };

                try {
                  final response = await http.post(
                    Uri.parse("${dotenv.env['API_URL']!}/api/reservations"),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode(payload),
                  );

                  if (response.statusCode == 201 ||
                      response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Booking confirmed successfully!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to book: ${response.body}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                routeDistance != null
                    ? 'Book Now - ${(routeDistance! * (driver.driverDetails?.pricePerKm ?? 1.2)).toStringAsFixed(2)} TND'
                    : 'Book Now',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Map picker screen that displays an OpenStreetMap and allows tapping to select a spot.
/// Returns LatLng on confirm.
class MapPickerPage extends StatefulWidget {
  final LatLng? initialLocation;
  const MapPickerPage({super.key, this.initialLocation});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  // Default to Tunis coordinates if not provided
  LatLng selectedPoint = LatLng(36.8065, 10.1815);

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      selectedPoint = widget.initialLocation!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
        backgroundColor: AppColors.primary,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: selectedPoint,
          initialZoom: 13.0,
          onTap: (tapPos, point) {
            // User tapped map — update selection marker
            setState(() {
              selectedPoint = point;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: selectedPoint,
                width: 40,
                height: 40,
                child:
                    const Icon(Icons.location_on, size: 40, color: Colors.red),
              )
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context, selectedPoint),
        label: const Text("Confirm"),
        icon: const Icon(Icons.check),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
