import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../providers/vehicles_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class VehicleSelector extends StatefulWidget {
  final String? selectedVehicleId;
  final ValueChanged<String?> onVehicleSelected;
  final String? errorText;
  final bool enabled;

  const VehicleSelector({
    super.key,
    this.selectedVehicleId,
    required this.onVehicleSelected,
    this.errorText,
    this.enabled = true,
  });

  @override
  State<VehicleSelector> createState() => _VehicleSelectorState();
}

class _VehicleSelectorState extends State<VehicleSelector> {
  List<Vehicle> _availableVehicles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableVehicles();
  }

  Future<void> _loadAvailableVehicles() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final vehiclesProvider = Provider.of<VehiclesProvider>(
        context,
        listen: false,
      );
      final vehicles = await vehiclesProvider.getAvailableVehicles();
      if (mounted) {
        setState(() {
          _availableVehicles = vehicles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.vehicleLabel,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        _buildDropdown(),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            widget.errorText!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown() {
    if (_isLoading) {
      return _buildLoadingDropdown();
    }

    if (_availableVehicles.isEmpty) {
      return _buildEmptyDropdown();
    }

    final selectedVehicle = widget.selectedVehicleId != null
        ? _availableVehicles.firstWhere(
            (vehicle) => vehicle.id == widget.selectedVehicleId,
            orElse: () => _availableVehicles.first,
          )
        : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: widget.errorText != null ? AppColors.error : AppColors.border,
          width: widget.errorText != null ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showVehicleBottomSheet(context),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: selectedVehicle != null
                ? _buildSelectedVehicleDisplay(selectedVehicle)
                : _buildPlaceholderDisplay(),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedVehicleDisplay(Vehicle vehicle) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getVehicleTypeColor(vehicle.type),
                _getVehicleTypeColor(vehicle.type).withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _getVehicleTypeColor(
                  vehicle.type,
                ).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _getVehicleTypeIcon(vehicle.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vehicle.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.local_shipping,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${vehicle.type.displayName} • ${vehicle.licensePlate}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.statusCompleted.withValues(alpha: 0.15),
                AppColors.statusCompleted.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.statusCompleted.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.statusCompleted,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Available',
                style: const TextStyle(
                  color: AppColors.statusCompleted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.textSecondary,
          size: 24,
        ),
      ],
    );
  }

  Widget _buildPlaceholderDisplay() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: Icon(
            Icons.local_shipping,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Select a vehicle',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.textSecondary,
          size: 24,
        ),
      ],
    );
  }

  void _showVehicleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppGradients.secondaryGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Vehicle',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _availableVehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = _availableVehicles[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          widget.onVehicleSelected.call(vehicle.id);
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: _buildVehicleItem(vehicle),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleItem(Vehicle vehicle) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surfaceVariant.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getVehicleTypeColor(vehicle.type).withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getVehicleTypeColor(vehicle.type).withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getVehicleTypeColor(vehicle.type),
                  _getVehicleTypeColor(vehicle.type).withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: _getVehicleTypeColor(
                    vehicle.type,
                  ).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _getVehicleTypeIcon(vehicle.type),
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  vehicle.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: 10,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${vehicle.type.displayName} • ${vehicle.licensePlate}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.statusCompleted.withValues(alpha: 0.15),
                  AppColors.statusCompleted.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.statusCompleted.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.statusCompleted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  'Available',
                  style: const TextStyle(
                    color: AppColors.statusCompleted,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDropdown() {
    return Container(
      height: AppConstants.inputHeight,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping, color: AppColors.secondary),
          const SizedBox(width: AppConstants.paddingMedium),
          const Expanded(
            child: Text(
              'Loading vehicles...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDropdown() {
    return Container(
      height: AppConstants.inputHeight,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Row(
        children: [
          const Icon(Icons.no_transfer, color: AppColors.error),
          const SizedBox(width: AppConstants.paddingMedium),
          const Expanded(
            child: Text(
              AppStrings.noVehiclesAvailable,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          IconButton(
            onPressed: _loadAvailableVehicles,
            icon: const Icon(
              Icons.refresh,
              color: AppColors.secondary,
              size: AppConstants.iconSizeSmall,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Color _getVehicleTypeColor(VehicleType type) {
    switch (type) {
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

  IconData _getVehicleTypeIcon(VehicleType type) {
    switch (type) {
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

class VehicleListTile extends StatelessWidget {
  final Vehicle vehicle;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showStatus;

  const VehicleListTile({
    super.key,
    required this.vehicle,
    this.isSelected = false,
    this.onTap,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected
          ? AppConstants.elevationMedium
          : AppConstants.elevationSmall,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.marginMedium,
        vertical: AppConstants.marginSmall,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        side: BorderSide(
          color: isSelected ? AppColors.secondary : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getVehicleTypeColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          child: Icon(_getVehicleTypeIcon(), color: _getVehicleTypeColor()),
        ),
        title: Text(
          vehicle.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.secondary : AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${vehicle.type.displayName} • ${vehicle.licensePlate}'),
            if (showStatus)
              Text(
                vehicle.status.displayName,
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.secondary)
            : Icon(_getStatusIcon(), color: _getStatusColor()),
        isThreeLine: showStatus,
      ),
    );
  }

  Color _getVehicleTypeColor() {
    switch (vehicle.type) {
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
    switch (vehicle.type) {
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

  Color _getStatusColor() {
    switch (vehicle.status) {
      case VehicleStatus.available:
        return AppColors.statusCompleted;
      case VehicleStatus.assigned:
        return AppColors.statusInProgress;
      case VehicleStatus.maintenance:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon() {
    switch (vehicle.status) {
      case VehicleStatus.available:
        return Icons.check_circle;
      case VehicleStatus.assigned:
        return Icons.assignment;
      case VehicleStatus.maintenance:
        return Icons.build;
    }
  }
}
