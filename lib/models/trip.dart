import 'package:uuid/uuid.dart';

enum TripStatus { pending, inProgress, completed }

class Trip {
  final String id;
  final String driverId;
  final String vehicleId;
  final String pickupLocation;
  final String dropoffLocation;
  final TripStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;

  Trip({
    String? id,
    required this.driverId,
    required this.vehicleId,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.status = TripStatus.pending,
    DateTime? createdAt,
    this.updatedAt,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Trip copyWith({
    String? id,
    String? driverId,
    String? vehicleId,
    String? pickupLocation,
    String? dropoffLocation,
    TripStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return Trip(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      vehicleId: vehicleId ?? this.vehicleId,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'vehicleId': vehicleId,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      driverId: json['driverId'],
      vehicleId: json['vehicleId'],
      pickupLocation: json['pickupLocation'],
      dropoffLocation: json['dropoffLocation'],
      status: TripStatus.values[json['status']],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      notes: json['notes'],
    );
  }

  @override
  String toString() {
    return 'Trip{id: $id, driverId: $driverId, vehicleId: $vehicleId, pickupLocation: $pickupLocation, dropoffLocation: $dropoffLocation, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, notes: $notes}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Trip &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          driverId == other.driverId &&
          vehicleId == other.vehicleId &&
          pickupLocation == other.pickupLocation &&
          dropoffLocation == other.dropoffLocation &&
          status == other.status &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      driverId.hashCode ^
      vehicleId.hashCode ^
      pickupLocation.hashCode ^
      dropoffLocation.hashCode ^
      status.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      notes.hashCode;
}

extension TripStatusExtension on TripStatus {
  String get displayName {
    switch (this) {
      case TripStatus.pending:
        return 'Pending';
      case TripStatus.inProgress:
        return 'In Progress';
      case TripStatus.completed:
        return 'Completed';
    }
  }

  String get displayValue {
    switch (this) {
      case TripStatus.pending:
        return 'pending';
      case TripStatus.inProgress:
        return 'in_progress';
      case TripStatus.completed:
        return 'completed';
    }
  }
}