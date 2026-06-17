/// Immagine ordinata appartenente a una striscia.
class StrisciaImmagine {
  final int? id;
  final int idStriscia;
  final String percorso;
  final int ordine;

  const StrisciaImmagine({
    this.id,
    required this.idStriscia,
    required this.percorso,
    this.ordine = 0,
  });

  factory StrisciaImmagine.fromMap(Map<String, Object?> map) =>
      StrisciaImmagine(
        id: map['id'] as int?,
        idStriscia: map['id_striscia'] as int,
        percorso: map['percorso'] as String,
        ordine: map['ordine'] as int? ?? 0,
      );

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'id_striscia': idStriscia,
    'percorso': percorso,
    'ordine': ordine,
  };
}

/// Striscia comunicativa: nome + sequenza ordinata di immagini.
class Striscia {
  final int? id;
  final String nome;
  final String? creatoIl;
  final List<StrisciaImmagine> immagini;

  const Striscia({
    this.id,
    required this.nome,
    this.creatoIl,
    this.immagini = const [],
  });

  factory Striscia.fromMap(
    Map<String, Object?> map, {
    List<StrisciaImmagine> immagini = const [],
  }) => Striscia(
    id: map['id'] as int?,
    nome: map['nome'] as String,
    creatoIl: map['creato_il'] as String?,
    immagini: immagini,
  );

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'nome': nome,
  };
}
