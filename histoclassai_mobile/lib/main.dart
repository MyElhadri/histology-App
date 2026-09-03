import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const HistoClassApp(),
    ),
  );
}

class HistoClassApp extends StatelessWidget {
  const HistoClassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HistoClass AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
