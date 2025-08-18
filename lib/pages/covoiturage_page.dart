import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_colors.dart';
import '../models/user.dart';
import '../models/sessionManager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class CarpoolPage extends StatefulWidget {
  const CarpoolPage({super.key});

  @override
  State<CarpoolPage> createState() => _CarpoolPageState();
}

class _CarpoolPageState extends State<CarpoolPage> {
  // Data lists and filter fields
  List<User> carpoolDrivers = [];
  List<User> filteredCarpoolDrivers = [];

  // Filter controllers
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  
  String selectedCity = 'All';
  int? selectedSeats;
  String? selectedWorkingHours;
  DateTime? selectedDate;
  bool isLoading = true;
  String? errorMessage;

  // Tunisian cities list
  final List<String> tunisianCities = [
    'Tunis', 'Sfax', 'Sousse', 'Kairouan', 'Bizerte', 'Gabès', 'Ariana',
    'Gafsa', 'Monastir', 'Ben Arous', 'Kasserine', 'Médenine', 'Nabeul',
    'Tataouine', 'Béja', 'Jendouba', 'Mahdia', 'Siliana', 'Manouba',
    'Zaghouan', 'Tozeur', 'Kébili', 'Le Kef', 'Sidi Bouzid', 'Hammamet',
    'La Marsa', 'Carthage', 'Skhira', 'Djerba', 'Zarzis'
  ];

  @override
  void initState() {
    super.initState();
    _fetchCarpoolDrivers();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  /// Fetch carpool drivers from API and keep only users with role == "carpool_driver".
  Future<void> _fetchCarpoolDrivers() async {
  try {
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']!}/api/users'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        carpoolDrivers = jsonData
            .map((json) => User.fromJson(json))
            .where((u) => u.role == "carpool_driver" && u.carpoolDetails != null)
            .toList();
        filteredCarpoolDrivers = List.from(carpoolDrivers);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load carpool drivers');
    }
  } catch (e) {
    setState(() {
      isLoading = false;
      errorMessage = 'Error: $e';
    });
  }
}

  /// Reset all filters
  void _resetFilters() {
    setState(() {
      _fromController.clear();
      _toController.clear();
      selectedCity = 'All';
      selectedSeats = null;
      selectedWorkingHours = null;
      selectedDate = null;
      filteredCarpoolDrivers = List.from(carpoolDrivers);
    });
  }

  /// Apply filters
  void _applyFilters() {
    setState(() {
      filteredCarpoolDrivers = carpoolDrivers.where((driver) {
        final details = driver.carpoolDetails;
        if (details == null) return false;

        // From location filter
        final matchesFrom = _fromController.text.isEmpty ||
            details.fromLocation.toLowerCase().contains(_fromController.text.toLowerCase());

        // To location filter
        final matchesTo = _toController.text.isEmpty ||
            details.toLocation.toLowerCase().contains(_toController.text.toLowerCase());

        // Available seats filter
        final matchesSeats = selectedSeats == null ||
            details.availableSeats >= selectedSeats!;

        // Date filter
        bool matchesDate = true;
        if (selectedDate != null) {
          final tripDate = details.departureDate;
          if (tripDate != null) {
            matchesDate = DateFormat('yyyy-MM-dd').format(tripDate as DateTime) ==
                DateFormat('yyyy-MM-dd').format(selectedDate!);
          }
        }

        return matchesFrom && matchesTo && matchesSeats && matchesDate;
      }).toList();
    });
  }

  /// Show location selection bottom sheet
  void _showLocationBottomSheet(TextEditingController controller, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select $title',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: tunisianCities.length,
                itemBuilder: (context, index) {
                  final city = tunisianCities[index];
                  return GestureDetector(
                    onTap: () {
                      controller.text = city;
                      Navigator.pop(context);
                      _applyFilters();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: controller.text == city
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        city,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: controller.text == city
                              ? AppColors.primary
                              : AppColors.textDark,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show date picker
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER + filters
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 0, 23, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button row
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

                  // Title
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
                    'Carpools',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // From location selector
                  GestureDetector(
                    onTap: () => _showLocationBottomSheet(_fromController, 'From Location'),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _fromController.text.isEmpty ? 'From Location' : _fromController.text,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _fromController.text.isEmpty 
                                    ? AppColors.textMedium 
                                    : AppColors.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.keyboard_arrow_down, color: AppColors.textMedium),
                        ],
                      ),
                    ),
                  ),

