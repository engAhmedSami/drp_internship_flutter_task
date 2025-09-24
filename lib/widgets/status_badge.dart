import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class StatusBadge extends StatelessWidget {
  final TripStatus status;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final bool showIcon;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize,
    this.padding,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: _getGradient(),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIcon(),
                color: Colors.white,
                size: (fontSize ?? 12) + 2,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            status.displayName,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (status) {
      case TripStatus.pending:
        return Icons.schedule;
      case TripStatus.inProgress:
        return Icons.local_shipping;
      case TripStatus.completed:
        return Icons.check_circle;
    }
  }

  LinearGradient _getGradient() {
    switch (status) {
      case TripStatus.pending:
        return AppGradients.statusPendingGradient;
      case TripStatus.inProgress:
        return AppGradients.statusInProgressGradient;
      case TripStatus.completed:
        return AppGradients.statusCompletedGradient;
    }
  }
}

class AnimatedStatusBadge extends StatefulWidget {
  final TripStatus status;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final bool showIcon;
  final Duration animationDuration;

  const AnimatedStatusBadge({
    super.key,
    required this.status,
    this.fontSize,
    this.padding,
    this.showIcon = false,
    this.animationDuration = AppConstants.animationDuration,
  });

  @override
  State<AnimatedStatusBadge> createState() => _AnimatedStatusBadgeState();
}

class _AnimatedStatusBadgeState extends State<AnimatedStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _animationController.reset();
      _animationController.forward();
    }
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
          child: StatusBadge(
            status: widget.status,
            fontSize: widget.fontSize,
            padding: widget.padding,
            showIcon: widget.showIcon,
          ),
        );
      },
    );
  }
}

class StatusFilterChip extends StatelessWidget {
  final TripStatus? status;
  final bool isSelected;
  final VoidCallback onTap;
  final String? label;

  const StatusFilterChip({
    super.key,
    this.status,
    required this.isSelected,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final displayLabel = label ?? (status?.displayName ?? 'All');

    return FilterChip(
      label: Text(displayLabel),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.transparent,
      selectedColor: _getSelectedColor(),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : _getTextColor(),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(color: _getBorderColor(), width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
    );
  }

  Color _getSelectedColor() {
    if (status == null) return AppColors.primary;
    switch (status!) {
      case TripStatus.pending:
        return AppColors.statusPending;
      case TripStatus.inProgress:
        return AppColors.statusInProgress;
      case TripStatus.completed:
        return AppColors.statusCompleted;
    }
  }

  Color _getBorderColor() {
    if (status == null) return AppColors.primary;
    return _getSelectedColor();
  }

  Color _getTextColor() {
    if (status == null) return AppColors.primary;
    return _getSelectedColor();
  }
}
