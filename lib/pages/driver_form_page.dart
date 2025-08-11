import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/sessionManager.dart';
import '../models/user.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DriverFormPage extends StatefulWidget {
  const DriverFormPage({super.key});

  @override
  State<DriverFormPage> createState() => _DriverFormPageState();
}

class _DriverFormPageState extends State<DriverFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _licenseNumberController = TextEditingController();
  final _licenseExpiryDateController = TextEditingController();
  final _vehicleMakeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _numberOfSeatsController = TextEditingController();
  final _preferredWorkingHoursController = TextEditingController();

  List<String> selectedServiceAreas = [];
  final List<String> availableServiceAreas = [
    'Tunis',
    'Ariana',
    'Manouba',
    'Ben Arous',
    'Sfax',
    'Sousse',
    'Monastir',
    'Mahdia',
    'Kairouan',
    'Bizerte',
    'Nabeul',
    'Zaghouan'
  ];

  bool _isLoading = false;

  @override
  void dispose() {
    _licenseNumberController.dispose();
    _licenseExpiryDateController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _licensePlateController.dispose();
    _numberOfSeatsController.dispose();
    _preferredWorkingHoursController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _licenseExpiryDateController.text = picked.toIso8601String().split('T')[0]; // Format as YYYY-MM-DD
      });
    }
  }

  void _showServiceAreasBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Service Areas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose multiple areas where you provide service',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Selected Areas
                  if (selectedServiceAreas.isNotEmpty) ...[
                    const Text(
                      'Selected Areas:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: selectedServiceAreas.map((area) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                area,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  modalSetState(() {
                                    selectedServiceAreas.remove(area);
                                  });
                                  setState(() {}); // To reflect outside changes
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const Text(
                    'Available Areas:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableServiceAreas
                            .where((area) => !selectedServiceAreas.contains(area))
                            .map(
                              (area) => GestureDetector(
                                onTap: () {
                                  modalSetState(() {
                                    if (!selectedServiceAreas.contains(area)) {
                                      selectedServiceAreas.add(area);
                                    }
                                  });
                                  setState(() {}); // Sync with main UI
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGray,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.mediumGray,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    area,
                                    style: const TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Done Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && selectedServiceAreas.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get current user
        final User? user = SessionManager().getUser();
        if (user == null) {
          throw Exception('User not found. Please login again.');
        }

        // Prepare user data with driver details as nested object
        Map<String, dynamic> userData = user.toJson();
        
        // Create driver details object matching your DriverDetails model
        userData['driverDetails'] = {
          'licenseNumber': _licenseNumberController.text.trim(),
          'licenseExpiryDate': _licenseExpiryDateController.text.trim(), // Will be converted to LocalDate by Spring
          'vehicleMake': _vehicleMakeController.text.trim(),
          'vehicleModel': _vehicleModelController.text.trim(),
          'vehicleYear': int.parse(_vehicleYearController.text.trim()),
          'licensePlate': _licensePlateController.text.trim(),
          'numberOfSeats': int.parse(_numberOfSeatsController.text.trim()),
          'serviceAreas': jsonEncode(selectedServiceAreas), // Store as JSON string
          'preferredWorkingHours': _preferredWorkingHoursController.text.trim(),
          'city': null, // You might want to add a city field to your form or set a default
        };
        
        // Also set the user role to driver if not already set
        userData['role'] = 'driver'; // Assuming Role enum has DRIVER value

        // Make API call
        final response = await http.put(
          Uri.parse('${dotenv.env['API_URL']!}/api/users/update'), // Replace with your actual base URL
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Accept': 'application/json',
          },
          body: jsonEncode(userData),
        );

        if (response.statusCode == 200) {
          // Success - update session if needed
          final updatedUserData = jsonDecode(response.body);
          // You might want to update the session with new user data
          // SessionManager().updateUser(User.fromJson(updatedUserData));

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Driver details saved successfully!'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          // Handle error response
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to save driver details');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (selectedServiceAreas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service area'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
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
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Title
                  const Text(
                    'Driver',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ),
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Complete your driver profile information',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // License Number
                      CustomTextField(
                        hintText: 'License Number (e.g., TN123456789)',
                        prefixIcon: Icons.credit_card_outlined,
                        controller: _licenseNumberController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your license number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // License Expiry Date
                      CustomTextField(
                        hintText: 'License Expiry Date',
                        prefixIcon: Icons.calendar_today_outlined,
                        controller: _licenseExpiryDateController,
                        readOnly: true,
                        onTap: _selectDate,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select license expiry date';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Vehicle Make
                      CustomTextField(
                        hintText: 'Vehicle Make (e.g., Toyota)',
                        prefixIcon: Icons.directions_car_outlined,
                        controller: _vehicleMakeController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter vehicle make';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Vehicle Model
                      CustomTextField(
                        hintText: 'Vehicle Model (e.g., Corolla)',
                        prefixIcon: Icons.car_rental_outlined,
                        controller: _vehicleModelController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter vehicle model';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Vehicle Year
                      CustomTextField(
                        hintText: 'Vehicle Year (e.g., 2021)',
                        prefixIcon: Icons.date_range_outlined,
                        controller: _vehicleYearController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter vehicle year';
                          }
                          final year = int.tryParse(value);
                          if (year == null ||
                              year < 1990 ||
                              year > DateTime.now().year + 1) {
                            return 'Please enter a valid year';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // License Plate
                      CustomTextField(
                        hintText: 'License Plate (e.g., 1234 TN 2025)',
                        prefixIcon: Icons.confirmation_number_outlined,
                        controller: _licensePlateController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter license plate';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Number of Seats
                      CustomTextField(
                        hintText: 'Number of Seats (e.g., 4)',
                        prefixIcon: Icons.people_outline,
                        controller: _numberOfSeatsController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of seats';
                          }
                          final seats = int.tryParse(value);
                          if (seats == null || seats < 1 || seats > 50) {
                            return 'Please enter a valid number of seats';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Service Areas
                      GestureDetector(
                        onTap: _showServiceAreasBottomSheet,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.textMedium,
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: selectedServiceAreas.isEmpty
                                      ? const Text(
                                          'Select Service Areas',
                                          style: TextStyle(
                                            color: AppColors.textLight,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        )
                                      : Wrap(
                                          spacing: 4,
                                          runSpacing: 4,
                                          children: selectedServiceAreas
                                              .take(3)
                                              .map(
                                                (area) => Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    area,
                                                    style: const TextStyle(
                                                      color: AppColors.primary,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList()
                                            ..addAll(selectedServiceAreas
                                                        .length >
                                                    3
                                                ? [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary
                                                            .withOpacity(0.05),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Text(
                                                        ' +${selectedServiceAreas.length - 3} more',
                                                        style: const TextStyle(
                                                          color: AppColors
                                                              .textMedium,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    )
                                                  ]
                                                : [])),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.textMedium,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Preferred Working Hours
                      CustomTextField(
                        hintText: 'Working Hours (e.g., 08:00-18:00)',
                        prefixIcon: Icons.access_time_outlined,
                        controller: _preferredWorkingHoursController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter preferred working hours';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 40),

                      // Submit button
                      CustomButton(
                        text: 'Save Details',
                        onPressed: _submitForm,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}