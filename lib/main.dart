import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/storage_service.dart';
import 'providers/app_state_provider.dart';
import 'views/auth/splash_screen.dart';
import 'views/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: const PropertyHubApp(),
    ),
  );
}

class PropertyHubApp extends StatelessWidget {
  const PropertyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, state, _) {
        return MaterialApp(
          title: 'Search',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: state.isLoggedIn
              ? const MainNavigationScreen()
              : const SplashScreen(),
        );
      },
    );
  }
}
