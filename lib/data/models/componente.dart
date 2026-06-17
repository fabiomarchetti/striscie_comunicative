/// Tipo di componente (parola-segno tipizzata).
enum TipoComponente {
  soggetto,
  verbo,
  complemento;

  static TipoComponente fromString(String value) =>
      TipoComponente.values.firstWhere((t) => t.name == value);
}

/// Una parola-segno del dizionario, con tipo e (opzionale) video del segno.
class Componente {
  final int? id;
  final String parola;
  final TipoComponente tipo;
  final String? video;

  const Componente({
    this.id,
    required this.parola,
    required this.tipo,
    this.video,
  });

  factory Componente.fromMap(Map<String, Object?> map) => Componente(
    id: map['id'] as int?,
    parola: map['parola'] as String,
    tipo: TipoComponente.fromString(map['tipo'] as String),
    video: map['video'] as String?,
  );

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'parola': parola,
    'tipo': tipo.name,
    'video': video,
  };
}
