/// Immagine ordinata appartenente a un'attività.
class AttivitaImmagine {
  final int? id;
  final int idAttivita;
  final String percorso;
  final int ordine;

  const AttivitaImmagine({
    this.id,
    required this.idAttivita,
    required this.percorso,
    this.ordine = 0,
  });

  factory AttivitaImmagine.fromMap(Map<String, Object?> map) =>
      AttivitaImmagine(
        id: map['id'] as int?,
        idAttivita: map['id_attivita'] as int,
        percorso: map['percorso'] as String,
        ordine: map['ordine'] as int? ?? 0,
      );

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'id_attivita': idAttivita,
    'percorso': percorso,
    'ordine': ordine,
  };
}

/// Attività: raccolta di immagini + 1 video dimostrativo.
class Attivita {
  final int? id;
  final String nome;
  final String? video;
  final String? creatoIl;
  final List<AttivitaImmagine> immagini;

  const Attivita({
    this.id,
    required this.nome,
    this.video,
    this.creatoIl,
    this.immagini = const [],
  });

  factory Attivita.fromMap(
    Map<String, Object?> map, {
    List<AttivitaImmagine> immagini = const [],
  }) => Attivita(
    id: map['id'] as int?,
    nome: map['nome'] as String,
    video: map['video'] as String?,
    creatoIl: map['creato_il'] as String?,
    immagini: immagini,
  );

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'nome': nome,
    'video': video,
  };
}
