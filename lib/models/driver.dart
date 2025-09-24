import 'package:uuid/uuid.dart';

enum DriverStatus { available, onTrip, offline }

class Driver {
  final String id;
  final String name;
  final String licenseNumber;
  final DriverStatus status;
  final String? currentTripId;

  Driver({
    String? id,
    required this.name,
    required this.licenseNumber,
    this.status = DriverStatus.available,
    this.currentTripId,
  }) : id = id ?? const Uuid().v4();

  Driver copyWith({
    String? id,
    String? name,
    String? licenseNumber,
    DriverStatus? status,
    String? currentTripId,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      status: status ?? this.status,
      currentTripId: currentTripId ?? this.currentTripId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'licenseNumber': licenseNumber,
      'status': status.index,
      'currentTripId': currentTripId,
    };
  }

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      licenseNumber: json['licenseNumber'],
      status: DriverStatus.values[json['status']],
      currentTripId: json['currentTripId'],
    );
  }

  @override
  String toString() {
    return 'Driver{id: $id, name: $name, licenseNumber: $licenseNumber, status: $status, currentTripId: $currentTripId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Driver &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          licenseNumber == other.licenseNumber &&
          status == other.status &&
          currentTripId == other.currentTripId;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      licenseNumber.hashCode ^
      status.hashCode ^
      currentTripId.hashCode;
}

extension DriverStatusExtension on DriverStatus {
  String get displayName {
    switch (this) {
      case DriverStatus.available:
        return 'Available';
      case DriverStatus.onTrip:
        return 'On Trip';
      case DriverStatus.offline:
        return 'Offline';
    }
  }

  String get displayValue {
    switch (this) {
      case DriverStatus.available:
        return 'available';
      case DriverStatus.onTrip:
        return 'on_trip';
      case DriverStatus.offline:
        return 'offline';
    }
  }
}