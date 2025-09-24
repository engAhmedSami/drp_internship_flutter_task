import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trips_provider.dart';

import '../widgets/custom_app_bar.dart';
import '../widgets/driver_selector.dart';
import '../widgets/vehicle_selector.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class AssignTripScreen extends StatefulWidget {
  const AssignTripScreen({super.key});

  @override
  State<AssignTripScreen> createState() => _AssignTripScreenState();
}

class _AssignTripScreenState extends State<AssignTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedDriverId;
  String? _selectedVehicleId;
  bool _isLoading = false;

  String? _driverError;
  String? _vehicleError;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _assignTrip() async {
    setState(() {
      _driverError = null;
      _vehicleError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDriverId == null) {
      setState(() {
        _driverError = 'Please select a driver';
      });
      return;
    }

    if (_selectedVehicleId == null) {
      setState(() {
        _vehicleError = 'Please select a vehicle';
      });
      return;
    }

    final locationError = Validators.validateLocationsDifferent(
      _pickupController.text.trim(),
      _dropoffController.text.trim(),
    );
    if (locationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locationError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
      final success = await tripsProvider.createTrip(
        driverId: _selectedDriverId!,
        vehicleId: _selectedVehicleId!,
        pickupLocation: _pickupController.text.trim(),
        dropoffLocation: _dropoffController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.tripCreatedSuccess),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(); // Go back to trips list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create trip'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating trip: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _pickupController.clear();
    _dropoffController.clear();
    _notesController.clear();
    setState(() {
      _selectedDriverId = null;
      _selectedVehicleId = null;
      _driverError = null;
      _vehicleError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.assignTripTitle,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _resetForm,
            child: const Text(
              'Reset',
              style: TextStyle(color: AppColors.onPrimary),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildDriverVehicleSection(),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildLocationSection(),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildNotesSection(),
            const SizedBox(height: AppConstants.paddingLarge * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusLarge,
              ),
            ),
            child: const Icon(
              Icons.add_road,
              color: AppColors.onPrimary,
              size: AppConstants.iconSizeLarge,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Trip',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingXSmall),
                Text(
                  'Assign a driver and vehicle to a new delivery route',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: .9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverVehicleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assignment Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              children: [
                DriverSelector(
                  selectedDriverId: _selectedDriverId,
                  onDriverSelected: (driverId) {
                    setState(() {
                      _selectedDriverId = driverId;
                      _driverError = null;
                    });
                  },
                  errorText: _driverError,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                VehicleSelector(
                  selectedVehicleId: _selectedVehicleId,
                  onVehicleSelected: (vehicleId) {
                    setState(() {
                      _selectedVehicleId = vehicleId;
                      _vehicleError = null;
                    });
                  },
                  errorText: _vehicleError,
                  enabled: !_isLoading,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              children: [
                _buildLocationField(
                  controller: _pickupController,
                  label: AppStrings.pickupLocationLabel,
                  icon: Icons.trip_origin,
                  iconColor: AppColors.statusInProgress,
                  validator: Validators.validatePickupLocation,
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                _buildLocationField(
                  controller: _dropoffController,
                  label: AppStrings.dropoffLocationLabel,
                  icon: Icons.location_on,
                  iconColor: AppColors.statusCompleted,
                  validator: Validators.validateDropoffLocation,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        TextFormField(
          controller: controller,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            prefixIcon: Icon(icon, color: iconColor),
            suffixIcon: PopupMenuButton<String>(
              icon: Icon(Icons.location_city, color: AppColors.textSecondary),
              onSelected: (value) {
                controller.text = value;
              },
              itemBuilder: (context) => AppConstants.availableLocations
                  .map(
                    (location) =>
                        PopupMenuItem(value: location, child: Text(location)),
                  )
                  .toList(),
              tooltip: 'Select from common locations',
            ),
          ),
          validator: validator,
          textCapitalization: TextCapitalization.words,
          maxLength: AppConstants.maxLocationNameLength,
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.notesLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                TextFormField(
                  controller: _notesController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Add any special instructions or notes...',
                    prefixIcon: const Icon(
                      Icons.note,
                      color: AppColors.textSecondary,
                    ),
                    alignLabelWithHint: true,
                  ),
                  validator: Validators.validateNotes,
                  maxLines: 3,
                  maxLength: AppConstants.maxTripNotesLength,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: AppConstants.paddingMedium,
        right: AppConstants.paddingMedium,
        top: AppConstants.paddingMedium,
        bottom:
            AppConstants.paddingMedium + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              label: const Text(AppStrings.cancel),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingMedium,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _assignTrip,
              icon: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.onPrimary,
                        ),
                      ),
                    )
                  : const Icon(Icons.add_road),
              label: Text(_isLoading ? 'Creating...' : AppStrings.assignTrip),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
