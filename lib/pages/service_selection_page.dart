import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'carpool_form_page.dart';
import 'driver_form_page.dart';
import 'cargo_form_page.dart';

class ServiceSelectionPage extends StatefulWidget {
  const ServiceSelectionPage({super.key});

  @override
  State<ServiceSelectionPage> createState() => _ServiceSelectionPageState();
}

class _ServiceSelectionPageState extends State<ServiceSelectionPage> {
  String? selectedService;

  void _navigateToService(String service) {
    setState(() {
      selectedService = service;
    });

    // Small delay for visual feedback
    Future.delayed(const Duration(milliseconds: 200), () {
      Widget destination;
      switch (service) {
        case 'carpool':
          destination = const CarpoolFormPage();
          break;
        case 'ride':
          destination = const DriverFormPage();
          break;
        case 'cargo':
          destination = const CargoFormPage();
          break;
        default:
          return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    });
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
                    'Choose Your',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ),
                  const Text(
                    'Service Type',
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
                    'Select the service that best fits your needs',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Service Cards
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    // Carpool Driver Card
                    _ServiceCard(
                      icon: Icons.people_outline,
                      title: 'Carpool Driver',
                      description:
                          'Share your regular commute and earn money while helping others',
                      features: const [
                        'Share fuel costs',
                        'Meet new people',
                        'Flexible schedule',
                        'Eco-friendly option',
                        'Easy registration',
                      ],
                      serviceType: 'carpool',
                      isSelected: selectedService == 'carpool',
                      onTap: () => _navigateToService('carpool'),
                    ),

                    const SizedBox(height: 24),

                    // Ride Driver Card
                    _ServiceCard(
                      icon: Icons.directions_car_outlined,
                      title: 'Ride Driver',
                      description:
                          'Become a professional driver and earn on your own schedule',
                      features: const [
                        'Flexible working hours',
                        'Weekly payments',
                        'Driver support',
                        'Insurance coverage',
                        'Background check included',
                      ],
                      serviceType: 'ride',
                      isSelected: selectedService == 'ride',
                      onTap: () => _navigateToService('ride'),
                    ),

                    const SizedBox(height: 24),

                    // Cargo Transporter Card
                    _ServiceCard(
                      icon: Icons.local_shipping_outlined,
                      title: 'Cargo Transporter',
                      description:
                          'Use your van or truck to transport goods and packages',
                      features: const [
                        'Higher earning potential',
                        'Business opportunities',
                        'Flexible contracts',
                        'Commercial insurance',
                        'Professional network',
                      ],
                      serviceType: 'cargo',
                      isSelected: selectedService == 'cargo',
                      onTap: () => _navigateToService('cargo'),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String> features;
  final String serviceType;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.features,
    required this.serviceType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.black.withOpacity(0.08),
              blurRadius: isSelected ? 25 : 20,
              offset: const Offset(0, 8),
              spreadRadius: isSelected ? 2 : 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textMedium,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Features list
            const Text(
              'Key Features:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 12),

            ...features
                .map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textMedium,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),

            const SizedBox(height: 20),

            // Action button
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  isSelected ? 'Selected - Continue' : 'Select This Service',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textDark,
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
