import 'package:flutter/foundation.dart';

import '../data/database.dart';
import '../data/media_storage.dart';
import '../data/models/attivita.dart';
import '../data/models/componente.dart';
import '../data/models/striscia.dart';
import '../data/repositories/abbinamento_repo.dart';
import '../data/repositories/attivita_repo.dart';
import '../data/repositories/componente_repo.dart';
import '../data/repositories/frase_repo.dart';
import '../data/repositories/striscia_repo.dart';

/// Le quattro schermate dell'app (stato `screen` dell'handoff).
enum AppScreen { comunica, attivita, frasi, esplora }

/// Bozza di un'attività in editing (immagini + video, prima del salvataggio).
class BozzaAttivita {
  final List<String> immagini = []; // percorsi relativi salvati
  String? video; // percorso relativo salvato
}

/// Messaggio snackbar con timestamp di emissione (per auto-dismiss).
class SnackMessage {
  final String testo;
  final int seq;
  const SnackMessage(this.testo, this.seq);
}

/// Stato globale a livello app (ChangeNotifier, come da handoff §State).
class AppState extends ChangeNotifier {
  final AppDatabase _db = AppDatabase.instance;
  final MediaStorage media = MediaStorage.instance;

  late final ComponenteRepo componentiRepo = ComponenteRepo(_db);
  late final FraseRepo frasiRepo = FraseRepo(_db);
  late final StrisciaRepo strisceRepo = StrisciaRepo(_db);
  late final AttivitaRepo attivitaRepo = AttivitaRepo(_db);
  late final AbbinamentoRepo abbinamentiRepo = AbbinamentoRepo(_db);

  // --- Navigazione ---
  AppScreen _screen = AppScreen.comunica;
  AppScreen get screen => _screen;
  void vaiA(AppScreen s) {
    if (_screen == s) return;
    _screen = s;
    notifyListeners();
  }

  // --- Footer rail: conteggio record totali ---
  int dbTotal = 0;

  // --- Snackbar ---
  SnackMessage? _snack;
  SnackMessage? get snack => _snack;
  int _snackSeq = 0;
  void mostraSnack(String testo) {
    _snack = SnackMessage(testo, ++_snackSeq);
    notifyListeners();
  }

  void chiudiSnack(int seq) {
    if (_snack?.seq == seq) {
      _snack = null;
      notifyListeners();
    }
  }

  // --- Dati caricati dal DB ---
  List<Striscia> strisce = [];
  List<Attivita> attivita = [];
  List<Componente> componenti = [];

  // --- Bozza Comunicazioni (striscia in creazione/modifica) ---
  String striscaNome = '';
  final List<String> bozzaStrisciaImmagini = [];

  /// Id della striscia in modifica; `null` = creazione di una nuova striscia.
  int? striscaInModificaId;
  bool get inModificaStriscia => striscaInModificaId != null;

  // --- Bozze Attività (più card) ---
  final List<BozzaAttivita> bozzeAttivita = [BozzaAttivita()];

  // --- Selezioni Abbina / Al lavoro ---
  int? striscaSelId; // condivisa tra Abbina e Al lavoro
  int? attivitaSelId; // Abbina

  Striscia? get striscaSel =>
      strisce.where((s) => s.id == striscaSelId).firstOrNull;
  Attivita? get attivitaSel =>
      attivita.where((a) => a.id == attivitaSelId).firstOrNull;

  /// Inizializzazione: apre il DB (creando schema+seed) e carica i dati.
  Future<void> inizializza() async {
    await ricaricaTutto();
  }

