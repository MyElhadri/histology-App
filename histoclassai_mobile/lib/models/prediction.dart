import 'quiz.dart';

class OrganeInfo {
  final String id;
  final String nom;

  OrganeInfo({required this.id, required this.nom});

  factory OrganeInfo.fromJson(Map<String, dynamic> json) {
    return OrganeInfo(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
    );
  }
}

class PredictionResult {
  final String scanId;
  final String imageUrl;
  final String codeLabelIa;
  final double confiance;
  final String tissuId;
  final String nomTissu;
  final String descriptionTissu;
  final List<OrganeInfo> organes;
  final List<Question> questions;

  PredictionResult({
    required this.scanId,
    required this.imageUrl,
    required this.codeLabelIa,
    required this.confiance,
    required this.tissuId,
    required this.nomTissu,
    required this.descriptionTissu,
    required this.organes,
    required this.questions,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    var organesList = json['organes'] as List? ?? [];
    var questionsList = json['questions'] as List? ?? [];

    return PredictionResult(
      scanId: json['scanId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      codeLabelIa: json['codeLabelIa'] ?? '',
      confiance: (json['confiance'] ?? 0.0).toDouble(),
      tissuId: json['tissuId'] ?? '',
      nomTissu: json['nomTissu'] ?? '',
      descriptionTissu: json['descriptionTissu'] ?? '',
      organes: organesList.map((o) => OrganeInfo.fromJson(o)).toList(),
      questions: questionsList.map((q) => Question.fromJson(q)).toList(),
    );
  }
}

class ScanHistoryItem {
  final String id;
  final String tissuId;
  final String tissuNom;
  final String urlImage;
  final double scoreConfiance;
  final DateTime dateScan;

  ScanHistoryItem({
    required this.id,
    required this.tissuId,
    required this.tissuNom,
    required this.urlImage,
    required this.scoreConfiance,
    required this.dateScan,
  });

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      id: json['id'] ?? '',
      tissuId: json['tissuId'] ?? '',
      tissuNom: json['tissuNom'] ?? '',
      urlImage: json['urlImage'] ?? '',
      scoreConfiance: (json['scoreConfiance'] ?? 0.0).toDouble(),
      dateScan: DateTime.tryParse(json['dateScan'] ?? '') ?? DateTime.now(),
    );
  }
}
