import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../models/driver.dart';
import '../models/vehicle.dart';
import '../services/mock_data_service.dart';
import 'drivers_provider.dart';
import 'vehicles_provider.dart';

class TripsProvider with ChangeNotifier {
  final MockDataService _dataService = MockDataService();
  DriversProvider? _driversProvider;
  VehiclesProvider? _vehiclesProvider;

  List<Trip> _trips = [];
  List<Trip> _filteredTrips = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  TripStatus? _statusFilter;

  void setProviders(DriversProvider driversProvider, VehiclesProvider vehiclesProvider) {
    _driversProvider = driversProvider;
    _vehiclesProvider = vehiclesProvider;
  }

  List<Trip> get trips => _filteredTrips;
  List<Trip> get allTrips => _trips;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  TripStatus? get statusFilter => _statusFilter;

  int get totalTrips => _trips.length;
  int get pendingTrips =>
      _trips.where((trip) => trip.status == TripStatus.pending).length;
  int get inProgressTrips =>
      _trips.where((trip) => trip.status == TripStatus.inProgress).length;
  int get completedTrips =>
      _trips.where((trip) => trip.status == TripStatus.completed).length;

  bool get hasTrips => _trips.isNotEmpty;
  bool get hasFilteredTrips => _filteredTrips.isNotEmpty;

  Future<void> loadTrips() async {
    _setLoading(true);
    _setError(null);

    try {
      final trips = await _dataService.getTrips();
      _trips = trips;
      _applyFilters();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load trips: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> refreshTrips() async {
    await loadTrips();
  }

  Future<Trip?> getTripById(String id) async {
    try {
      final trip = _trips.firstWhere((trip) => trip.id == id);
      return trip;
    } catch (e) {
      try {
        return await _dataService.getTripById(id);
      } catch (e) {
        return null;
      }
    }
  }

  Future<bool> createTrip({
    required String driverId,
    required String vehicleId,
    required String pickupLocation,
    required String dropoffLocation,
    String? notes,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final newTrip = Trip(
        driverId: driverId,
        vehicleId: vehicleId,
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        notes: notes,
      );

      final success = await _dataService.createTrip(newTrip);
      if (success) {
        _trips.insert(0, newTrip);
        _applyFilters();

        await _updateDriverStatus(driverId, DriverStatus.onTrip, newTrip.id);
        await _updateVehicleStatus(
          vehicleId,
          VehicleStatus.assigned,
          newTrip.id,
        );
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Failed to create trip: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateTrip(Trip updatedTrip) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _dataService.updateTrip(updatedTrip);
      if (success) {
        final index = _trips.indexWhere((trip) => trip.id == updatedTrip.id);
        if (index != -1) {
          _trips[index] = updatedTrip;
          _applyFilters();
        }
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Failed to update trip: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateTripStatus(String tripId, TripStatus newStatus) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _dataService.updateTripStatus(tripId, newStatus);
      if (success) {
        final index = _trips.indexWhere((trip) => trip.id == tripId);
        if (index != -1) {
          final currentTrip = _trips[index];
          final updatedTrip = currentTrip.copyWith(
            status: newStatus,
            updatedAt: DateTime.now(),
          );
          _trips[index] = updatedTrip;

          if (newStatus == TripStatus.completed) {
            await _updateDriverStatus(
              currentTrip.driverId,
              DriverStatus.available,
              null,
            );
            await _updateVehicleStatus(
              currentTrip.vehicleId,
              VehicleStatus.available,
              null,
            );
          } else if (newStatus == TripStatus.inProgress) {
            await _updateDriverStatus(
              currentTrip.driverId,
              DriverStatus.onTrip,
              tripId,
            );
            await _updateVehicleStatus(
              currentTrip.vehicleId,
              VehicleStatus.assigned,
              tripId,
            );
          }

          _applyFilters();
        }
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Failed to update trip status: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteTrip(String tripId) async {
    _setLoading(true);
    _setError(null);

    try {
      final tripToDelete = _trips.firstWhere((trip) => trip.id == tripId);
      final success = await _dataService.deleteTrip(tripId);

      if (success) {
        _trips.removeWhere((trip) => trip.id == tripId);

        if (tripToDelete.status != TripStatus.completed) {
          await _updateDriverStatus(
            tripToDelete.driverId,
            DriverStatus.available,
            null,
          );
          await _updateVehicleStatus(
            tripToDelete.vehicleId,
            VehicleStatus.available,
            null,
          );
        }

        _applyFilters();
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Failed to delete trip: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  void searchTrips(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByStatus(TripStatus? status) {
    _statusFilter = status;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _applyFilters();
  }

  void _applyFilters() {
    List<Trip> filtered = List.from(_trips);

    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((trip) {
        // Get driver and vehicle for enhanced search
        final driver = _driversProvider?.getDriverById(trip.driverId);
        final vehicle = _vehiclesProvider?.getVehicleById(trip.vehicleId);

        return trip.id.toLowerCase().contains(lowerQuery) ||
            trip.pickupLocation.toLowerCase().contains(lowerQuery) ||
            trip.dropoffLocation.toLowerCase().contains(lowerQuery) ||
            trip.status.displayName.toLowerCase().contains(lowerQuery) ||
            (trip.notes?.toLowerCase().contains(lowerQuery) ?? false) ||
            (driver?.name.toLowerCase().contains(lowerQuery) ?? false) ||
            (driver?.licenseNumber.toLowerCase().contains(lowerQuery) ?? false) ||
            (vehicle?.name.toLowerCase().contains(lowerQuery) ?? false) ||
            (vehicle?.licensePlate.toLowerCase().contains(lowerQuery) ?? false) ||
            (vehicle?.type.displayName.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    if (_statusFilter != null) {
      filtered = filtered
          .where((trip) => trip.status == _statusFilter)
          .toList();
    }

    _filteredTrips = filtered;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> _updateDriverStatus(
    String driverId,
    DriverStatus status,
    String? tripId,
  ) async {
    try {
      await _dataService.updateDriverStatus(driverId, status, tripId: tripId);
    } catch (e) {
      debugPrint('Failed to update driver status: $e');
    }
  }

  Future<void> _updateVehicleStatus(
    String vehicleId,
    VehicleStatus status,
    String? tripId,
  ) async {
    try {
      await _dataService.updateVehicleStatus(vehicleId, status, tripId: tripId);
    } catch (e) {
      debugPrint('Failed to update vehicle status: $e');
    }
  }

  List<Trip> getTripsByStatus(TripStatus status) {
    return _trips.where((trip) => trip.status == status).toList();
  }

  List<Trip> getRecentTrips({int limit = 5}) {
    final sortedTrips = List<Trip>.from(_trips);
    sortedTrips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedTrips.take(limit).toList();
  }

  List<Trip> getTripsByDriver(String driverId) {
    return _trips.where((trip) => trip.driverId == driverId).toList();
  }

  List<Trip> getTripsByVehicle(String vehicleId) {
    return _trips.where((trip) => trip.vehicleId == vehicleId).toList();
  }

  Map<String, int> getTripsStatistics() {
    return {
      'total': totalTrips,
      'pending': pendingTrips,
      'inProgress': inProgressTrips,
      'completed': completedTrips,
    };
  }
}
