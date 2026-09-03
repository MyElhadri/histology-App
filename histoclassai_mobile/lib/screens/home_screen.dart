import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import 'login_screen.dart';
import 'scan_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Institutional Top Banner
            Container(
              margin: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/logo_faculte_medecine.png',
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    color: Colors.grey.shade300,
                  ),
                  Expanded(
                    child: Image.asset(
                      'assets/images/logo_labo_histologie.png',
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour, Étudiant',
                          style: theme.textTheme.displayMedium?.copyWith(fontSize: 24),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Prêt pour votre prochaine analyse ?',
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () async {
                          await auth.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: theme.colorScheme.errorContainer,
                          child: Icon(Icons.logout, color: theme.colorScheme.error, size: 20),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    // Scan Card
                    Card(
                      color: theme.colorScheme.primaryContainer,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ScanScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 32),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Nouvelle Analyse',
                                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Scanner une lame histologique pour lancer la classification via l\'IA.',
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // History Title
                    Text(
                      'Activité Récente',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    
                    // History Card
                    Card(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const HistoryScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.history_rounded, color: theme.colorScheme.primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Historique des scans',
                                      style: theme.textTheme.labelLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Voir vos analyses précédentes',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