  Future<void> ricaricaTutto() async {
    strisce = await strisceRepo.tutte();
    attivita = await attivitaRepo.tutte();
    componenti = await componentiRepo.tutti();
    dbTotal = await _db.contaTotaleRecord();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Comunicazioni
  // ---------------------------------------------------------------------------
  void setStriscaNome(String v) {
    striscaNome = v;
  }

  void aggiungiImmagineStriscia(String percorsoRelativo) {
    bozzaStrisciaImmagini.add(percorsoRelativo);
    notifyListeners();
  }

  void rimuoviImmagineStriscia(int index) {
    bozzaStrisciaImmagini.removeAt(index);
    notifyListeners();
  }

  /// Sostituisce l'immagine alla posizione [index] mantenendone l'ordine.
  void sostituisciImmagineStriscia(int index, String percorsoRelativo) {
    bozzaStrisciaImmagini[index] = percorsoRelativo;
    notifyListeners();
  }

  /// Entra in modalità modifica caricando nome e immagini della striscia.
  Future<void> iniziaModificaStriscia(int id) async {
    final s = await strisceRepo.conImmagini(id);
    if (s == null) return;
    striscaInModificaId = id;
    striscaNome = s.nome;
    bozzaStrisciaImmagini
      ..clear()
      ..addAll(s.immagini.map((i) => i.percorso));
    notifyListeners();
  }

  /// Esce dalla modifica e ripristina una bozza vuota.
  void nuovaStriscia() {
    striscaInModificaId = null;
    striscaNome = '';
    bozzaStrisciaImmagini.clear();
    notifyListeners();
  }

  /// Salva la striscia corrente: inserisce se nuova, aggiorna se in modifica.
  /// Ritorna `false` se il nome è vuoto.
  Future<bool> salvaStriscia() async {
    final nome = striscaNome.trim();
    if (nome.isEmpty) {
      mostraSnack('Inserisci un nome per la striscia');
      return false;
    }
    final immagini = List.of(bozzaStrisciaImmagini);
    if (inModificaStriscia) {
      await strisceRepo.aggiornaConImmagini(
        id: striscaInModificaId!,
        nome: nome,
        percorsiImmagini: immagini,
      );
      await ricaricaTutto();
      mostraSnack('Striscia «$nome» aggiornata');
    } else {
      await strisceRepo.inserisciConImmagini(
        nome: nome,
        percorsiImmagini: immagini,
      );
      await ricaricaTutto();
      mostraSnack('Striscia «$nome» salvata');
    }
    nuovaStriscia();
    return true;
  }

  /// Elimina la striscia in modifica (o quella indicata) dal DB.
  Future<void> eliminaStriscia(int id) async {
    await strisceRepo.elimina(id);
    if (striscaInModificaId == id) {
      nuovaStriscia();
    }
    // Se era selezionata altrove (Abbina/Al lavoro), deseleziona.
    if (striscaSelId == id) {
      striscaSelId = null;
    }
    await ricaricaTutto();
    mostraSnack('Striscia eliminata');
  }

  // ---------------------------------------------------------------------------
  // Attività
  // ---------------------------------------------------------------------------
  void aggiungiCardAttivita() {
    bozzeAttivita.add(BozzaAttivita());
    notifyListeners();
  }

  void aggiungiImmagineAttivita(int cardIndex, String percorsoRelativo) {
    bozzeAttivita[cardIndex].immagini.add(percorsoRelativo);
    notifyListeners();
  }

  void setVideoAttivita(int cardIndex, String percorsoRelativo) {
    bozzeAttivita[cardIndex].video = percorsoRelativo;
    notifyListeners();
  }

  /// Salva una card attività come record. Nome generato progressivo.
  Future<void> salvaAttivita(int cardIndex) async {
    final bozza = bozzeAttivita[cardIndex];
    final nome = 'Attività ${attivita.length + 1}';
    await attivitaRepo.inserisciCompleta(
      nome: nome,
      video: bozza.video,
      percorsiImmagini: List.of(bozza.immagini),
    );
    bozzeAttivita[cardIndex] = BozzaAttivita();
    await ricaricaTutto();
    mostraSnack('«$nome» salvata');
  }

  // ---------------------------------------------------------------------------
  // Abbina
  // ---------------------------------------------------------------------------
  void selezionaStriscia(int? id) {
    striscaSelId = id;
    notifyListeners();
  }

  void selezionaAttivita(int? id) {
    attivitaSelId = id;
    notifyListeners();
  }

  Future<bool> salvaAbbinamento() async {
    if (striscaSelId == null || attivitaSelId == null) {
      mostraSnack('Seleziona una striscia e un\'attività');
      return false;
    }
    await abbinamentiRepo.inserisci(
      idStriscia: striscaSelId!,
      idAttivita: attivitaSelId!,
    );
    final s = striscaSel?.nome ?? 'Striscia';
    final a = attivitaSel?.nome ?? 'Attività';
    await ricaricaTutto();
    mostraSnack('$s + $a — salvato in archivio');
    return true;
  }
}
