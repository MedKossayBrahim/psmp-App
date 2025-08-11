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
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      photoURL: json['photoURL'] ?? '',
      role: json['role'] ?? '',
      driverDetails: json['driverDetails'] != null
          ? DriverDetails.fromJson(json['driverDetails'])
          : null,
      carpoolDetails: json['carpoolDetails'] != null
          ? CarpoolDetails.fromJson(json['carpoolDetails'])
          : null,
      cargoDetails: json['cargoDetails'] != null
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
  final double pricePerKm;

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
    this.pricePerKm = 1.2, // Default value for pricePerKm
  });

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
      pricePerKm: (json['pricePerKm'] ?? 1.2).toDouble(),
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
      'pricePerKm': pricePerKm,
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
  });

  factory CarpoolDetails.fromJson(Map<String, dynamic> json) {
    return CarpoolDetails(
      fromLocation: json['fromLocation'] ?? '',
      toLocation: json['toLocation'] ?? '',
      departureDate: json['departureDate'] ?? '',
      departureTime: json['departureTime'] ?? '',
      availableSeats: json['availableSeats'] ?? 0,
      pricePerSeat: (json['pricePerSeat'] ?? 0).toDouble(),
      isRecurring: json['isRecurring'] ?? false,
      smokingAllowed: json['smokingAllowed'] ?? false,
      petsAllowed: json['petsAllowed'] ?? false,
      additionalInfo: json['additionalInfo'] ?? '',
      vehicleMake: json['vehicleMake'] ?? '',
      vehicleModel: json['vehicleModel'] ?? '',
      vehicleYear: json['vehicleYear'] ?? 0,
      vehicleColor: json['vehicleColor'] ?? '',
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
      pricePerKm: (json['pricePerKm'] ?? 0).toDouble(),
      minimumCharge: (json['minimumCharge'] ?? 0).toDouble(),
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
