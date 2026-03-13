import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/data_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/router/app_router.dart';
import 'presentation/theme/app_theme.dart';
import 'data/services/mongodb_service.dart'; // Import MongoDbService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();

  // Configure and connect to MongoDB (Skip on web as mongo_dart is not supported)
  if (!kIsWeb) {
    try {
      MongoDbService.configure(
        'mongodb+srv://kartikeypandey1804_db_user:1ARE72m471H6xkhK@clusterservice.z9tgkbg.mongodb.net/?appName=ClusterService',
      );
      await MongoDbService.connect();
    } catch (e) {
      debugPrint('Error connecting to MongoDB: $e');
    }
  } else {
    debugPrint('Running on Web: Using Mock Data Service');
  }

  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(create: (_) => ThemeProvider()),
          provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
          provider.ChangeNotifierProvider(create: (_) => DataProvider()),
        ],
        child: const ServiceCenterApp(),
      ),
    ),
  );
}

class ServiceCenterApp extends StatelessWidget {
  const ServiceCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = provider.Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      title: 'Service Center Dashboard',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
