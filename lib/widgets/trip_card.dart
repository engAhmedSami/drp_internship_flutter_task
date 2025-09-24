import 'package:drp_internship_flutter_task/models/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../providers/drivers_provider.dart';
import '../providers/vehicles_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import 'status_badge.dart';

class TripCard extends StatefulWidget {
  final Trip trip;
  final VoidCallback? onTap;
  final VoidCallback? onStatusUpdate;
  final VoidCallback? onDelete;
  final bool showActions;

  const TripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.onStatusUpdate,
    this.onDelete,
    this.showActions = false,
  });

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 5, end: 20).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppGradients.cardGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: _elevationAnimation.value,
                  offset: Offset(0, _elevationAnimation.value / 4),
                  spreadRadius: 0,
                ),
                if (_isHovered)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
              ],
              border: Border.all(
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.divider.withValues(alpha: 0.3),
                width: _isHovered ? 1.5 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                onHover: (hovered) {
                  setState(() {
                    _isHovered = hovered;
                  });
                  if (hovered) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 12),
                      _buildDriverVehicleInfo(context),
                      const SizedBox(height: 12),
                      _buildRouteInfo(context),
                      if (widget.trip.notes != null &&
                          widget.trip.notes!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _buildNotesSection(context),
                      ],
                      const SizedBox(height: 10),
                      _buildFooter(context),
                      if (widget.showActions) ...[
                        const SizedBox(height: 12),
                        _buildActionButtons(context),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip #${widget.trip.id.length >= 8 ? widget.trip.id.substring(widget.trip.id.length - 8).toUpperCase() : widget.trip.id.toUpperCase()}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingXSmall),
              Text(
                'Created ${DateFormat(AppConstants.defaultDateTimeFormat).format(widget.trip.createdAt)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        AnimatedStatusBadge(status: widget.trip.status, showIcon: true),
      ],
    );
  }

  Widget _buildDriverVehicleInfo(BuildContext context) {
    return Consumer2<DriversProvider, VehiclesProvider>(
      builder: (context, driversProvider, vehiclesProvider, child) {
        final driver = driversProvider.getDriverById(widget.trip.driverId);
        final vehicle = vehiclesProvider.getVehicleById(widget.trip.vehicleId);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.person,
                  title: 'Driver',
                  subtitle: driver?.name ?? 'Unknown Driver',
                  iconColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.local_shipping,
                  title: 'Vehicle',
                  subtitle: vehicle != null
                      ? '${vehicle.name} - ${vehicle.type.displayName}'
                      : 'Unknown Vehicle',
                  iconColor: AppColors.secondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceVariant.withValues(alpha: 0.8),
            AppColors.surface.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.statusInProgressLight.withValues(alpha: 0.4),
            AppColors.statusInProgressLight.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.statusInProgress.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppGradients.statusInProgressGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.route, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                'Route',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.trip.pickupLocation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                TextSpan(
                  text: '  →  ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.statusInProgress,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: widget.trip.dropoffLocation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note,
                color: AppColors.textSecondary,
                size: AppConstants.iconSizeSmall,
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingXSmall),
          Text(
            widget.trip.notes!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.trip.updatedAt != null)
          Row(
            children: [
              Icon(
                Icons.update,
                color: AppColors.textHint,
                size: AppConstants.iconSizeSmall,
              ),
              const SizedBox(width: AppConstants.paddingXSmall),
              Text(
                'Updated ${DateFormat(AppConstants.defaultDateTimeFormat).format(widget.trip.updatedAt!)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
              ),
            ],
          )
        else
          const SizedBox.shrink(),
        if (widget.onTap != null)
          Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textHint,
            size: AppConstants.iconSizeSmall,
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceVariant.withValues(alpha: 0.5),
            AppColors.surface.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (widget.onStatusUpdate != null &&
              widget.trip.status != TripStatus.completed) ...[
            Expanded(
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onStatusUpdate,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.update,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Update',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (widget.onDelete != null) ...[
            Expanded(
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.error, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onDelete,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete, color: AppColors.error, size: 14),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Delete',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
