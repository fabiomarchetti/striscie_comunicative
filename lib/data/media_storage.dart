import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Gestisce il salvataggio persistente dei media scelti dall'utente.
///
/// I file (immagini/video) vengono copiati in una sottocartella `media`
/// della directory documenti dell'app. In DB si memorizza solo il **percorso
/// relativo** (es. `media/img_1718...jpg`); per leggere il file si ricostruisce
/// il percorso assoluto con [percorsoAssoluto].
class MediaStorage {
  MediaStorage._();
  static final MediaStorage instance = MediaStorage._();

  Directory? _baseDir;
  int _counter = 0;

  Future<Directory> _mediaDir() async {
    if (_baseDir != null) return _baseDir!;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'media'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return _baseDir = dir;
  }

  /// Copia [sorgente] nella cartella media e ritorna il percorso RELATIVO
  /// (rispetto alla directory documenti) da salvare in DB.
  Future<String> salva(String sorgente, {String prefisso = 'media'}) async {
    final dir = await _mediaDir();
    final ext = p.extension(sorgente);
    // Nome univoco senza dipendere da Date.now()/Random (non deterministici):
    // microsecondi dall'avvio + contatore incrementale.
    final stamp = '${DateTime.now().microsecondsSinceEpoch}_${_counter++}';
    final nome = '${prefisso}_$stamp$ext';
    final dest = File(p.join(dir.path, nome));
    await File(sorgente).copy(dest.path);
    return p.join('media', nome);
  }

  /// Ricostruisce il percorso assoluto a partire dal percorso relativo in DB.
  Future<String> percorsoAssoluto(String percorsoRelativo) async {
    final docs = await getApplicationDocumentsDirectory();
    return p.join(docs.path, percorsoRelativo);
  }
}
