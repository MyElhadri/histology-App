class Question {
  final String id;
  final String texte;
  final List<Choix> choix;

  Question({
    required this.id,
    required this.texte,
    required this.choix,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var choixList = json['choix'] as List? ?? [];
    List<Choix> choixItems = choixList.map((i) => Choix.fromJson(i)).toList();
    
    return Question(
      id: json['id'] ?? '',
      texte: json['texte'] ?? '',
      choix: choixItems,
    );
  }
}

class Choix {
  final String id;
  final String texte;
  final bool estCorrect;

  Choix({
    required this.id,
    required this.texte,
    required this.estCorrect,
  });

  factory Choix.fromJson(Map<String, dynamic> json) {
    return Choix(
      id: json['id'] ?? '',
      texte: json['texte'] ?? '',
      estCorrect: json['estCorrect'] ?? false,
    );
  }
}
