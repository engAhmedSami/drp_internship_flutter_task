import 'package:flutter/material.dart';
import '../models/driver.dart';
import '../services/mock_data_service.dart';

class DriversProvider with ChangeNotifier {
  final MockDataService _dataService = MockDataService();

  List<Driver> _drivers = [];
  bool _isLoading = false;
  String? _error;

  List<Driver> get drivers => _drivers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Driver> get availableDrivers => _drivers
      .where((driver) => driver.status == DriverStatus.available)
      .toList();

  List<Driver> get onTripDrivers =>
      _drivers.where((driver) => driver.status == DriverStatus.onTrip).toList();

  List<Driver> get offlineDrivers => _drivers
      .where((driver) => driver.status == DriverStatus.offline)
      .toList();

  int get totalDrivers => _drivers.length;
  int get availableDriversCount => availableDrivers.length;
  int get onTripDriversCount => onTripDrivers.length;
  int get offlineDriversCount => offlineDrivers.length;

  bool get hasDrivers => _drivers.isNotEmpty;
  bool get hasAvailableDrivers => availableDrivers.isNotEmpty;

  Future<void> loadDrivers() async {
    _setLoading(true);
    _setError(null);

    try {
      final drivers = await _dataService.getDrivers();
      _drivers = drivers;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load drivers: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> refreshDrivers() async {
    await loadDrivers();
  }

  Driver? getDriverById(String id) {
    try {
      return _drivers.firstWhere((driver) => driver.id == id);
    } catch (e) {
      return null;
    }
  }

  String getDriverNameById(String id) {
    final driver = getDriverById(id);
    return driver?.name ?? 'Unknown Driver';
  }

  Future<List<Driver>> getAvailableDrivers() async {
    try {
      if (_drivers.isEmpty) {
        await loadDrivers();
      }
      return availableDrivers;
    } catch (e) {
      _setError('Failed to get available drivers: ${e.toString()}');
      return [];
    }
  }

  Future<bool> updateDriverStatus(
    String driverId,
    DriverStatus status, {
    String? tripId,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _dataService.updateDriverStatus(
        driverId,
        status,
        tripId: tripId,
      );
      if (success) {
        final index = _drivers.indexWhere((driver) => driver.id == driverId);
        if (index != -1) {
          _drivers[index] = _drivers[index].copyWith(
            status: status,
            currentTripId: tripId,
          );
        }
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Failed to update driver status: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> addDriver(Driver driver) async {
    _setLoading(true);
    _setError(null);

    try {
      _drivers.add(driver);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to add driver: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateDriver(Driver updatedDriver) async {
    _setLoading(true);
    _setError(null);

    try {
      final index = _drivers.indexWhere(
        (driver) => driver.id == updatedDriver.id,
      );
      if (index != -1) {
        _drivers[index] = updatedDriver;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update driver: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> removeDriver(String driverId) async {
    _setLoading(true);
    _setError(null);

    try {
      _drivers.removeWhere((driver) => driver.id == driverId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to remove driver: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  List<Driver> searchDrivers(String query) {
    if (query.isEmpty) return _drivers;

    final lowerQuery = query.toLowerCase();
    return _drivers.where((driver) {
      return driver.name.toLowerCase().contains(lowerQuery) ||
          driver.licenseNumber.toLowerCase().contains(lowerQuery) ||
          driver.status.displayName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Driver> getDriversByStatus(DriverStatus status) {
    return _drivers.where((driver) => driver.status == status).toList();
  }

  bool isDriverAvailable(String driverId) {
    final driver = getDriverById(driverId);
    return driver?.status == DriverStatus.available;
  }

  bool isDriverOnTrip(String driverId) {
    final driver = getDriverById(driverId);
    return driver?.status == DriverStatus.onTrip;
  }

  String? getDriverCurrentTrip(String driverId) {
    final driver = getDriverById(driverId);
    return driver?.currentTripId;
  }

  Map<String, int> getDriversStatistics() {
    return {
      'total': totalDrivers,
      'available': availableDriversCount,
      'onTrip': onTripDriversCount,
      'offline': offlineDriversCount,
    };
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
