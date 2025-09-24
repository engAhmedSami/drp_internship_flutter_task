import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/trips_provider.dart';
import 'providers/drivers_provider.dart';
import 'providers/vehicles_provider.dart';
import 'screens/trips_list_screen.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

void main() {
  runApp(const TripsManagerApp());
}

// Fixed tab bar and modern UI update

class TripsManagerApp extends StatelessWidget {
  const TripsManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripsProvider()),
        ChangeNotifierProvider(create: (_) => DriversProvider()),
        ChangeNotifierProvider(create: (_) => VehiclesProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        home: const TripsListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
