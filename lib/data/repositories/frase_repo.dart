import '../database.dart';
import '../models/frase.dart';

/// Accesso alle frasi (soggetto + verbo + complemento).
class FraseRepo {
  final AppDatabase _appDb;
  FraseRepo(this._appDb);

  Future<List<Frase>> tutte() async {
    final db = await _appDb.database;
    final rows = await db.query('frasi', orderBy: 'id DESC');
    return rows.map(Frase.fromMap).toList();
  }

  Future<int> inserisci(Frase frase) async {
    final db = await _appDb.database;
    return db.insert('frasi', frase.toMap());
  }
}
