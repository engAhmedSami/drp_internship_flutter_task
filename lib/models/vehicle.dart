import 'package:uuid/uuid.dart';

enum VehicleType { truck, van, bike, car }

enum VehicleStatus { available, assigned, maintenance }

class Vehicle {
  final String id;
  final String name;
  final VehicleType type;
  final VehicleStatus status;
  final String licensePlate;
  final String? currentTripId;

  Vehicle({
    String? id,
    required this.name,
    required this.type,
    this.status = VehicleStatus.available,
    required this.licensePlate,
    this.currentTripId,
  }) : id = id ?? const Uuid().v4();

  Vehicle copyWith({
    String? id,
    String? name,
    VehicleType? type,
    VehicleStatus? status,
    String? licensePlate,
    String? currentTripId,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      licensePlate: licensePlate ?? this.licensePlate,
      currentTripId: currentTripId ?? this.currentTripId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'status': status.index,
      'licensePlate': licensePlate,
      'currentTripId': currentTripId,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      name: json['name'],
      type: VehicleType.values[json['type']],
      status: VehicleStatus.values[json['status']],
      licensePlate: json['licensePlate'],
      currentTripId: json['currentTripId'],
    );
  }

  @override
  String toString() {
    return 'Vehicle{id: $id, name: $name, type: $type, status: $status, licensePlate: $licensePlate, currentTripId: $currentTripId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vehicle &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          status == other.status &&
          licensePlate == other.licensePlate &&
          currentTripId == other.currentTripId;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      status.hashCode ^
      licensePlate.hashCode ^
      currentTripId.hashCode;
}

extension VehicleTypeExtension on VehicleType {
  String get displayName {
    switch (this) {
      case VehicleType.truck:
        return 'Truck';
      case VehicleType.van:
        return 'Van';
      case VehicleType.bike:
        return 'Bike';
      case VehicleType.car:
        return 'Car';
    }
  }

  String get displayValue {
    switch (this) {
      case VehicleType.truck:
        return 'truck';
      case VehicleType.van:
        return 'van';
      case VehicleType.bike:
        return 'bike';
      case VehicleType.car:
        return 'car';
    }
  }
}

extension VehicleStatusExtension on VehicleStatus {
  String get displayName {
    switch (this) {
      case VehicleStatus.available:
        return 'Available';
      case VehicleStatus.assigned:
        return 'Assigned';
      case VehicleStatus.maintenance:
        return 'Maintenance';
    }
  }

  String get displayValue {
    switch (this) {
      case VehicleStatus.available:
        return 'available';
      case VehicleStatus.assigned:
        return 'assigned';
      case VehicleStatus.maintenance:
        return 'maintenance';
    }
  }
}