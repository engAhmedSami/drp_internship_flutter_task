import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/mock_data_service.dart';

class VehiclesProvider with ChangeNotifier {
  final MockDataService _dataService = MockDataService();

  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _error;

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Vehicle> get availableVehicles => _vehicles
      .where((vehicle) => vehicle.status == VehicleStatus.available)
      .toList();

  List<Vehicle> get assignedVehicles => _vehicles
      .where((vehicle) => vehicle.status == VehicleStatus.assigned)
      .toList();

  List<Vehicle> get maintenanceVehicles => _vehicles
      .where((vehicle) => vehicle.status == VehicleStatus.maintenance)
      .toList();

  int get totalVehicles => _vehicles.length;
  int get availableVehiclesCount => availableVehicles.length;
  int get assignedVehiclesCount => assignedVehicles.length;
  int get maintenanceVehiclesCount => maintenanceVehicles.length;

  bool get hasVehicles => _vehicles.isNotEmpty;
  bool get hasAvailableVehicles => availableVehicles.isNotEmpty;

  List<Vehicle> get truckVehicles =>
      _vehicles.where((v) => v.type == VehicleType.truck).toList();
  List<Vehicle> get vanVehicles =>
      _vehicles.where((v) => v.type == VehicleType.van).toList();
  List<Vehicle> get bikeVehicles =>
      _vehicles.where((v) => v.type == VehicleType.bike).toList();
  List<Vehicle> get carVehicles =>
      _vehicles.where((v) => v.type == VehicleType.car).toList();

  Future<void> loadVehicles() async {
    _setLoading(true);
    _setError(null);

    try {
      final vehicles = await _dataService.getVehicles();
      _vehicles = vehicles;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load vehicles: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> refreshVehicles() async {
    await loadVehicles();
  }

  Vehicle? getVehicleById(String id) {
    try {
      return _vehicles.firstWhere((vehicle) => vehicle.id == id);
    } catch (e) {
      return null;
    }
  }

  String getVehicleNameById(String id) {
    final vehicle = getVehicleById(id);
    return vehicle?.name ?? 'Unknown Vehicle';
  }

  String getVehicleDisplayInfo(String id) {
    final vehicle = getVehicleById(id);
    if (vehicle == null) return 'Unknown Vehicle';
    return '${vehicle.name} (${vehicle.type.displayName})';
  }

  Future<List<Vehicle>> getAvailableVehicles() async {
    try {
      if (_vehicles.isEmpty) {
        await loadVehicles();
      }
      return availableVehicles;
    } catch (e) {
      _setError('Failed to get available vehicles: ${e.toString()}');
      return [];
    }
  }

  Future<bool> updateVehicleStatus(
    String vehicleId,
    VehicleStatus status, {
    String? tripId,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _dataService.updateVehicleStatus(
        vehicleId,
        status,
        tripId: tripId,
      );
      if (success) {
        final index = _vehicles.indexWhere(
          (vehicle) => vehicle.id == vehicleId,
        );
        if (index != -1) {
          _vehicles[index] = _vehicles[index].copyWith(
            status: status,
            currentTripId: tripId,
          );
        }
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Failed to update vehicle status: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> addVehicle(Vehicle vehicle) async {
    _setLoading(true);
    _setError(null);

    try {
      _vehicles.add(vehicle);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to add vehicle: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateVehicle(Vehicle updatedVehicle) async {
    _setLoading(true);
    _setError(null);

    try {
      final index = _vehicles.indexWhere(
        (vehicle) => vehicle.id == updatedVehicle.id,
      );
      if (index != -1) {
        _vehicles[index] = updatedVehicle;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update vehicle: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> removeVehicle(String vehicleId) async {
    _setLoading(true);
    _setError(null);

    try {
      _vehicles.removeWhere((vehicle) => vehicle.id == vehicleId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to remove vehicle: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  List<Vehicle> searchVehicles(String query) {
    if (query.isEmpty) return _vehicles;

    final lowerQuery = query.toLowerCase();
    return _vehicles.where((vehicle) {
      return vehicle.name.toLowerCase().contains(lowerQuery) ||
          vehicle.licensePlate.toLowerCase().contains(lowerQuery) ||
          vehicle.type.displayName.toLowerCase().contains(lowerQuery) ||
          vehicle.status.displayName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Vehicle> getVehiclesByStatus(VehicleStatus status) {
    return _vehicles.where((vehicle) => vehicle.status == status).toList();
  }

  List<Vehicle> getVehiclesByType(VehicleType type) {
    return _vehicles.where((vehicle) => vehicle.type == type).toList();
  }

  List<Vehicle> getAvailableVehiclesByType(VehicleType type) {
    return _vehicles
        .where(
          (vehicle) =>
              vehicle.type == type && vehicle.status == VehicleStatus.available,
        )
        .toList();
  }

  bool isVehicleAvailable(String vehicleId) {
    final vehicle = getVehicleById(vehicleId);
    return vehicle?.status == VehicleStatus.available;
  }

  bool isVehicleAssigned(String vehicleId) {
    final vehicle = getVehicleById(vehicleId);
    return vehicle?.status == VehicleStatus.assigned;
  }

  bool isVehicleInMaintenance(String vehicleId) {
    final vehicle = getVehicleById(vehicleId);
    return vehicle?.status == VehicleStatus.maintenance;
  }

  String? getVehicleCurrentTrip(String vehicleId) {
    final vehicle = getVehicleById(vehicleId);
    return vehicle?.currentTripId;
  }

  Map<String, int> getVehiclesStatistics() {
    return {
      'total': totalVehicles,
      'available': availableVehiclesCount,
      'assigned': assignedVehiclesCount,
      'maintenance': maintenanceVehiclesCount,
    };
  }

  Map<String, int> getVehicleTypeStatistics() {
    return {
      'trucks': truckVehicles.length,
      'vans': vanVehicles.length,
      'bikes': bikeVehicles.length,
      'cars': carVehicles.length,
    };
  }

  List<Vehicle> filterVehicles({
    VehicleType? type,
    VehicleStatus? status,
    String? searchQuery,
  }) {
    List<Vehicle> filtered = List.from(_vehicles);

    if (type != null) {
      filtered = filtered.where((vehicle) => vehicle.type == type).toList();
    }

    if (status != null) {
      filtered = filtered.where((vehicle) => vehicle.status == status).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      filtered = filtered.where((vehicle) {
        return vehicle.name.toLowerCase().contains(lowerQuery) ||
            vehicle.licensePlate.toLowerCase().contains(lowerQuery) ||
            vehicle.type.displayName.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    return filtered;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
