import 'package:flutter/material.dart';

class AppConstants {
  // 192.168.3.133 est l'adresse IP locale du PC sur le réseau Wi-Fi
  static const String apiBaseUrl = 'http://192.168.3.133:5008/api';

  // Colors based on the MedTech theme used in Vue.js
  static const Color primaryColor = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFE0E7FF);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Colors.white;
  static const Color textColor = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
}
