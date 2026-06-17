/// Abbinamento tra una striscia e un'attività salvato in archivio.
class Abbinamento {
  final int? id;
  final int idStriscia;
  final int idAttivita;
  final String? creatoIl;

  const Abbinamento({
    this.id,
    required this.idStriscia,
    required this.idAttivita,
    this.creatoIl,
  });

  factory Abbinamento.fromMap(Map<String, Object?> map) => Abbinamento(
    id: map['id'] as int?,
    idStriscia: map['id_striscia'] as int,
    idAttivita: map['id_attivita'] as int,
    creatoIl: map['creato_il'] as String?,
  );

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'id_striscia': idStriscia,
    'id_attivita': idAttivita,
  };
}
