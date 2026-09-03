import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Vérification de la session en arrière-plan pendant l'animation
    final checkAuthFuture = authProvider.checkAuthStatus();
    final delayFuture = Future.delayed(const Duration(milliseconds: 2200));

    await Future.wait([checkAuthFuture, delayFuture]);

    if (!mounted) return;

    final targetScreen = authProvider.isAuthenticated 
        ? const HomeScreen() 
        : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo rond officiel avec ombre portée douce
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F3B66).withValues(alpha: 0.14),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/app_logo_round.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Titre de la plateforme
                Text(
                  'HistoClass AI',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: const Color(0xFF0F3B66),
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    fontSize: 28,
                  ),
                ),

                const SizedBox(height: 8),

                // Sous-titre académique
                Text(
                  'Laboratoire d\'Histologie',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFEA8E00),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Faculté de Médecine et de Pharmacie • Tanger',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                const Spacer(flex: 2),

                // Indicateur de chargement discret et élégant
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F3B66)),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Initialisation...',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
