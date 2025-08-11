import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:psmp_new/pages/covoiturage_page.dart';
import 'package:psmp_new/pages/driver_form_page.dart';
import 'package:psmp_new/pages/login_page.dart';
import 'package:psmp_new/pages/ride_page.dart';
import 'package:psmp_new/pages/service_selection_page.dart';
import 'package:psmp_new/pages/transporteur_page.dart';
import '../models/sessionManager.dart';
import '../models/user.dart';
import '../utils/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Base API URL - replace with your actual base URL

  // Function to get reservations by driver ID
  Future<List<Map<String, dynamic>>> _getReservationsByDriverId(
      String driverId) async {
    try {
      final response = await http.get(
        Uri.parse(
            dotenv.env['API_URL']! + '/api/reservations/driver/$driverId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load reservations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reservations: $e');
      throw Exception('Failed to load reservations: $e');
    }
  }

  // Function to get user by ID
  Future<Map<String, dynamic>> _getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(dotenv.env['API_URL']! + '/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user $userId: $e');
      // Return fallback user data
      return {
        'id': userId,
        'fullName': 'Unknown User',
        'email': 'Not available',
        'phoneNumber': 'Not available',
        'role': 'unknown',
        'photoURL': '',
      };
    }
  }

  // Function to merge reservations with user data
  Future<List<Map<String, dynamic>>> _loadMergedReservations() async {
    try {
      final User? currentUser = SessionManager().getUser();
      if (currentUser == null || currentUser.id == null) {
        throw Exception('No user logged in');
      }

      // Step 1: Get reservations for the current driver
      final reservations = await _getReservationsByDriverId(currentUser.id!);

      // Step 2: Get unique client and driver IDs
      final Set<String> userIds = {};
      for (final reservation in reservations) {
        if (reservation['clientId'] != null) {
          userIds.add(reservation['clientId']);
        }
        if (reservation['driverId'] != null) {
          userIds.add(reservation['driverId']);
        }
      }

      // Step 3: Fetch user data for all unique IDs
      final Map<String, Map<String, dynamic>> usersMap = {};
      for (final userId in userIds) {
        final userData = await _getUserById(userId);
        usersMap[userId] = userData;
      }

      // Step 4: Merge reservations with user data
      final List<Map<String, dynamic>> mergedReservations = [];
      for (final reservation in reservations) {
        final clientData = usersMap[reservation['clientId']];
        final driverData = usersMap[reservation['driverId']];

        mergedReservations.add({
          ...reservation,
          'client': clientData,
          'driver': driverData,
        });
      }

      return mergedReservations;
    } catch (e) {
      print('Error loading merged reservations: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = SessionManager().getUser();
    final bool isUserRole = user?.role?.toLowerCase() != 'user';

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Header with settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hello,',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMedium,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        user?.fullName ?? 'Guest',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      logout(context);
                      // Navigate to settings
                      print('Settings tapped');
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: AppColors.textDark,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // Conditional content based on user role
              if (!isUserRole) ...[
                // Services title (only shown for non-user roles)
                const Text(
                  'Choose your',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMedium,
                    height: 1.2,
                  ),
                ),
                const Text(
                  'Service',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 50),

                // Service cards (only shown for non-user roles)
                Expanded(
                  child: Column(
                    children: [
                      // Ride card
                      Expanded(
                        child: _ServiceCard(
                          title: 'Ride',
                          subtitle: 'Book your ride',
                          onTap: () {
                            print('Ride tapped');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RidePage()),
                            );
                          },
                          imageAssetPath: 'assets/images/ride.jpg',
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Covoiturage and Transporteur cards
                      Expanded(
                        child: Row(
                          children: [
                            // Covoiturage card
                            Expanded(
                              child: _ServiceCard(
                                title: 'Covoiturage',
                                subtitle: 'Share rides',
                                onTap: () {
                                  print('Covoiturage tapped');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CovoituragePage()),
                                  );
                                },
                                imageAssetPath: 'assets/images/carpool.jpg',
                              ),
                            ),

                            const SizedBox(width: 24),

                            // Transporteur card
                            Expanded(
                              child: _ServiceCard(
                                title: 'Transporteur',
                                subtitle: 'Become driver',
                                onTap: () {
                                  print('Transporteur tapped');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const TransporteurPage()),
                                  );
                                },
                                imageAssetPath: 'assets/images/cargo.jpg',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ServiceSelectionPage()),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Text(
                            '    JOIN US ',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Reservations view for user role
                const Text(
                  'Your',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMedium,
                    height: 1.2,
                  ),
                ),
                const Text(
                  'Reservations',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 30),

                // Reservations ListView
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _loadMergedReservations(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading your reservations...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red.withOpacity(0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading reservations',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMedium,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                snapshot.error.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      final mergedReservations = snapshot.data ?? [];

                      if (mergedReservations.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_note,
                                size: 48,
                                color: AppColors.textMedium.withOpacity(0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No reservations found',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMedium,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your reservations will appear here',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textMedium.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async {
                          // Trigger rebuild to refresh data
                          (context as Element).markNeedsBuild();
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: mergedReservations.length,
                          itemBuilder: (context, index) {
                            final reservation = mergedReservations[index];
                            return _ReservationCard(reservation: reservation);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    // 🔁 Clear saved user from persistent storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInUser');

    // 🔁 Clear in-memory session
    SessionManager().clearUser();

    // 🔁 Navigate to login page (clears navigation stack)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Map<String, dynamic> reservation;

  const _ReservationCard({required this.reservation});

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return AppColors.textMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final driver = reservation['driver'] as Map<String, dynamic>?;
    final client = reservation['client'] as Map<String, dynamic>?;
    final status = reservation['status'] as String? ?? 'UNKNOWN';
    final statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: () {
        try {
          // Extract coordinates from your string format "{lat: ..., lon: ...}"
          final pickupStr = reservation['pickupLocation']
              .toString()
              .replaceAll(RegExp(r'[^0-9\.\,\-]'), '');
          final dropoffStr = reservation['dropoffLocation']
              .toString()
              .replaceAll(RegExp(r'[^0-9\.\,\-]'), '');

          final pickupParts = pickupStr.split(',');
          final dropoffParts = dropoffStr.split(',');

          final pickup = LatLng(
            double.parse(pickupParts[0]),
            double.parse(pickupParts[1]),
          );
          final dropoff = LatLng(
            double.parse(dropoffParts[0]),
            double.parse(dropoffParts[1]),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RouteMapPage(
                pickup: pickup,
                dropoff: dropoff,
              ),
            ),
          );
        } catch (e) {
          print("Error parsing locations: $e");
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reservation',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Reservation details with better formatting
              Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.attach_money,
                      label: 'Price',
                      value:
                          '${reservation['estimatedPrice']?.toStringAsFixed(1) ?? '0.0'} DT',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.route,
                      label: 'Distance',
                      value:
                          '${reservation['distanceKm']?.toStringAsFixed(1) ?? '0.0'} km',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              // Add pickup and dropoff locations if available
              if (reservation['pickupLocation'] != null ||
                  reservation['dropoffLocation'] != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (reservation['pickupLocation'] != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.my_location,
                              color: Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Pickup: ${reservation['pickupLocation']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (reservation['dropoffLocation'] != null)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Dropoff: ${reservation['dropoffLocation']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // // Driver section
              // if (driver != null) ...[
              //   Row(
              //     children: [
              //       Icon(
              //         Icons.drive_eta,
              //         color: AppColors.primary,
              //         size: 20,
              //       ),
              //       const SizedBox(width: 8),
              //       const Text(
              //         'Driver',
              //         style: TextStyle(
              //           fontSize: 16,
              //           fontWeight: FontWeight.w700,
              //           color: AppColors.textDark,
              //           letterSpacing: -0.3,
              //         ),
              //       ),
              //     ],
              //   ),
              //   const SizedBox(height: 12),
              //   _UserInfo(userData: driver),
              //   const SizedBox(height: 20),
              // ],

              // Client section
              if (client != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Client',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _UserInfo(userData: client),
                const SizedBox(height: 20),
              ],

              // Created date and pickup time
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppColors.textMedium,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Created: ${reservation['createdAt']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                    if (reservation['pickupTime'] != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pickup: ${reservation['pickupTime']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  final Map<String, dynamic> userData;

  const _UserInfo({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.lightGray,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: userData['photoURL'] != null
                  ? Image.network(
                      userData['photoURL'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: AppColors.textMedium,
                          size: 24,
                        );
                      },
                    )
                  : const Icon(
                      Icons.person,
                      color: AppColors.textMedium,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // User details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['fullName'] ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userData['email'] ?? 'No email',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userData['phoneNumber'] ?? 'No phone',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Map<String, dynamic> data;
  final IconData icon;
  final Color color;

  const _DataCard({
    required this.title,
    required this.subtitle,
    required this.data,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.3,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textMedium,
            height: 1.3,
          ),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightGray.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.entries
                  .map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(
                                '${entry.key}:',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMedium,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value.toString(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textDark,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageAssetPath;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.imageAssetPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset(
                  imageAssetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.lightGray,
                      child: const Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: AppColors.textLight,
                      ),
                    );
                  },
                ),
              ),

              // Overlay with low opacity
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.textDark.withOpacity(0.3),
                  ),
                ),
              ),

              // Content
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tap indicator
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/pages/route_map_page.dart

class RouteMapPage extends StatefulWidget {
  final LatLng pickup;
  final LatLng dropoff;

  const RouteMapPage({super.key, required this.pickup, required this.dropoff});

  @override
  State<RouteMapPage> createState() => _RouteMapPageState();
}

class _RouteMapPageState extends State<RouteMapPage> {
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    try {
      final apiKey = "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImNmZWQyMmJjZWRlODRlZjFhYTUzZjg3OTkyYWU3NWRlIiwiaCI6Im11cm11cjY0In0="; // Replace with your key
      final url = Uri.parse(
        "https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${widget.pickup.longitude},${widget.pickup.latitude}&end=${widget.dropoff.longitude},${widget.dropoff.latitude}",
      );

      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final coords = data['features'][0]['geometry']['coordinates'];
        setState(() {
          _routePoints = coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
        });
      } else {
        throw Exception("Failed to fetch route: ${res.statusCode}");
      }
    } catch (e) {
      print("Error fetching route: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Route Map")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: widget.pickup,
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "com.example.app",
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: widget.pickup,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on,
                    color: Colors.green, size: 40),
              ),
              Marker(
                point: widget.dropoff,
                width: 40,
                height: 40,
                child: const Icon(Icons.flag, color: Colors.red, size: 40),
              ),
            ],
          ),
          if (_routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _routePoints,
                  strokeWidth: 4,
                  color: Colors.blue,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
