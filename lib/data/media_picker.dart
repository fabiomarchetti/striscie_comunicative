import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'media_storage.dart';

/// Wrapper sui picker di sistema. Dopo la scelta, il file viene copiato nello
/// storage persistente dell'app e viene ritornato il percorso RELATIVO da
/// salvare in DB (oppure `null` se l'utente annulla).
class MediaPicker {
  MediaPicker._();
  static final MediaPicker instance = MediaPicker._();

  final ImagePicker _imagePicker = ImagePicker();
  final MediaStorage _storage = MediaStorage.instance;

  /// Sceglie un'immagine dalla galleria/file system.
  Future<String?> scegliImmagine() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (file == null) return null;
    return _storage.salva(file.path, prefisso: 'img');
  }

  /// Sceglie un video dal file system.
  Future<String?> scegliVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    final path = result?.files.single.path;
    if (path == null) return null;
    return _storage.salva(path, prefisso: 'vid');
  }
}
