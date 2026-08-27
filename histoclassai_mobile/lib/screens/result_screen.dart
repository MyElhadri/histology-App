import 'package:flutter/material.dart';
import '../models/prediction.dart';
import '../utils/constants.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatelessWidget {
  final PredictionResult result;

  const ResultScreen({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int score = (result.confiance * 100).round();
    final Color scoreColor = score >= 80 
        ? theme.colorScheme.primary 
        : (score >= 50 ? Colors.orange : theme.colorScheme.error);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat d\'Analyse'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo prise au microscope
              if (result.imageUrl.isNotEmpty) ...[
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.all(16),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            InteractiveViewer(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  AppConstants.resolveImageUrl(result.imageUrl),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 30),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 11,
                            child: Image.network(
                              AppConstants.resolveImageUrl(result.imageUrl),
                              fit: BoxFit.cover,
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorBuilder: (ctx, err, stack) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.zoom_in, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Agrandir',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Main Result Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_circle_outline_rounded, size: 64, color: scoreColor),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      result.nomTissu,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontSize: 28,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (result.descriptionTissu.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        result.descriptionTissu,
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.analytics_outlined, color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Score de confiance : $score%',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Associated Organs
              if (result.organes.isNotEmpty) ...[
                const SizedBox(height: 32),
                Text(
                  'Organes Associés',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: result.organes.map((organe) => Chip(
                    label: Text(organe.nom),
                    backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.1),
                    side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
                    labelStyle: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  )).toList(),
                ),
              ],

              const SizedBox(height: 48),

              // Action Button (QCM)
              if (result.questions.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(
                          scanId: result.scanId,
                          tissuNom: result.nomTissu,
                          questions: result.questions,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.school_outlined),
                  label: Text('Évaluer mes connaissances (${result.questions.length})'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Aucun QCM disponible pour ce tissu.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Retour à l\'accueil'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
