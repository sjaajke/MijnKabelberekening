class Gebruiker {
  final String id;
  final String naam;
  final DateTime aangemaakt;

  const Gebruiker({
    required this.id,
    required this.naam,
    required this.aangemaakt,
  });

  Gebruiker copyWith({String? naam}) => Gebruiker(
        id: id,
        naam: naam ?? this.naam,
        aangemaakt: aangemaakt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'naam': naam,
        'aangemaakt': aangemaakt.toIso8601String(),
      };

  factory Gebruiker.fromJson(Map<String, dynamic> j) => Gebruiker(
        id: j['id'] as String,
        naam: j['naam'] as String,
        aangemaakt: DateTime.parse(j['aangemaakt'] as String),
      );
}
