import '../database.dart';
import '../models/striscia.dart';

/// Accesso alle strisce comunicative e alle loro immagini.
class StrisciaRepo {
  final AppDatabase _appDb;
  StrisciaRepo(this._appDb);

  /// Inserisce una striscia con la lista ordinata di percorsi immagine.
  /// Ritorna l'id della striscia creata.
  Future<int> inserisciConImmagini({
    required String nome,
    required List<String> percorsiImmagini,
  }) async {
    final db = await _appDb.database;
    return db.transaction((txn) async {
      final idStriscia = await txn.insert('strisce', {'nome': nome});
      for (var i = 0; i < percorsiImmagini.length; i++) {
        await txn.insert('striscia_immagini', {
          'id_striscia': idStriscia,
          'percorso': percorsiImmagini[i],
          'ordine': i,
        });
      }
      return idStriscia;
    });
  }

  /// Aggiorna nome e immagini di una striscia esistente: sostituisce
  /// completamente l'elenco immagini con quello fornito (ri-ordinato).
  Future<void> aggiornaConImmagini({
    required int id,
    required String nome,
    required List<String> percorsiImmagini,
  }) async {
    final db = await _appDb.database;
    await db.transaction((txn) async {
      await txn.update(
        'strisce',
        {'nome': nome},
        where: 'id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'striscia_immagini',
        where: 'id_striscia = ?',
        whereArgs: [id],
      );
      for (var i = 0; i < percorsiImmagini.length; i++) {
        await txn.insert('striscia_immagini', {
          'id_striscia': id,
          'percorso': percorsiImmagini[i],
          'ordine': i,
        });
      }
    });
  }

  /// Elimina una striscia (le immagini vengono rimosse in cascata).
  Future<void> elimina(int id) async {
    final db = await _appDb.database;
    await db.delete('strisce', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Striscia>> tutte() async {
    final db = await _appDb.database;
    final rows = await db.query('strisce', orderBy: 'id DESC');
    return rows.map((r) => Striscia.fromMap(r)).toList();
  }

  /// Carica una striscia completa di immagini ordinate.
  Future<Striscia?> conImmagini(int id) async {
    final db = await _appDb.database;
    final rows = await db.query(
      'strisce',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final imgRows = await db.query(
      'striscia_immagini',
      where: 'id_striscia = ?',
      whereArgs: [id],
      orderBy: 'ordine',
    );
    return Striscia.fromMap(
      rows.first,
      immagini: imgRows.map(StrisciaImmagine.fromMap).toList(),
    );
  }
}
