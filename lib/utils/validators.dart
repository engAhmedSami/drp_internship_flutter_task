import 'constants.dart';

class Validators {
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName is required'
          : AppStrings.requiredField;
    }
    return null;
  }

  static String? validateDriverSelection(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a driver';
    }
    return null;
  }

  static String? validateVehicleSelection(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a vehicle';
    }
    return null;
  }

  static String? validatePickupLocation(String? value) {
    final requiredError = validateRequired(value, 'Pickup location');
    if (requiredError != null) return requiredError;

    if (value!.length > AppConstants.maxLocationNameLength) {
      return 'Pickup location cannot exceed ${AppConstants.maxLocationNameLength} characters';
    }

    return null;
  }

  static String? validateDropoffLocation(String? value) {
    final requiredError = validateRequired(value, 'Drop-off location');
    if (requiredError != null) return requiredError;

    if (value!.length > AppConstants.maxLocationNameLength) {
      return 'Drop-off location cannot exceed ${AppConstants.maxLocationNameLength} characters';
    }

    return null;
  }

  static String? validateNotes(String? value) {
    if (value != null && value.length > AppConstants.maxTripNotesLength) {
      return 'Notes cannot exceed ${AppConstants.maxTripNotesLength} characters';
    }
    return null;
  }

  static String? validateDriverName(String? value) {
    final requiredError = validateRequired(value, 'Driver name');
    if (requiredError != null) return requiredError;

    if (value!.length > AppConstants.maxDriverNameLength) {
      return 'Driver name cannot exceed ${AppConstants.maxDriverNameLength} characters';
    }

    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Driver name can only contain letters and spaces';
    }

    return null;
  }

  static String? validateLicenseNumber(String? value) {
    final requiredError = validateRequired(value, 'License number');
    if (requiredError != null) return requiredError;

    if (value!.length < 5) {
      return 'License number must be at least 5 characters';
    }

    return null;
  }

  static String? validateVehicleName(String? value) {
    final requiredError = validateRequired(value, 'Vehicle name');
    if (requiredError != null) return requiredError;

    if (value!.length > AppConstants.maxVehicleNameLength) {
      return 'Vehicle name cannot exceed ${AppConstants.maxVehicleNameLength} characters';
    }

    return null;
  }

  static String? validateLicensePlate(String? value) {
    final requiredError = validateRequired(value, 'License plate');
    if (requiredError != null) return requiredError;

    final plateRegex = RegExp(r'^[A-Z0-9\-\s]+$');
    if (!plateRegex.hasMatch(value!.toUpperCase())) {
      return 'Invalid license plate format';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    final requiredError = validateRequired(value, 'Email');
    if (requiredError != null) return requiredError;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value!)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    final requiredError = validateRequired(value, 'Phone number');
    if (requiredError != null) return requiredError;

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value!)) {
      return 'Please enter a valid phone number';
    }

    if (value.replaceAll(RegExp(r'[\s\-\(\)]'), '').length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    return null;
  }

  static bool isSameLocation(String pickup, String dropoff) {
    return pickup.trim().toLowerCase() == dropoff.trim().toLowerCase();
  }

  static String? validateLocationsDifferent(String? pickup, String? dropoff) {
    if (pickup != null && dropoff != null && isSameLocation(pickup, dropoff)) {
      return 'Pickup and drop-off locations must be different';
    }
    return null;
  }

  static String? validateForm(Map<String, String?> values, Map<String, String? Function(String?)> validators) {
    for (final entry in validators.entries) {
      final fieldName = entry.key;
      final validator = entry.value;
      final value = values[fieldName];

      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}