import '../database.dart';
import '../models/abbinamento.dart';

/// Accesso agli abbinamenti striscia ↔ attività.
class AbbinamentoRepo {
  final AppDatabase _appDb;
  AbbinamentoRepo(this._appDb);

  Future<int> inserisci({
    required int idStriscia,
    required int idAttivita,
  }) async {
    final db = await _appDb.database;
    return db.insert('abbinamenti', {
      'id_striscia': idStriscia,
      'id_attivita': idAttivita,
    });
  }

  Future<List<Abbinamento>> tutti() async {
    final db = await _appDb.database;
    final rows = await db.query('abbinamenti', orderBy: 'id DESC');
    return rows.map(Abbinamento.fromMap).toList();
  }
}
