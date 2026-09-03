import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/prediction.dart';
import '../models/quiz.dart';

class ApiService {
  static Future<String?> login(String email, String password) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'motDePasse': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception(response.body);
    }
  }

  /// Envoie une image au backend pour analyse IA.
  /// Retourne un PredictionResult complet avec tissu, organes et questions.
  static Future<PredictionResult> uploadScan(File imageFile, String token) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/scans/analyze');
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PredictionResult.fromJson(data);
    } else {
      throw Exception('Impossible d\'analyser la lame histologique (${response.statusCode})');
    }
  }

  /// Récupère les questions QCM pour un tissu donné.
  static Future<List<Question>> getQuizForTissu(String tissuId, String token) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/questions/tissu/$tissuId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<Question>.from(l.map((model) => Question.fromJson(model)));
    } else {
      throw Exception('Impossible de charger le questionnaire QCM');
    }
  }

  /// Récupère l'historique des scans de l'étudiant connecté.
  static Future<List<ScanHistoryItem>> getMyScans(String token) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/scans/my');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<ScanHistoryItem>.from(l.map((model) => ScanHistoryItem.fromJson(model)));
    } else {
      throw Exception('Impossible de charger l\'historique des analyses');
    }
  }

  /// Soumet le résultat d'un QCM au backend.
  static Future<void> submitResultat(String scanId, int note, String token) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}/resultats');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'scanId': scanId,
        'note': note,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Impossible d\'enregistrer le score du QCM');
    }
  }
}
