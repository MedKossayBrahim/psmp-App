import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class CarpoolFormPage extends StatefulWidget {
  const CarpoolFormPage({super.key});

  @override
  State<CarpoolFormPage> createState() => _CarpoolFormPageState();
}

class _CarpoolFormPageState extends State<CarpoolFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _fromLocationController = TextEditingController();
  final _toLocationController = TextEditingController();
  final _departureDateController = TextEditingController();
  final _departureTimeController = TextEditingController();
  final _availableSeatsController = TextEditingController();
  final _pricePerSeatController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final _vehicleMakeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  
  bool smokingAllowed = false;
  bool petsAllowed = true;
  bool _isLoading = false;

  final List<String> tunisianCities = [
    'Tunis', 'Sfax', 'Sousse', 'Kairouan', 'Bizerte', 'Gabès', 'Ariana',
    'Gafsa', 'Monastir', 'Ben Arous', 'Kasserine', 'Médenine', 'Nabeul',
    'Tataouine', 'Beja', 'Jendouba', 'Mahdia', 'Siliana', 'Manouba',
    'Kef', 'Tozeur', 'Sidi Bouzid', 'Zaghouan', 'Kebili'
  ];

  final List<String> vehicleColors = [
    'Black', 'White', 'Silver', 'Gray', 'Blue', 'Red', 'Green', 'Brown', 'Other'
  ];

  @override
  void dispose() {
    _fromLocationController.dispose();
    _toLocationController.dispose();
    _departureDateController.dispose();
    _departureTimeController.dispose();
    _availableSeatsController.dispose();
    _pricePerSeatController.dispose();
    _additionalInfoController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _vehicleColorController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
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
        _departureDateController.text = picked.toIso8601String();
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
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
      final now = DateTime.now();
      final dateTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      setState(() {
        _departureTimeController.text = dateTime.toIso8601String();
      });
    }
  }

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
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: controller.text == city ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        city,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: controller.text == city ? AppColors.primary : AppColors.textDark,
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

  void _showColorBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Vehicle Color',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: vehicleColors.length,
                itemBuilder: (context, index) {
                  final color = vehicleColors[index];
                  return GestureDetector(
                    onTap: () {
                      _vehicleColorController.text = color;
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _vehicleColorController.text == color ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        color,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _vehicleColorController.text == color ? AppColors.primary : AppColors.textDark,
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Carpool details saved successfully!'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
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
                    'Carpool',
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
                    'Set up your carpool trip information',
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
                      // From Location
                      GestureDetector(
                        onTap: () => _showLocationBottomSheet(_fromLocationController, 'From Location'),
                        child: AbsorbPointer(
                          child: CustomTextField(
                            hintText: 'From Location',
                            prefixIcon: Icons.my_location_outlined,
                            controller: _fromLocationController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select departure location';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // To Location
                      GestureDetector(
                        onTap: () => _showLocationBottomSheet(_toLocationController, 'To Location'),
                        child: AbsorbPointer(
                          child: CustomTextField(
                            hintText: 'To Location',
                            prefixIcon: Icons.location_on_outlined,
                            controller: _toLocationController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select destination';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Departure Date
                      CustomTextField(
                        hintText: 'Departure Date',
                        prefixIcon: Icons.calendar_today_outlined,
                        controller: _departureDateController,
                        readOnly: true,
                        onTap: _selectDate,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select departure date';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Departure Time
                      CustomTextField(
                        hintText: 'Departure Time',
                        prefixIcon: Icons.access_time_outlined,
                        controller: _departureTimeController,
                        readOnly: true,
                        onTap: _selectTime,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select departure time';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Available Seats and Price Per Seat
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              hintText: 'Available Seats',
                              prefixIcon: Icons.people_outline,
                              controller: _availableSeatsController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final seats = int.tryParse(value);
                                if (seats == null || seats < 1 || seats > 8) {
                                  return 'Invalid seats';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              hintText: 'Price/Seat (TND)',
                              prefixIcon: Icons.attach_money_outlined,
                              controller: _pricePerSeatController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price < 0) {
                                  return 'Invalid price';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Preferences Section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Trip Preferences',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Smoking Allowed
                            Row(
                              children: [
                                const Icon(
                                  Icons.smoking_rooms_outlined,
                                  color: AppColors.textMedium,
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Text(
                                    'Smoking Allowed',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: smokingAllowed,
                                  onChanged: (value) {
                                    setState(() {
                                      smokingAllowed = value;
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Pets Allowed
                            Row(
                              children: [
                                const Icon(
                                  Icons.pets_outlined,
                                  color: AppColors.textMedium,
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Text(
                                    'Pets Allowed',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: petsAllowed,
                                  onChanged: (value) {
                                    setState(() {
                                      petsAllowed = value;
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Vehicle Information Section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vehicle Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Vehicle Make and Model
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    hintText: 'Make (e.g., Hyundai)',
                                    prefixIcon: Icons.directions_car_outlined,
                                    controller: _vehicleMakeController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    hintText: 'Model (e.g., i30)',
                                    prefixIcon: Icons.car_rental_outlined,
                                    controller: _vehicleModelController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Vehicle Year and Color
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    hintText: 'Year (e.g., 2020)',
                                    prefixIcon: Icons.date_range_outlined,
                                    controller: _vehicleYearController,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      final year = int.tryParse(value);
                                      if (year == null || year < 1990 || year > DateTime.now().year + 1) {
                                        return 'Invalid year';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _showColorBottomSheet,
                                    child: AbsorbPointer(
                                      child: CustomTextField(
                                        hintText: 'Color',
                                        prefixIcon: Icons.palette_outlined,
                                        controller: _vehicleColorController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Required';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Additional Info
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextFormField(
                          controller: _additionalInfoController,
                          maxLines: 4,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Additional Information (e.g., "Please be on time. Luggage space is limited.")',
                            hintStyle: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Icon(
                                Icons.info_outline,
                                color: AppColors.textMedium,
                                size: 24,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Submit button
                      CustomButton(
                        text: 'Create Carpool',
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
