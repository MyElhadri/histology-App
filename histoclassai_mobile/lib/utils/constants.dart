import 'package:flutter/material.dart';

class AppConstants {
  /// URL de base de l'API HistoClassAI.
  /// En production : passer `--dart-define=API_BASE_URL=https://votre-domaine.com/api`
  /// En local : utilise l'adresse IP du serveur sur le réseau Wi-Fi.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.3.133:5008/api',
  );

  // Colors based on the MedTech theme used in Vue.js
  static const Color primaryColor = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFE0E7FF);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Colors.white;
  static const Color textColor = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);

  /// Adapte automatiquement les URLs d'images (MinIO) au réseau local du téléphone
  static String resolveImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    try {
      final apiUri = Uri.parse(apiBaseUrl);
      final host = apiUri.host;
      return url
          .replaceAll('localhost:9000', '$host:9000')
          .replaceAll('127.0.0.1:9000', '$host:9000')
          .replaceAll('minio:9000', '$host:9000');
    } catch (_) {
      return url;
    }
  }
}
