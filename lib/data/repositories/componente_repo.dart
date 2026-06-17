import '../database.dart';
import '../models/componente.dart';

/// Accesso al dizionario componenti (parole-segno tipizzate).
class ComponenteRepo {
  final AppDatabase _appDb;
  ComponenteRepo(this._appDb);

  Future<List<Componente>> tutti() async {
    final db = await _appDb.database;
    final rows = await db.query('componenti', orderBy: 'tipo, parola');
    return rows.map(Componente.fromMap).toList();
  }

  Future<List<Componente>> perTipo(TipoComponente tipo) async {
    final db = await _appDb.database;
    final rows = await db.query(
      'componenti',
      where: 'tipo = ?',
      whereArgs: [tipo.name],
      orderBy: 'parola',
    );
    return rows.map(Componente.fromMap).toList();
  }

  Future<int> inserisci(Componente componente) async {
    final db = await _appDb.database;
    return db.insert('componenti', componente.toMap());
  }
}
