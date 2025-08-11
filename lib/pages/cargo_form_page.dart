import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class CargoFormPage extends StatefulWidget {
  const CargoFormPage({super.key});

  @override
  State<CargoFormPage> createState() => _CargoFormPageState();
}

class _CargoFormPageState extends State<CargoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _businessLicenseController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehicleMakeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _maxWeightController = TextEditingController();
  final _maxDimensionsController = TextEditingController();
  final _serviceAreasController = TextEditingController();
  final _pricePerKmController = TextEditingController();
  final _minimumChargeController = TextEditingController();
  final _serviceDescriptionController = TextEditingController();
  
  bool _isLoading = false;

  final List<String> vehicleTypes = [
    'Truck', 'Van', 'Pickup', 'Trailer', 'Container Truck', 'Refrigerated Truck', 'Flatbed', 'Other'
  ];

  @override
  void dispose() {
    _companyNameController.dispose();
    _contactPersonController.dispose();
    _businessLicenseController.dispose();
    _vehicleTypeController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _maxWeightController.dispose();
    _maxDimensionsController.dispose();
    _serviceAreasController.dispose();
    _pricePerKmController.dispose();
    _minimumChargeController.dispose();
    _serviceDescriptionController.dispose();
    super.dispose();
  }

  void _showVehicleTypeBottomSheet() {
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
              'Select Vehicle Type',
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
                itemCount: vehicleTypes.length,
                itemBuilder: (context, index) {
                  final type = vehicleTypes[index];
                  return GestureDetector(
                    onTap: () {
                      _vehicleTypeController.text = type;
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _vehicleTypeController.text == type ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _vehicleTypeController.text == type ? AppColors.primary : AppColors.textDark,
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
            content: Text('Cargo service details saved successfully!'),
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
                    'Cargo',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ),
                  const Text(
                    'Service',
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
                    'Set up your cargo transport business',
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
                      // Company Information Section
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
                              'Company Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            CustomTextField(
                              hintText: 'Company Name (e.g., GoTransport SARL)',
                              prefixIcon: Icons.business_outlined,
                              controller: _companyNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter company name';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            CustomTextField(
                              hintText: 'Contact Person (e.g., Ahmed Trabelsi)',
                              prefixIcon: Icons.person_outline,
                              controller: _contactPersonController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter contact person';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            CustomTextField(
                              hintText: 'Business License (e.g., TN-BIZ-0098765432)',
                              prefixIcon: Icons.verified_outlined,
                              controller: _businessLicenseController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter business license number';
                                }
                                return null;
                              },
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
                            
                            // Vehicle Type
                            GestureDetector(
                              onTap: _showVehicleTypeBottomSheet,
                              child: AbsorbPointer(
                                child: CustomTextField(
                                  hintText: 'Vehicle Type',
                                  prefixIcon: Icons.local_shipping_outlined,
                                  controller: _vehicleTypeController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select vehicle type';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Vehicle Make and Model
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    hintText: 'Make (e.g., Mercedes-Benz)',
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
                                    hintText: 'Model (e.g., Actros)',
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
                            
                            CustomTextField(
                              hintText: 'Vehicle Year (e.g., 2019)',
                              prefixIcon: Icons.date_range_outlined,
                              controller: _vehicleYearController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter vehicle year';
                                }
                                final year = int.tryParse(value);
                                if (year == null || year < 1990 || year > DateTime.now().year + 1) {
                                  return 'Please enter a valid year';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Capacity Information Section
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
                              'Capacity Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            CustomTextField(
                              hintText: 'Max Weight Capacity (kg) - e.g., 3000',
                              prefixIcon: Icons.fitness_center_outlined,
                              controller: _maxWeightController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter max weight capacity';
                                }
                                final weight = int.tryParse(value);
                                if (weight == null || weight <= 0) {
                                  return 'Please enter a valid weight';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            CustomTextField(
                              hintText: 'Max Dimensions (cm) - e.g., 500x200x250',
                              prefixIcon: Icons.straighten_outlined,
                              controller: _maxDimensionsController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter max dimensions';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Service Information Section
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
                              'Service Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            CustomTextField(
                              hintText: 'Service Areas (e.g., Nationwide)',
                              prefixIcon: Icons.location_on_outlined,
                              controller: _serviceAreasController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter service areas';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Price Per Km and Minimum Charge
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    hintText: 'Price/Km (TND) - e.g., 0.75',
                                    prefixIcon: Icons.attach_money_outlined,
                                    controller: _pricePerKmController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    hintText: 'Min Charge (TND) - e.g., 25',
                                    prefixIcon: Icons.money_outlined,
                                    controller: _minimumChargeController,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      final charge = double.tryParse(value);
                                      if (charge == null || charge < 0) {
                                        return 'Invalid charge';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Service Description
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextFormField(
                          controller: _serviceDescriptionController,
                          maxLines: 4,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Service Description (e.g., "Specialized in temperature-sensitive cargo and heavy loads.")',
                            hintStyle: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Icon(
                                Icons.description_outlined,
                                color: AppColors.textMedium,
                                size: 24,
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter service description';
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Submit button
                      CustomButton(
                        text: 'Register Cargo Service',
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
