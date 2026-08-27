import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';

class QuizScreen extends StatefulWidget {
  final String scanId;
  final String tissuNom;
  final List<Question> questions;

  const QuizScreen({
    Key? key,
    required this.scanId,
    required this.tissuNom,
    required this.questions,
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Map<String, String> _selectedAnswers = {};
  bool _submitted = false;
  bool _isSubmitting = false;

  void _submitQuiz() async {
    if (_selectedAnswers.length < widget.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez répondre à toutes les questions.')),
      );
      return;
    }

    int score = 0;
    for (var q in widget.questions) {
      final selectedId = _selectedAnswers[q.id];
      final correctChoix = q.choix.where((c) => c.estCorrect).toList();
      if (correctChoix.isNotEmpty && selectedId == correctChoix.first.id) {
        score++;
      }
    }

    setState(() {
      _submitted = true;
      _isSubmitting = true;
    });

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        await ApiService.submitResultat(widget.scanId, score, token);
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'envoi du résultat: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('QCM - ${widget.tissuNom}')),
        body: const Center(child: Text('Aucun QCM disponible pour ce tissu.')),
      );
    }

    int score = 0;
    if (_submitted) {
      for (var q in widget.questions) {
        final selectedId = _selectedAnswers[q.id];
        final correctChoix = q.choix.where((c) => c.estCorrect).toList();
        if (correctChoix.isNotEmpty && selectedId == correctChoix.first.id) {
          score++;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('QCM d\'Évaluation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.tissuNom,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedAnswers.length}/${widget.questions.length}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LinearProgressIndicator(
                value: widget.questions.isEmpty ? 0 : _selectedAnswers.length / widget.questions.length,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  final q = widget.questions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${index + 1}',
                            style: theme.textTheme.labelMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            q.texte,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ...q.choix.map((choix) {
                            final isSelected = _selectedAnswers[q.id] == choix.id;
                            Color itemColor = Colors.transparent;
                            Color borderColor = theme.colorScheme.outline.withOpacity(0.3);
                            Color iconColor = theme.colorScheme.onSurfaceVariant;

                            if (isSelected) {
                              borderColor = theme.colorScheme.primary;
                              iconColor = theme.colorScheme.primary;
                              itemColor = theme.colorScheme.primary.withOpacity(0.05);
                            }

                            if (_submitted) {
                              if (choix.estCorrect) {
                                itemColor = theme.colorScheme.primary.withOpacity(0.1);
                                borderColor = theme.colorScheme.primary;
                              } else if (isSelected && !choix.estCorrect) {
                                itemColor = theme.colorScheme.error.withOpacity(0.1);
                                borderColor = theme.colorScheme.error;
                              }
                            }

                            return InkWell(
                              onTap: _submitted ? null : () {
                                setState(() {
                                  _selectedAnswers[q.id] = choix.id;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: itemColor,
                                  border: Border.all(
                                    color: borderColor,
                                    width: isSelected || (_submitted && choix.estCorrect) ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                      color: iconColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        choix.texte,
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (_submitted && choix.estCorrect)
                                      Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
                                    if (_submitted && isSelected && !choix.estCorrect)
                                      Icon(Icons.cancel, color: theme.colorScheme.error, size: 20),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Bottom Action Area
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: _submitted
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Score Final : $score / ${widget.questions.length}',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          child: const Text('Terminer et retourner à l\'accueil'),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitQuiz,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Soumettre le QCM'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