                  // To location selector
                  GestureDetector(
                    onTap: () => _showLocationBottomSheet(_toController, 'To Location'),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _toController.text.isEmpty ? 'To Location' : _toController.text,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _toController.text.isEmpty 
                                    ? AppColors.textMedium 
                                    : AppColors.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.keyboard_arrow_down, color: AppColors.textMedium),
                        ],
                      ),
                    ),
                  ),

                  // Carpool count text
                  Text(
                    '${filteredCarpoolDrivers.length} carpools found',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // CARPOOL LIST
            Expanded(
              child: _buildCarpoolList(),
            ),
          ],
        ),
      ),
      // Floating reset button
      floatingActionButton: FloatingActionButton(
        onPressed: _resetFilters,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildCarpoolList() {
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

    if (filteredCarpoolDrivers.isEmpty) {
      return const Center(
        child: Text('No carpools found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      itemCount: filteredCarpoolDrivers.length,
      itemBuilder: (context, index) {
        final carpoolDriver = filteredCarpoolDrivers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _CarpoolCard(
            driver: carpoolDriver,
            onBookingComplete: _fetchCarpoolDrivers, // Refresh list after booking
          ),
        );
      },
    );
  }
}

/// Carpool card widget
class _CarpoolCard extends StatelessWidget {
  final User driver;
  final VoidCallback onBookingComplete;

  const _CarpoolCard({
    required this.driver,
    required this.onBookingComplete,
  });

  @override
  Widget build(BuildContext context) {
    final carpoolDetails = driver.carpoolDetails!;
    
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
                      '${carpoolDetails.fromLocation} → ${carpoolDetails.toLocation}',
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

          // Trip info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        carpoolDetails.departureDate!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const Icon(Icons.access_time, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      carpoolDetails.departureTime,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.people_outline, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${carpoolDetails.availableSeats} seats available',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Text(
                      '${carpoolDetails.pricePerSeat.toStringAsFixed(0)} TND/seat',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

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
                        '${carpoolDetails.vehicleMake} ${carpoolDetails.vehicleModel} (${carpoolDetails.vehicleYear})',
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
                      Icons.palette_outlined,
                      color: AppColors.textMedium,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      carpoolDetails.vehicleColor,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMedium,
                      ),
                    ),
                    const Spacer(),
                    if (carpoolDetails.smokingAllowed)
                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Row(
                          children: [
                            Icon(Icons.smoking_rooms, color: AppColors.textMedium, size: 16),
                            SizedBox(width: 4),
                            Text('Smoking', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
                          ],
                        ),
                      ),
                    if (carpoolDetails.petsAllowed)
                      const Row(
                        children: [
                          Icon(Icons.pets, color: AppColors.textMedium, size: 16),
                          SizedBox(width: 4),
                          Text('Pets OK', style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Additional info if available
          if (carpoolDetails.additionalInfo.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightGray.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Additional Info',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    carpoolDetails.additionalInfo,
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

          const SizedBox(height: 20),

          // Book button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: carpoolDetails.availableSeats > 0 ? () async {
                await _handleBooking(context, driver, onBookingComplete);
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: carpoolDetails.availableSeats > 0 
                    ? AppColors.primary 
                    : Colors.grey,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                carpoolDetails.availableSeats > 0 
                    ? 'Book Seat - ${carpoolDetails.pricePerSeat.toStringAsFixed(0)} TND/seat'
                    : 'No Seats Available',
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

  /// Handle the booking process with confirmation dialog
  static Future<void> _handleBooking(
    BuildContext context, 
    User driver,
    VoidCallback onBookingComplete,
  ) async {
    final carpoolDetails = driver.carpoolDetails!;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.directions_car, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              "Confirm Booking",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reserve a seat with ${driver.fullName}?",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.route, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${carpoolDetails.fromLocation} → ${carpoolDetails.toLocation}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${carpoolDetails.departureDate} at ${carpoolDetails.departureTime}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.payments, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${carpoolDetails.pricePerSeat.toStringAsFixed(0)} TND per seat',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Note: You will reserve 1 seat in this carpool.",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMedium,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: AppColors.textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Confirm Booking",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Processing your reservation..."),
          ],
        ),
      ),
    );

    try {
      final currentUser = SessionManager().getUser();
      if (currentUser == null) {
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackBar(context, "Please log in to make a reservation");
        return;
      }

      // Create the reservation request payload
      final payload = {
        "carpoolDriverId": driver.id,
        "passengerId": currentUser.id,
      };

      final response = await http.post(
        Uri.parse("${dotenv.env['API_URL']!}/api/users/carpool-reservation"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200) {
        _showSuccessSnackBar(context, "Carpool seat reserved successfully!");
        onBookingComplete(); // Refresh the list
      } else {
        final errorMessage = response.body.contains("Error: ") 
            ? response.body
            : "Failed to reserve seat. Please try again.";
        _showErrorSnackBar(context, errorMessage);
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar(context, "Network error: Please check your connection and try again.");
    }
  }

  /// Show success snack bar
  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show error snack bar
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}