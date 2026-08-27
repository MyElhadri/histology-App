import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prediction.dart';
import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../utils/constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanHistoryItem> _scans = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) throw Exception("Non authentifié");

      final scans = await ApiService.getMyScans(token);
      if (mounted) {
        setState(() {
          _scans = scans;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl, String tissuNom) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InteractiveViewer(
                    child: Image.network(
                      AppConstants.resolveImageUrl(imageUrl),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Text('Image indisponible', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tissuNom,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Scans'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Erreur de chargement', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadHistory();
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_scans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: theme.colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Aucun scan effectué',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Vos analyses histologiques apparaîtront ici.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        await _loadHistory();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _scans.length,
        itemBuilder: (context, index) {
          final scan = _scans[index];
          final int confidence = (scan.scoreConfiance * 100).round();
          final Color confColor = confidence >= 80
              ? const Color(0xFF10B981)
              : (confidence >= 50 ? Colors.orange : theme.colorScheme.error);

          final resolvedImageUrl = AppConstants.resolveImageUrl(scan.urlImage);

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.04),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Photo miniature du scan avec zoom au tap
                  GestureDetector(
                    onTap: resolvedImageUrl.isNotEmpty
                        ? () => _showImageDialog(context, scan.urlImage, scan.tissuNom)
                        : null,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200, width: 1.5),
                        color: Colors.grey.shade100,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: resolvedImageUrl.isNotEmpty
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    resolvedImageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (ctx, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, __, ___) => Container(
                                      color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                                      child: Icon(Icons.biotech_rounded, color: theme.colorScheme.primary, size: 30),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.55),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.search, size: 12, color: Colors.white),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                                child: Icon(Icons.biotech_rounded, color: theme.colorScheme.primary, size: 30),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Infos du scan et du QCM
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom du tissu
                        Text(
                          scan.tissuNom,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Date du scan
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 14, color: theme.colorScheme.outline),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(scan.dateScan),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Statut & Score du QCM
                        if (scan.noteQcm != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: scan.noteQcm! >= 2
                                  ? const Color(0xFFDCFCE7)
                                  : (scan.noteQcm! == 1 ? const Color(0xFFFEF3C7) : const Color(0xFFFEE2E2)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  scan.noteQcm! >= 2
                                      ? Icons.check_circle_rounded
                                      : (scan.noteQcm! == 1 ? Icons.info_rounded : Icons.cancel_rounded),
                                  size: 14,
                                  color: scan.noteQcm! >= 2
                                      ? const Color(0xFF15803D)
                                      : (scan.noteQcm! == 1 ? const Color(0xFFB45309) : const Color(0xFFB91C1C)),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Score QCM : ${scan.noteQcm} / ${scan.totalQuestionsQcm ?? 3}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: scan.noteQcm! >= 2
                                        ? const Color(0xFF15803D)
                                        : (scan.noteQcm! == 1 ? const Color(0xFFB45309) : const Color(0xFFB91C1C)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.school_outlined, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  'QCM non évalué',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Badge de confiance IA
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: confColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$confidence%',
                          style: TextStyle(
                            color: confColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
