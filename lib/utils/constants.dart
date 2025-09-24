class AppConstants {
  static const String appName = 'Trips Manager';
  static const String appVersion = '1.0.0';

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  static const Duration searchDebounceDelay = Duration(milliseconds: 500);
  static const Duration refreshIndicatorDelay = Duration(seconds: 2);

  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;

  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double marginXSmall = 4.0;
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;
  static const double marginXLarge = 32.0;

  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  static const double cardElevation = 4.0;
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;

  static const double maxContentWidth = 1200.0;
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1024.0;

  static const int maxTripNotesLength = 500;
  static const int maxLocationNameLength = 100;
  static const int maxDriverNameLength = 50;
  static const int maxVehicleNameLength = 50;

  static const String defaultDateFormat = 'MMM dd, yyyy';
  static const String defaultTimeFormat = 'HH:mm';
  static const String defaultDateTimeFormat = 'MMM dd, yyyy HH:mm';

  static const List<String> availableLocations = [
    'New York',
    'London',
    'Paris',
    'Tokyo',
    'Dubai',
    'Rome',
    'Istanbul',
    'Bangkok',
    'Singapore',
    'Los Angeles',
    'Barcelona',
    'Sydney',
    'Moscow',
    'Toronto',
    'Hong Kong',
    'Berlin',
    'Amsterdam',
    'Cairo',
    'Beijing',
    'Rio de Janeiro',
  ];
}

class AppStrings {
  static const String tripsListTitle = 'Trips Management';
  static const String tripDetailsTitle = 'Trip Details';
  static const String assignTripTitle = 'Assign New Trip';

  static const String searchHint = 'Search trips...';
  static const String noTripsFound = 'No trips found';
  static const String noTripsMessage =
      'No trips available. Tap the + button to create your first trip.';

  static const String driverLabel = 'Driver';
  static const String vehicleLabel = 'Vehicle';
  static const String pickupLocationLabel = 'Pickup Location';
  static const String dropoffLocationLabel = 'Drop-off Location';
  static const String notesLabel = 'Notes (Optional)';
  static const String statusLabel = 'Status';
  static const String createdAtLabel = 'Created At';
  static const String updatedAtLabel = 'Updated At';

  static const String assignTrip = 'Assign Trip';
  static const String updateStatus = 'Update Status';
  static const String editTrip = 'Edit Trip';
  static const String deleteTrip = 'Delete Trip';

  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String confirm = 'Confirm';

  static const String requiredField = 'This field is required';
  static const String invalidSelection = 'Please make a valid selection';
  static const String maxLengthError = 'Maximum length exceeded';

  static const String deleteConfirmationTitle = 'Delete Trip';
  static const String deleteConfirmationMessage =
      'Are you sure you want to delete this trip? This action cannot be undone.';

  static const String statusUpdateConfirmationTitle = 'Update Status';
  static const String statusUpdateConfirmationMessage =
      'Are you sure you want to update the trip status?';

  static const String tripCreatedSuccess = 'Trip created successfully';
  static const String tripUpdatedSuccess = 'Trip updated successfully';
  static const String tripDeletedSuccess = 'Trip deleted successfully';

  static const String networkError = 'Network error occurred';
  static const String unexpectedError = 'An unexpected error occurred';
  static const String loadingError = 'Failed to load data';

  static const String pullToRefresh = 'Pull to refresh';
  static const String refreshing = 'Refreshing...';
  static const String loading = 'Loading...';

  static const String filterAll = 'All';
  static const String filterPending = 'Pending';
  static const String filterInProgress = 'In Progress';
  static const String filterCompleted = 'Completed';

  static const String route = 'Route';
  static const String routeArrow = ' → ';

  static const String noDriversAvailable = 'No drivers available';
  static const String noVehiclesAvailable = 'No vehicles available';
}
