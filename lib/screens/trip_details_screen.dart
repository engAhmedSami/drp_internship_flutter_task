import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';
import '../models/driver.dart';
import '../models/vehicle.dart';
import '../providers/trips_provider.dart';
import '../providers/drivers_provider.dart';
import '../providers/vehicles_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/status_badge.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class TripDetailsScreen extends StatefulWidget {
  final String tripId;

  const TripDetailsScreen({super.key, required this.tripId});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  Trip? _trip;
  Driver? _driver;
  Vehicle? _vehicle;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTripDetails();
  }

  Future<void> _loadTripDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
      final driversProvider = Provider.of<DriversProvider>(
        context,
        listen: false,
      );
      final vehiclesProvider = Provider.of<VehiclesProvider>(
        context,
        listen: false,
      );

      final trip = await tripsProvider.getTripById(widget.tripId);
      if (trip == null) {
        setState(() {
          _error = 'Trip not found';
          _isLoading = false;
        });
        return;
      }

      final driver = driversProvider.getDriverById(trip.driverId);
      final vehicle = vehiclesProvider.getVehicleById(trip.vehicleId);

      setState(() {
        _trip = trip;
        _driver = driver;
        _vehicle = vehicle;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load trip details: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateTripStatus(TripStatus newStatus) async {
    if (_trip == null) return;

    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    final success = await tripsProvider.updateTripStatus(_trip!.id, newStatus);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.tripUpdatedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        _loadTripDetails(); // Refresh the data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update trip status'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showStatusUpdateDialog() {
    if (_trip == null || _trip!.status == TripStatus.completed) return;

    final nextStatus = _trip!.status == TripStatus.pending
        ? TripStatus.inProgress
        : TripStatus.completed;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.statusUpdateConfirmationTitle),
        content: Text('Update trip status to ${nextStatus.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateTripStatus(nextStatus);
            },
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    if (_trip == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteConfirmationTitle),
        content: const Text(AppStrings.deleteConfirmationMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteTrip();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTrip() async {
    if (_trip == null) return;

    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    final success = await tripsProvider.deleteTrip(_trip!.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.tripDeletedSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(); // Go back to trips list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete trip'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.tripDetailsTitle,
        actions: [
          if (_trip != null && _trip!.status != TripStatus.completed)
            IconButton(
              icon: const Icon(Icons.update),
              onPressed: _showStatusUpdateDialog,
              tooltip: AppStrings.updateStatus,
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error),
                    SizedBox(width: AppConstants.paddingSmall),
                    Text('Delete Trip'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_error != null) {
      return _buildErrorView();
    }

    if (_trip == null) {
      return _buildNotFoundView();
    }

    return _buildDetailsView();
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppConstants.paddingMedium),
          Text(
            AppStrings.loading,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppConstants.iconSizeXLarge,
              color: AppColors.error,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton.icon(
              onPressed: _loadTripDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: AppConstants.iconSizeXLarge,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Trip Not Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            const Text(
              'The requested trip could not be found.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textHint),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTripHeader(),
          const SizedBox(height: AppConstants.paddingLarge),
          _buildRouteSection(),
          const SizedBox(height: AppConstants.paddingLarge),
          _buildDriverSection(),
          const SizedBox(height: AppConstants.paddingLarge),
          _buildVehicleSection(),
          if (_trip!.notes != null && _trip!.notes!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingLarge),
            _buildNotesSection(),
          ],
          const SizedBox(height: AppConstants.paddingLarge),
          _buildTimestampSection(),
          if (_trip!.status != TripStatus.completed) ...[
            const SizedBox(height: AppConstants.paddingLarge * 2),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildTripHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trip #${_trip!.id.length >= 8 ? _trip!.id.substring(_trip!.id.length - 8).toUpperCase() : _trip!.id.toUpperCase()}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        'Created ${DateFormat(AppConstants.defaultDateTimeFormat).format(_trip!.createdAt)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedStatusBadge(
                  status: _trip!.status,
                  showIcon: true,
                  fontSize: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSection() {
    return _buildSection(
      title: AppStrings.route,
      icon: Icons.location_on,
      iconColor: AppColors.statusInProgress,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.statusInProgressLight.withValues(alpha: .3),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          border: Border.all(
            color: AppColors.statusInProgress.withValues(alpha: .3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              'From',
              _trip!.pickupLocation,
              Icons.trip_origin,
              AppColors.statusInProgress,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            _buildInfoRow(
              'To',
              _trip!.dropoffLocation,
              Icons.location_on,
              AppColors.statusCompleted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverSection() {
    return _buildSection(
      title: AppStrings.driverLabel,
      icon: Icons.person,
      iconColor: AppColors.primary,
      child: _driver != null
          ? _buildDriverInfo()
          : _buildNotFoundInfo('Driver information not available'),
    );
  }

  Widget _buildDriverInfo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: .1),
                child: Text(
                  _driver!.name.isNotEmpty ? _driver!.name.substring(0, 1).toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _driver!.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'License: ${_driver!.licenseNumber}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: _getDriverStatusColor().withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusLarge,
                  ),
                ),
                child: Text(
                  _driver!.status.displayName,
                  style: TextStyle(
                    color: _getDriverStatusColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSection() {
    return _buildSection(
      title: AppStrings.vehicleLabel,
      icon: Icons.local_shipping,
      iconColor: AppColors.secondary,
      child: _vehicle != null
          ? _buildVehicleInfo()
          : _buildNotFoundInfo('Vehicle information not available'),
    );
  }

  Widget _buildVehicleInfo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getVehicleTypeColor().withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                ),
                child: Icon(
                  _getVehicleTypeIcon(),
                  color: _getVehicleTypeColor(),
                  size: AppConstants.iconSizeLarge,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _vehicle!.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _vehicle!.type.displayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Plate: ${_vehicle!.licensePlate}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: _getVehicleStatusColor().withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusLarge,
                  ),
                ),
                child: Text(
                  _vehicle!.status.displayName,
                  style: TextStyle(
                    color: _getVehicleStatusColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildSection(
      title: AppStrings.notesLabel,
      icon: Icons.note,
      iconColor: AppColors.textSecondary,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        child: Text(
          _trip!.notes!,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildTimestampSection() {
    return _buildSection(
      title: 'Timeline',
      icon: Icons.access_time,
      iconColor: AppColors.textSecondary,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        ),
        child: Column(
          children: [
            _buildInfoRow(
              AppStrings.createdAtLabel,
              DateFormat(
                AppConstants.defaultDateTimeFormat,
              ).format(_trip!.createdAt),
              Icons.add_circle_outline,
              AppColors.statusPending,
            ),
            if (_trip!.updatedAt != null) ...[
              const SizedBox(height: AppConstants.paddingMedium),
              _buildInfoRow(
                AppStrings.updatedAtLabel,
                DateFormat(
                  AppConstants.defaultDateTimeFormat,
                ).format(_trip!.updatedAt!),
                Icons.update,
                AppColors.statusInProgress,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: AppConstants.iconSizeMedium),
            const SizedBox(width: AppConstants.paddingSmall),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        child,
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: AppConstants.iconSizeSmall),
        const SizedBox(width: AppConstants.paddingSmall),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotFoundInfo(String message) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: AppConstants.iconSizeMedium,
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showDeleteDialog,
            icon: const Icon(Icons.delete),
            label: const Text('Delete Trip'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.paddingMedium),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showStatusUpdateDialog,
            icon: const Icon(Icons.update),
            label: const Text('Update Status'),
          ),
        ),
      ],
    );
  }

  Color _getDriverStatusColor() {
    if (_driver == null) return AppColors.textSecondary;
    switch (_driver!.status) {
      case DriverStatus.available:
        return AppColors.statusCompleted;
      case DriverStatus.onTrip:
        return AppColors.statusInProgress;
      case DriverStatus.offline:
        return AppColors.textSecondary;
    }
  }

  Color _getVehicleStatusColor() {
    if (_vehicle == null) return AppColors.textSecondary;
    switch (_vehicle!.status) {
      case VehicleStatus.available:
        return AppColors.statusCompleted;
      case VehicleStatus.assigned:
        return AppColors.statusInProgress;
      case VehicleStatus.maintenance:
        return AppColors.error;
    }
  }

  Color _getVehicleTypeColor() {
    if (_vehicle == null) return AppColors.textSecondary;
    switch (_vehicle!.type) {
      case VehicleType.truck:
        return AppColors.warning;
      case VehicleType.van:
        return AppColors.info;
      case VehicleType.bike:
        return AppColors.success;
      case VehicleType.car:
        return AppColors.secondary;
    }
  }

  IconData _getVehicleTypeIcon() {
    if (_vehicle == null) return Icons.help;
    switch (_vehicle!.type) {
      case VehicleType.truck:
        return Icons.local_shipping;
      case VehicleType.van:
        return Icons.airport_shuttle;
      case VehicleType.bike:
        return Icons.two_wheeler;
      case VehicleType.car:
        return Icons.directions_car;
    }
  }
}
