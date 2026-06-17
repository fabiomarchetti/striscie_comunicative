# Segnami — Gestionale LIS (Flutter + SQLite)

**Segnami** è uno strumento didattico per la **Lingua Italiana dei Segni (LIS)**,
pensato come app **personale a utente singolo** (nessuna registrazione/login).
Gira su **tablet 10" in orizzontale (landscape)**, con estetica Material 3.

L'app permette a un educatore/genitore di:

1. **Creare e modificare strisce comunicative** (sequenze di immagini/segni).
2. **Creare attività** (raccolte di immagini + un video dimostrativo del segno).
3. **Abbinare** una striscia a un'attività e salvare l'abbinamento in archivio.
4. **Consultare ("Al lavoro")** una striscia selezionata durante l'uso quotidiano.

---

## Requisiti

- **Flutter** 3.35+ (Dart 3.9+)
- Un **tablet Android** (target di riferimento) con Debug USB attivo, oppure un
  emulatore. Funziona anche su iOS/desktop (su macOS/iOS serve CocoaPods).

## Avvio rapido

```bash
flutter pub get      # installa le dipendenze
flutter run          # avvia sul dispositivo collegato
```

Per scegliere un dispositivo specifico:

```bash
flutter devices                 # elenca i dispositivi
flutter run -d <id-dispositivo>
```

Comandi utili durante `flutter run`: **`r`** hot reload · **`R`** hot restart ·
**`q`** esci.

---

## Lavorare da più computer (sync con Git)

Il **codice** si sincronizza via Git/GitHub. Ciclo consigliato:

```bash
# A inizio sessione, su ogni computer:
git pull

# A fine sessione:
git add -A
git commit -m "descrizione delle modifiche"
git push
```

> ⚠️ **Nota sui dati:** Git sincronizza solo il codice del progetto. I dati
> inseriti a runtime (database SQLite + immagini/video importati) vivono nello
> storage dell'app **sul dispositivo** e non viaggiano con Git. Su un nuovo
> computer il database si ricrea da zero con il dizionario seed.

---

## Architettura

```
lib/
  main.dart                  # MaterialApp M3, lock landscape, init DB
  theme/app_theme.dart       # design tokens (colori, raggi, ombre, font)
  data/
    database.dart            # apertura sqflite, schema, seed
    media_storage.dart       # salvataggio media su filesystem app
    media_picker.dart        # image_picker / file_picker
    models/                  # componente, frase, striscia, attivita, abbinamento
    repositories/            # un repository per entità
  state/app_state.dart       # ChangeNotifier: schermata corrente + selezioni
  ui/
    shell/app_shell.dart     # NavigationRail + top bar + body switcher
    screens/                 # comunicazioni, attivita, abbina, al_lavoro
    widgets/                 # drop box, chip, step label, snackbar, logo, ...
```

**Stack:** `sqflite` (persistenza), `path`/`path_provider` (filesystem),
`image_picker` (immagini), `file_picker` (video), `video_player` (anteprime),
`provider` (state management), `google_fonts` (Roboto Flex / Roboto Mono).

I media (immagini/video) vengono copiati nella directory documenti dell'app; in
DB si memorizza solo il **percorso relativo**, non i blob.

---

## Schema dati (SQLite)

- `componenti` — dizionario parole-segno tipizzate (soggetto/verbo/complemento) + video
- `frasi` — soggetto + verbo + complemento
- `strisce` / `striscia_immagini` — strisce comunicative e relative immagini ordinate
- `attivita` / `attivita_immagini` — attività con immagini + 1 video dimostrativo
- `abbinamenti` — collegamento striscia ↔ attività

Le foreign key sono attive (`PRAGMA foreign_keys = ON`). Il dizionario
`componenti` viene popolato al primo avvio con i dati di seed.

---

## Documentazione di design

La cartella [`design_handoff_segnami_flutter/`](design_handoff_segnami_flutter/)
contiene il documento di handoff e il prototipo HTML di riferimento usati per
ricostruire la UI.
