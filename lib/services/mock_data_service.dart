import 'dart:math';
import '../models/driver.dart';
import '../models/vehicle.dart';
import '../models/trip.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  static const List<String> _driverNames = [
    'Ahmed Ali',
    'Muhammad Hassan',
    'Ali Khan',
    'Usman Sheikh',
    'Fahad Malik',
    'Hassan Raza',
    'Imran Ahmad',
    'Tariq Mahmood',
  ];

  static const List<String> _vehicleNames = [
    'City Express',
    'Metro Cargo',
    'Swift Delivery',
    'Urban Transport',
    'Quick Move',
    'Fast Track',
    'Rapid Transit',
    'Speed Wheels',
    'Prime Logistics',
    'Elite Transport',
  ];

  static const List<String> _locations = [
    'Islamabad',
    'Rawalpindi',
    'Lahore',
    'Karachi',
    'Peshawar',
    'Multan',
    'Faisalabad',
    'Quetta',
    'Sialkot',
    'Gujranwala',
    'Bahawalpur',
    'Sargodha',
    'Sukkur',
    'Larkana',
    'Sheikhupura',
    'Jhang',
    'Rahim Yar Khan',
    'Gujrat',
    'Kasur',
    'Mardan',
  ];

  static const List<String> _tripNotes = [
    'Fragile items - handle with care',
    'Customer will be available after 2 PM',
    'Multiple stops required',
    'Express delivery',
    'Temperature sensitive cargo',
    'Heavy machinery transport',
    'Documents pickup',
    'Medical supplies delivery',
    'Electronics shipment',
    'Food delivery - keep refrigerated',
  ];

  List<Driver> generateMockDrivers() {
    final random = Random();
    final drivers = <Driver>[];

    for (int i = 0; i < _driverNames.length; i++) {
      final name = _driverNames[i];
      final licenseNumber = 'DL${1000 + i}${String.fromCharCode(65 + random.nextInt(26))}';

      DriverStatus status;
      if (i < 2) {
        status = DriverStatus.onTrip;
      } else if (i < 6) {
        status = DriverStatus.available;
      } else {
        status = DriverStatus.offline;
      }

      drivers.add(Driver(
        id: 'driver_$i',
        name: name,
        licenseNumber: licenseNumber,
        status: status,
        currentTripId: status == DriverStatus.onTrip ? 'trip_$i' : null,
      ));
    }

    return drivers;
  }

  List<Vehicle> generateMockVehicles() {
    final random = Random();
    final vehicles = <Vehicle>[];
    final vehicleTypes = VehicleType.values;

    for (int i = 0; i < _vehicleNames.length; i++) {
      final name = _vehicleNames[i];
      final type = vehicleTypes[i % vehicleTypes.length];
      final licensePlate = _generateLicensePlate(random);

      VehicleStatus status;
      if (i < 2) {
        status = VehicleStatus.assigned;
      } else if (i < 8) {
        status = VehicleStatus.available;
      } else {
        status = VehicleStatus.maintenance;
      }

      vehicles.add(Vehicle(
        id: 'vehicle_$i',
        name: name,
        type: type,
        status: status,
        licensePlate: licensePlate,
        currentTripId: status == VehicleStatus.assigned ? 'trip_$i' : null,
      ));
    }

    return vehicles;
  }

  List<Trip> generateMockTrips() {
    final random = Random();
    final trips = <Trip>[];
    final statuses = TripStatus.values;

    for (int i = 0; i < 15; i++) {
      final pickupLocation = _locations[random.nextInt(_locations.length)];
      String dropoffLocation;
      do {
        dropoffLocation = _locations[random.nextInt(_locations.length)];
      } while (dropoffLocation == pickupLocation);

      final status = statuses[i % statuses.length];
      final createdAt = DateTime.now().subtract(Duration(
        days: random.nextInt(30),
        hours: random.nextInt(24),
        minutes: random.nextInt(60),
      ));

      DateTime? updatedAt;
      if (status != TripStatus.pending) {
        updatedAt = createdAt.add(Duration(
          hours: random.nextInt(48),
          minutes: random.nextInt(60),
        ));
      }

      final notes = random.nextBool()
          ? _tripNotes[random.nextInt(_tripNotes.length)]
          : null;

      trips.add(Trip(
        id: 'trip_$i',
        driverId: 'driver_${i % _driverNames.length}',
        vehicleId: 'vehicle_${i % _vehicleNames.length}',
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        status: status,
        createdAt: createdAt,
        updatedAt: updatedAt,
        notes: notes,
      ));
    }

    trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return trips;
  }

  String _generateLicensePlate(Random random) {
    final formats = [
      '${_randomLetters(2, random)}-${_randomDigits(4, random)}',
      '${_randomLetters(3, random)}-${_randomDigits(3, random)}',
      '${_randomDigits(2, random)}-${_randomLetters(2, random)}-${_randomDigits(2, random)}',
    ];
    return formats[random.nextInt(formats.length)];
  }

  String _randomLetters(int count, Random random) {
    return String.fromCharCodes(
      List.generate(count, (_) => 65 + random.nextInt(26)),
    );
  }

  String _randomDigits(int count, Random random) {
    return String.fromCharCodes(
      List.generate(count, (_) => 48 + random.nextInt(10)),
    );
  }

  static List<String> get availableLocations => List.from(_locations);

  Future<List<Driver>> getDrivers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return generateMockDrivers();
  }

  Future<List<Vehicle>> getVehicles() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return generateMockVehicles();
  }

  Future<List<Trip>> getTrips() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return generateMockTrips();
  }

  Future<Driver?> getDriverById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final drivers = generateMockDrivers();
    try {
      return drivers.firstWhere((driver) => driver.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Vehicle?> getVehicleById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final vehicles = generateMockVehicles();
    try {
      return vehicles.firstWhere((vehicle) => vehicle.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Trip?> getTripById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final trips = generateMockTrips();
    try {
      return trips.firstWhere((trip) => trip.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Driver>> getAvailableDrivers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final drivers = generateMockDrivers();
    return drivers.where((driver) => driver.status == DriverStatus.available).toList();
  }

  Future<List<Vehicle>> getAvailableVehicles() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final vehicles = generateMockVehicles();
    return vehicles.where((vehicle) => vehicle.status == VehicleStatus.available).toList();
  }

  Future<bool> createTrip(Trip trip) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  Future<bool> updateTrip(Trip trip) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  Future<bool> deleteTrip(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> updateTripStatus(String tripId, TripStatus status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  Future<bool> updateDriverStatus(String driverId, DriverStatus status, {String? tripId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> updateVehicleStatus(String vehicleId, VehicleStatus status, {String? tripId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<Map<String, int>> getTripStatistics() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final trips = generateMockTrips();

    final stats = <String, int>{
      'total': trips.length,
      'pending': trips.where((trip) => trip.status == TripStatus.pending).length,
      'inProgress': trips.where((trip) => trip.status == TripStatus.inProgress).length,
      'completed': trips.where((trip) => trip.status == TripStatus.completed).length,
    };

    return stats;
  }

  Future<List<Trip>> searchTrips(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final trips = generateMockTrips();
    final drivers = generateMockDrivers();
    final vehicles = generateMockVehicles();

    if (query.isEmpty) return trips;

    final lowerQuery = query.toLowerCase();
    return trips.where((trip) {
      final driver = drivers.firstWhere((d) => d.id == trip.driverId);
      final vehicle = vehicles.firstWhere((v) => v.id == trip.vehicleId);

      return trip.id.toLowerCase().contains(lowerQuery) ||
          trip.pickupLocation.toLowerCase().contains(lowerQuery) ||
          trip.dropoffLocation.toLowerCase().contains(lowerQuery) ||
          driver.name.toLowerCase().contains(lowerQuery) ||
          vehicle.name.toLowerCase().contains(lowerQuery) ||
          trip.status.displayName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<List<Trip>> filterTripsByStatus(TripStatus? status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final trips = generateMockTrips();

    if (status == null) return trips;

    return trips.where((trip) => trip.status == status).toList();
  }
}