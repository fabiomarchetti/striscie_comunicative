/// Frase composta da soggetto + verbo + complemento (riferimenti a componenti).
class Frase {
  final int? id;
  final int? idSoggetto;
  final int? idVerbo;
  final int? idComplemento;
  final String? creatoIl;

  const Frase({
    this.id,
    this.idSoggetto,
    this.idVerbo,
    this.idComplemento,
    this.creatoIl,
  });

  factory Frase.fromMap(Map<String, Object?> map) => Frase(
    id: map['id'] as int?,
    idSoggetto: map['id_soggetto'] as int?,
    idVerbo: map['id_verbo'] as int?,
    idComplemento: map['id_complemento'] as int?,
    creatoIl: map['creato_il'] as String?,
  );

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'id_soggetto': idSoggetto,
    'id_verbo': idVerbo,
    'id_complemento': idComplemento,
  };
}
