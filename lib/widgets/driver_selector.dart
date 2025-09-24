import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/driver.dart';
import '../providers/drivers_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class DriverSelector extends StatefulWidget {
  final String? selectedDriverId;
  final ValueChanged<String?> onDriverSelected;
  final String? errorText;
  final bool enabled;

  const DriverSelector({
    super.key,
    this.selectedDriverId,
    required this.onDriverSelected,
    this.errorText,
    this.enabled = true,
  });

  @override
  State<DriverSelector> createState() => _DriverSelectorState();
}

class _DriverSelectorState extends State<DriverSelector> {
  List<Driver> _availableDrivers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableDrivers();
  }

  Future<void> _loadAvailableDrivers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final driversProvider = Provider.of<DriversProvider>(
        context,
        listen: false,
      );
      final drivers = await driversProvider.getAvailableDrivers();
      if (mounted) {
        setState(() {
          _availableDrivers = drivers;
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
          AppStrings.driverLabel,
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

    if (_availableDrivers.isEmpty) {
      return _buildEmptyDropdown();
    }

    final selectedDriver = widget.selectedDriverId != null
        ? _availableDrivers.firstWhere(
            (driver) => driver.id == widget.selectedDriverId,
            orElse: () => _availableDrivers.first,
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
          onTap: () => _showDriverBottomSheet(context),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: selectedDriver != null
                ? _buildSelectedDriverDisplay(selectedDriver)
                : _buildPlaceholderDisplay(),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDriverDisplay(Driver driver) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              driver.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                driver.name,
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
                    Icons.credit_card,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      driver.licenseNumber,
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
          child: Icon(Icons.person, color: AppColors.textSecondary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Select a driver',
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

  void _showDriverBottomSheet(BuildContext context) {
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
                gradient: AppGradients.primaryGradient,
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
                    'Select Driver',
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
                itemCount: _availableDrivers.length,
                itemBuilder: (context, index) {
                  final driver = _availableDrivers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          widget.onDriverSelected.call(driver.id);
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: _buildDriverItem(driver),
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

  Widget _buildDriverItem(Driver driver) {
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
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
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
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                driver.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  driver.name,
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
                      Icons.credit_card,
                      size: 10,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        driver.licenseNumber,
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
          const Icon(Icons.person, color: AppColors.primary),
          const SizedBox(width: AppConstants.paddingMedium),
          const Expanded(
            child: Text(
              'Loading drivers...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
          const Icon(Icons.person_off, color: AppColors.error),
          const SizedBox(width: AppConstants.paddingMedium),
          const Expanded(
            child: Text(
              AppStrings.noDriversAvailable,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          IconButton(
            onPressed: _loadAvailableDrivers,
            icon: const Icon(
              Icons.refresh,
              color: AppColors.primary,
              size: AppConstants.iconSizeSmall,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class DriverListTile extends StatelessWidget {
  final Driver driver;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showStatus;

  const DriverListTile({
    super.key,
    required this.driver,
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
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _getStatusColor().withValues(alpha: .1),
          child: Text(
            driver.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: _getStatusColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          driver.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('License: ${driver.licenseNumber}'),
            if (showStatus)
              Text(
                driver.status.displayName,
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColors.primary)
            : Icon(_getStatusIcon(), color: _getStatusColor()),
        isThreeLine: showStatus,
      ),
    );
  }

  Color _getStatusColor() {
    switch (driver.status) {
      case DriverStatus.available:
        return AppColors.statusCompleted;
      case DriverStatus.onTrip:
        return AppColors.statusInProgress;
      case DriverStatus.offline:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    switch (driver.status) {
      case DriverStatus.available:
        return Icons.check_circle;
      case DriverStatus.onTrip:
        return Icons.local_shipping;
      case DriverStatus.offline:
        return Icons.offline_bolt;
    }
  }
}
