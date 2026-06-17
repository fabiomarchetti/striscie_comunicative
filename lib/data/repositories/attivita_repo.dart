import '../database.dart';
import '../models/attivita.dart';

/// Accesso alle attività e alle loro immagini/video.
class AttivitaRepo {
  final AppDatabase _appDb;
  AttivitaRepo(this._appDb);

  /// Inserisce un'attività con immagini e video. Ritorna l'id creato.
  Future<int> inserisciCompleta({
    required String nome,
    String? video,
    required List<String> percorsiImmagini,
  }) async {
    final db = await _appDb.database;
    return db.transaction((txn) async {
      final idAttivita = await txn.insert('attivita', {
        'nome': nome,
        'video': video,
      });
      for (var i = 0; i < percorsiImmagini.length; i++) {
        await txn.insert('attivita_immagini', {
          'id_attivita': idAttivita,
          'percorso': percorsiImmagini[i],
          'ordine': i,
        });
      }
      return idAttivita;
    });
  }

  Future<List<Attivita>> tutte() async {
    final db = await _appDb.database;
    final rows = await db.query('attivita', orderBy: 'id DESC');
    return rows.map((r) => Attivita.fromMap(r)).toList();
  }

  Future<Attivita?> conImmagini(int id) async {
    final db = await _appDb.database;
    final rows = await db.query(
      'attivita',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final imgRows = await db.query(
      'attivita_immagini',
      where: 'id_attivita = ?',
      whereArgs: [id],
      orderBy: 'ordine',
    );
    return Attivita.fromMap(
      rows.first,
      immagini: imgRows.map(AttivitaImmagine.fromMap).toList(),
    );
  }
}
