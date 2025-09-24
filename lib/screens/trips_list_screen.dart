import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../providers/trips_provider.dart';
import '../providers/drivers_provider.dart';
import '../providers/vehicles_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/trip_card.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import 'trip_details_screen.dart';
import 'assign_trip_screen.dart';

class TripsListScreen extends StatefulWidget {
  const TripsListScreen({super.key});

  @override
  State<TripsListScreen> createState() => _TripsListScreenState();
}

class _TripsListScreenState extends State<TripsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  TripStatus? _currentFilter;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;

    setState(() {
      switch (_tabController.index) {
        case 0:
          _currentFilter = null;
          break;
        case 1:
          _currentFilter = TripStatus.pending;
          break;
        case 2:
          _currentFilter = TripStatus.inProgress;
          break;
        case 3:
          _currentFilter = TripStatus.completed;
          break;
      }
    });

    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    tripsProvider.filterByStatus(_currentFilter);
  }

  Future<void> _loadData() async {
    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    final driversProvider = Provider.of<DriversProvider>(
      context,
      listen: false,
    );
    final vehiclesProvider = Provider.of<VehiclesProvider>(
      context,
      listen: false,
    );

    // Set providers for enhanced search functionality
    tripsProvider.setProviders(driversProvider, vehiclesProvider);

    await Future.wait([
      tripsProvider.loadTrips(),
      driversProvider.loadDrivers(),
      vehiclesProvider.loadVehicles(),
    ]);
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    tripsProvider.searchTrips(query);
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      isSearching = false;
    });
    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    tripsProvider.searchTrips('');
  }

  void _navigateToTripDetails(Trip trip) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TripDetailsScreen(tripId: trip.id),
      ),
    );
  }

  void _navigateToAssignTrip() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AssignTripScreen()));
  }

  void _showStatusUpdateDialog(Trip trip) {
    if (trip.status == TripStatus.completed) return;

    final nextStatus = trip.status == TripStatus.pending
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
              _updateTripStatus(trip.id, nextStatus);
            },
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Trip trip) {
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
              _deleteTrip(trip.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTripStatus(String tripId, TripStatus newStatus) async {
    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    final success = await tripsProvider.updateTripStatus(tripId, newStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? AppStrings.tripUpdatedSuccess
                : 'Failed to update trip status',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteTrip(String tripId) async {
    final tripsProvider = Provider.of<TripsProvider>(context, listen: false);
    final success = await tripsProvider.deleteTrip(tripId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? AppStrings.tripDeletedSuccess : 'Failed to delete trip',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        title: AppStrings.tripsListTitle,
        searchHint: AppStrings.searchHint,
        onSearchChanged: _onSearchChanged,
        onSearchClear: _clearSearch,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppGradients.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A6366F1),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    _buildModernTab('All', null),
                    _buildModernTab('Pending', TripStatus.pending),
                    _buildModernTab('In Progress', TripStatus.inProgress),
                    _buildModernTab('Completed', TripStatus.completed),
                  ],
                  isScrollable: false,
                  dividerColor: Colors.transparent,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),

                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
            Expanded(
              child: Consumer<TripsProvider>(
                builder: (context, tripsProvider, child) {
                  if (tripsProvider.isLoading && !tripsProvider.hasTrips) {
                    return _buildLoadingView();
                  }

                  if (tripsProvider.error != null && !tripsProvider.hasTrips) {
                    return _buildErrorView(tripsProvider.error!);
                  }

                  if (!tripsProvider.hasFilteredTrips) {
                    return _buildEmptyView();
                  }

                  return _buildTripsView(tripsProvider);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAssignTrip,
        icon: const Icon(Icons.add),
        label: const Text('Assign Trip'),
      ),
    );
  }

  Widget _buildModernTab(String label, TripStatus? status) {
    return Consumer<TripsProvider>(
      builder: (context, tripsProvider, child) {
        int count;
        if (status == null) {
          count = tripsProvider.totalTrips;
        } else {
          count = tripsProvider.getTripsByStatus(status).length;
        }

        final isSelected =
            _tabController.index ==
            (status == null
                ? 0
                : status == TripStatus.pending
                ? 1
                : status == TripStatus.inProgress
                ? 2
                : 3);

        // Shorter labels to prevent overflow
        String displayLabel = label;
        if (label == 'In Progress') {
          displayLabel = 'Active';
        } else if (label == 'Completed') {
          displayLabel = 'Done';
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  displayLabel,
                  style: TextStyle(
                    fontSize: isSelected ? 12 : 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    letterSpacing: 0.3,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected
                          ? [
                              Colors.white.withValues(alpha: 0.9),
                              Colors.white.withValues(alpha: 0.8),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.25),
                              Colors.white.withValues(alpha: 0.15),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.15),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
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

  Widget _buildErrorView(String error) {
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
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.local_shipping_outlined,
              size: AppConstants.iconSizeXLarge * 2,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            Text(
              _searchQuery.isNotEmpty
                  ? AppStrings.noTripsFound
                  : 'No trips yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search criteria'
                  : AppStrings.noTripsMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textHint),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: AppConstants.paddingLarge),
              ElevatedButton.icon(
                onPressed: _navigateToAssignTrip,
                icon: const Icon(Icons.add),
                label: const Text('Create First Trip'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTripsView(TripsProvider tripsProvider) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: AppConstants.paddingSmall,
          bottom: AppConstants.paddingLarge * 3,
        ),
        itemCount: tripsProvider.trips.length,
        itemBuilder: (context, index) {
          final trip = tripsProvider.trips[index];
          return TripCard(
            trip: trip,
            onTap: () => _navigateToTripDetails(trip),
            onStatusUpdate: () => _showStatusUpdateDialog(trip),
            onDelete: () => _showDeleteDialog(trip),
            showActions: true,
          );
        },
      ),
    );
  }
}
