class User {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String photoURL;
  final String role;
  final DriverDetails? driverDetails;
  final CarpoolDetails? carpoolDetails;
  final CargoDetails? cargoDetails;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.photoURL,
    required this.role,
    this.driverDetails,
    this.carpoolDetails,
    this.cargoDetails,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id']?['\$oid'] ?? '', // handle Mongo ObjectId
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      photoURL: json['photoURL'] ?? '',
      role: json['role'] ?? '',
      driverDetails: json['driverDetails'] != null && json['driverDetails'] is Map
          ? DriverDetails.fromJson(json['driverDetails'])
          : null,
      carpoolDetails: json['carpoolDetails'] != null && json['carpoolDetails'] is Map
          ? CarpoolDetails.fromJson(json['carpoolDetails'])
          : null,
      cargoDetails: json['cargoDetails'] != null && json['cargoDetails'] is Map
          ? CargoDetails.fromJson(json['cargoDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'role': role,
      'driverDetails': driverDetails?.toJson(),
      'carpoolDetails': carpoolDetails?.toJson(),
      'cargoDetails': cargoDetails?.toJson(),
    };
  }
}

class DriverDetails {
  final String city;
  final String licenseNumber;
  final String vehicleMake;
  final String vehicleModel;
  final int vehicleYear;
  final String licensePlate;
  final int numberOfSeats;
  final String serviceAreas;
  final String preferredWorkingHours;
  final double price4km;

  DriverDetails({
    required this.city,
    required this.licenseNumber,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.licensePlate,
    required this.numberOfSeats,
    required this.serviceAreas,
    required this.preferredWorkingHours,
    this.price4km = 1.2,
  });

  static double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory DriverDetails.fromJson(Map<String, dynamic> json) {
    return DriverDetails(
      city: json['city'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      vehicleMake: json['vehicleMake'] ?? '',
      vehicleModel: json['vehicleModel'] ?? '',
      vehicleYear: json['vehicleYear'] ?? 0,
      licensePlate: json['licensePlate'] ?? '',
      numberOfSeats: json['numberOfSeats'] ?? 0,
      serviceAreas: json['serviceAreas'] ?? '',
      preferredWorkingHours: json['preferredWorkingHours'] ?? '',
      price4km: _parseDouble(json['price4km'], 1.2),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'licenseNumber': licenseNumber,
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
      'vehicleYear': vehicleYear,
      'licensePlate': licensePlate,
      'numberOfSeats': numberOfSeats,
      'serviceAreas': serviceAreas,
      'preferredWorkingHours': preferredWorkingHours,
      'price4km': price4km,
    };
  }
}

class CarpoolDetails {
  final String fromLocation;
  final String toLocation;
  final String departureDate;
  final String departureTime;
  final int availableSeats;
  final double pricePerSeat;
  final bool isRecurring;
  final bool smokingAllowed;
  final bool petsAllowed;
  final String additionalInfo;
  final String vehicleMake;
  final String vehicleModel;
  final int vehicleYear;
  final String vehicleColor;
  final List<User> passengers; // ✅ NEW

  CarpoolDetails({
    required this.fromLocation,
    required this.toLocation,
    required this.departureDate,
    required this.departureTime,
    required this.availableSeats,
    required this.pricePerSeat,
    required this.isRecurring,
    required this.smokingAllowed,
    required this.petsAllowed,
    required this.additionalInfo,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.vehicleColor,
    this.passengers = const [], // ✅ NEW default empty
  });

  static double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory CarpoolDetails.fromJson(Map<String, dynamic> json) {
    return CarpoolDetails(
      fromLocation: json['fromLocation'] ?? '',
      toLocation: json['toLocation'] ?? '',
      departureDate: json['departureDate']?.toString() ?? '',
      departureTime: json['departureTime']?.toString() ?? '',
      availableSeats: json['availableSeats'] ?? 0,
      pricePerSeat: _parseDouble(json['pricePerSeat']),
      isRecurring: json['isRecurring'] ?? false,
      smokingAllowed: json['smokingAllowed'] ?? false,
      petsAllowed: json['petsAllowed'] ?? false,
      additionalInfo: json['additionalInfo'] ?? '',
      vehicleMake: json['vehicleMake'] ?? '',
      vehicleModel: json['vehicleModel'] ?? '',
      vehicleYear: json['vehicleYear'] ?? 0,
      vehicleColor: json['vehicleColor'] ?? '',
      passengers: (json['passengers'] as List<dynamic>? ?? [])
          .map((p) => User.fromJson(p))
          .toList(), // ✅ map list of users
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'departureDate': departureDate,
      'departureTime': departureTime,
      'availableSeats': availableSeats,
      'pricePerSeat': pricePerSeat,
      'isRecurring': isRecurring,
      'smokingAllowed': smokingAllowed,
      'petsAllowed': petsAllowed,
      'additionalInfo': additionalInfo,
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
      'vehicleYear': vehicleYear,
      'vehicleColor': vehicleColor,
      'passengers': passengers.map((p) => p.toJson()).toList(), // ✅ include in JSON
    };
  }
}

class CargoDetails {
  final String companyName;
  final String contactPerson;
  final String businessLicenseNumber;
  final String vehicleType;
  final String vehicleMake;
  final String vehicleModel;
  final int vehicleYear;
  final int maxWeightCapacityKg;
  final String maxDimensionsCm;
  final String serviceAreas;
  final double pricePerKm;
  final double minimumCharge;
  final String serviceDescription;

  CargoDetails({
    required this.companyName,
    required this.contactPerson,
    required this.businessLicenseNumber,
    required this.vehicleType,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.maxWeightCapacityKg,
    required this.maxDimensionsCm,
    required this.serviceAreas,
    required this.pricePerKm,
    required this.minimumCharge,
    required this.serviceDescription,
  });

  static double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory CargoDetails.fromJson(Map<String, dynamic> json) {
    return CargoDetails(
      companyName: json['companyName'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
      businessLicenseNumber: json['businessLicenseNumber'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      vehicleMake: json['vehicleMake'] ?? '',
      vehicleModel: json['vehicleModel'] ?? '',
      vehicleYear: json['vehicleYear'] ?? 0,
      maxWeightCapacityKg: json['maxWeightCapacityKg'] ?? 0,
      maxDimensionsCm: json['maxDimensionsCm'] ?? '',
      serviceAreas: json['serviceAreas'] ?? '',
      pricePerKm: _parseDouble(json['pricePerKm']),
      minimumCharge: _parseDouble(json['minimumCharge']),
      serviceDescription: json['serviceDescription'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'contactPerson': contactPerson,
      'businessLicenseNumber': businessLicenseNumber,
      'vehicleType': vehicleType,
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
      'vehicleYear': vehicleYear,
      'maxWeightCapacityKg': maxWeightCapacityKg,
      'maxDimensionsCm': maxDimensionsCm,
      'serviceAreas': serviceAreas,
      'pricePerKm': pricePerKm,
      'minimumCharge': minimumCharge,
      'serviceDescription': serviceDescription,
    };
  }
}
