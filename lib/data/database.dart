import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Gestisce l'apertura, la creazione e il seeding del database SQLite.
///
/// Lo schema riproduce fedelmente quello fornito nell'handoff. I media
/// (immagini/video) NON vengono salvati come blob: in DB resta solo il
/// percorso relativo al file salvato nella directory documenti dell'app.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const _dbName = 'segnami.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE componenti (
        id     INTEGER PRIMARY KEY AUTOINCREMENT,
        parola TEXT NOT NULL,
        tipo   TEXT NOT NULL CHECK (tipo IN ('soggetto','verbo','complemento')),
        video  TEXT
      );
    ''');

    batch.execute('''
      CREATE TABLE frasi (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        id_soggetto     INTEGER REFERENCES componenti(id),
        id_verbo        INTEGER REFERENCES componenti(id),
        id_complemento  INTEGER REFERENCES componenti(id),
        creato_il       TEXT DEFAULT (datetime('now'))
      );
    ''');

    batch.execute('''
      CREATE TABLE strisce (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        nome      TEXT NOT NULL,
        creato_il TEXT DEFAULT (datetime('now'))
      );
    ''');

    batch.execute('''
      CREATE TABLE striscia_immagini (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        id_striscia INTEGER NOT NULL REFERENCES strisce(id) ON DELETE CASCADE,
        percorso    TEXT NOT NULL,
        ordine      INTEGER NOT NULL DEFAULT 0
      );
    ''');

    batch.execute('''
      CREATE TABLE attivita (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        nome      TEXT NOT NULL,
        video     TEXT,
        creato_il TEXT DEFAULT (datetime('now'))
      );
    ''');

    batch.execute('''
      CREATE TABLE attivita_immagini (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        id_attivita  INTEGER NOT NULL REFERENCES attivita(id) ON DELETE CASCADE,
        percorso     TEXT NOT NULL,
        ordine       INTEGER NOT NULL DEFAULT 0
      );
    ''');

    batch.execute('''
      CREATE TABLE abbinamenti (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        id_striscia INTEGER NOT NULL REFERENCES strisce(id) ON DELETE CASCADE,
        id_attivita INTEGER NOT NULL REFERENCES attivita(id) ON DELETE CASCADE,
        creato_il   TEXT DEFAULT (datetime('now'))
      );
    ''');

    await batch.commit(noResult: true);
    await _seed(db);
  }

  /// Popola il dizionario componenti con i dati di seed dell'handoff.
  Future<void> _seed(Database db) async {
    const seed = <List<String>>[
      // soggetti
      ['Io', 'soggetto'],
      ['Tu', 'soggetto'],
      ['Mamma', 'soggetto'],
      ['Bambino', 'soggetto'],
      ['Amico', 'soggetto'],
      // verbi
      ['mangiare', 'verbo'],
      ['bere', 'verbo'],
      ['volere', 'verbo'],
      ['giocare', 'verbo'],
      ['leggere', 'verbo'],
      // complementi
      ['casa', 'complemento'],
      ['mela', 'complemento'],
      ['libro', 'complemento'],
      ['acqua', 'complemento'],
      ['gelato', 'complemento'],
      ['palla', 'complemento'],
    ];

    final batch = db.batch();
    for (final row in seed) {
      final parola = row[0];
      batch.insert('componenti', {
        'parola': parola,
        'tipo': row[1],
        'video': '$parola.mp4',
      });
    }
    await batch.commit(noResult: true);
  }

  /// Conteggio totale di tutti i record (per il footer del rail).
  Future<int> contaTotaleRecord() async {
    final db = await database;
    const tabelle = [
      'componenti',
      'frasi',
      'strisce',
      'striscia_immagini',
      'attivita',
      'attivita_immagini',
      'abbinamenti',
    ];
    var totale = 0;
    for (final t in tabelle) {
      final res = await db.rawQuery('SELECT COUNT(*) AS c FROM $t');
      totale += Sqflite.firstIntValue(res) ?? 0;
    }
    return totale;
  }
}
