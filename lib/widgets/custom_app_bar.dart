import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: foregroundColor ?? AppColors.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? AppColors.onPrimary,
      elevation: elevation ?? AppConstants.elevationMedium,
      leading:
          leading ??
          (showBackButton && Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                )
              : null),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClear;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const SearchAppBar({
    super.key,
    required this.title,
    this.searchHint = 'Search...',
    this.onSearchChanged,
    this.onSearchClear,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar>
    with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  late TextEditingController _searchController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _animationController = AnimationController(
      duration: AppConstants.animationDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
    _animationController.forward();
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
    });
    _animationController.reverse();
    _searchController.clear();
    widget.onSearchClear?.call();
  }

  void _onSearchChanged(String value) {
    widget.onSearchChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
      ),
      child: AppBar(
        title: AnimatedSwitcher(
          duration: AppConstants.animationDuration,
          child: _isSearching ? _buildSearchField() : _buildTitle(),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: widget.foregroundColor ?? AppColors.onPrimary,
        elevation: widget.elevation ?? 0,
        centerTitle: true,
        leading: widget.showBackButton && Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed:
                    widget.onBackPressed ?? () => Navigator.of(context).pop(),
              )
            : null,
        actions: _buildActions(),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.title,
      key: const ValueKey('title'),
      style: TextStyle(
        color: widget.foregroundColor ?? AppColors.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        key: const ValueKey('search'),
        controller: _searchController,
        onChanged: _onSearchChanged,
        autofocus: true,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.searchHint,
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    List<Widget> actions = [];

    if (_isSearching) {
      actions.add(
        Container(
          margin: const EdgeInsets.only(right: 4),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close, size: 18),
            ),
            onPressed: _stopSearch,
          ),
        ),
      );
    } else {
      actions.add(
        Container(
          margin: const EdgeInsets.only(right: 4),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.search, size: 18),
            ),
            onPressed: _startSearch,
          ),
        ),
      );
    }

    if (widget.actions != null) {
      for (final action in widget.actions!) {
        if (action is IconButton) {
          actions.add(
            Container(
              margin: const EdgeInsets.only(right: 4),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: action.icon,
                ),
                onPressed: action.onPressed,
              ),
            ),
          );
        } else {
          actions.add(action);
        }
      }
    }

    return actions;
  }
}

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Gradient? gradient;
  final double? elevation;
  final PreferredSizeWidget? bottom;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.gradient,
    this.elevation,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            gradient ??
            const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      ),
      child: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.onPrimary,
        elevation: elevation ?? 0,
        leading:
            leading ??
            (showBackButton && Navigator.of(context).canPop()
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed:
                        onBackPressed ?? () => Navigator.of(context).pop(),
                  )
                : null),
        actions: actions,
        bottom: bottom,
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

class CollapsibleAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? background;
  final List<Widget>? actions;
  final bool pinned;
  final bool floating;
  final double expandedHeight;
  final Widget body;

  const CollapsibleAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.background,
    this.actions,
    this.pinned = true,
    this.floating = false,
    this.expandedHeight = 200.0,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(title),
          actions: actions,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          pinned: pinned,
          floating: floating,
          expandedHeight: expandedHeight,
          flexibleSpace: FlexibleSpaceBar(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
            background:
                background ??
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
          ),
        ),
        SliverToBoxAdapter(child: body),
      ],
    );
  }
}
