# Handoff: Segnami — Gestionale LIS (Flutter + SQLite)

## Overview
**Segnami** è uno strumento didattico per la **Lingua Italiana dei Segni (LIS)**, pensato come app **personale a utente singolo** (nessuna registrazione/login). Gira su **tablet 10" in orizzontale (landscape)**, estetica **Android Material 3**.

L'app permette a un educatore/genitore di:
1. **Creare strisce comunicative** (sequenze di immagini/segni).
2. **Creare attività** (raccolte di immagini + un video dimostrativo del segno).
3. **Abbinare** una striscia a un'attività e salvare l'abbinamento in archivio.
4. **Consultare ("Al lavoro")** una striscia selezionata durante l'uso quotidiano.

Esiste anche un dominio dati di base — **componenti** (parole-segno tipizzate: soggetto/verbo/complemento, ciascuna con un video) e **frasi** (soggetto+verbo+complemento) — già modellato nello schema SQLite ed è la base semantica del prototipo.

---

## About the Design Files
Il file in questo bundle (`Segnami Admin Tablet.dc.html`) è una **reference di design realizzata in HTML** — un prototipo che mostra l'aspetto e il comportamento desiderati. **Non è codice di produzione da copiare.** Il compito è **ricreare questo design in un'app Flutter**, usando widget Material 3 nativi e `sqflite` per la persistenza.

Il prototipo simula il DB con `localStorage`; nell'app reale va sostituito con **SQLite via `sqflite`**. Lo schema SQL è fornito sotto, pronto all'uso.

> Le tre voci di menu "Crea striscie comunicative", "Crea attività" e i picker immagine/video nel prototipo mostrano stati segnaposto ("in arrivo"): vanno implementati come funzionalità reali (file/image picker, salvataggio su DB e su filesystem dell'app).

---

## Fidelity
**Hi-fi.** Colori, tipografia, spaziature e raggi sono definitivi e vanno riprodotti fedelmente (vedi *Design Tokens*). Le interazioni descritte (navigazione, salvataggi, snackbar) sono la specifica funzionale.

---

## Target & ottimizzazione tablet 10"
- **Orientamento**: forzare **landscape** (`SystemChrome.setPreferredOrientations([landscapeLeft, landscapeRight])`).
- **Layout di riferimento**: area utile **1280 × 800 logical px** (16:10, densità tipica tablet 10"). Usare layout **fluido** (`Expanded`/`Flexible`, `LayoutBuilder`) — NON misure fisse — così da adattarsi a 10.1"–11".
- **Navigazione**: `NavigationRail` Material 3 a sinistra (larghezza 96px), sempre visibile (no bottom nav su tablet).
- **Hit target** minimo 48×48 dp su tutti i controlli.
- **Niente `AppBar` mobile**: usare una top bar custom interna al pannello di contenuto (vedi struttura).

---

## Architettura consigliata (Flutter)

```
lib/
  main.dart                  // MaterialApp, theme M3, lock landscape
  theme/app_theme.dart       // ColorScheme + TextTheme (token sotto)
  data/
    database.dart            // apertura sqflite, migrazioni, seed
    models/
      componente.dart
      frase.dart
      striscia.dart
      attivita.dart
      abbinamento.dart
    repositories/
      componente_repo.dart
      frase_repo.dart
      striscia_repo.dart
      attivita_repo.dart
      abbinamento_repo.dart
  state/app_state.dart       // ChangeNotifier/Riverpod: schermata corrente + selezioni
  ui/
    shell/app_shell.dart     // NavigationRail + top bar + body switcher
    screens/
      comunicazioni_screen.dart
      attivita_screen.dart
      abbina_screen.dart
      al_lavoro_screen.dart
    widgets/
      media_drop_box.dart    // box tratteggiato "+ aggiungi"
      step_label.dart        // "1 · ..." etichette di sezione
      preview_chip.dart
```

**Pacchetti**: `sqflite`, `path` / `path_provider`, `image_picker` (immagini), `file_picker` o `image_picker` (video), `video_player` (anteprima/riproduzione segni). State management a scelta (`provider` o `riverpod`); il prototipo usa un singolo stato a livello di app.

---

## App Shell (struttura comune a tutte le schermate)

Tre fasce dentro il "device":
1. **Status bar** (solo nel prototipo per realismo — NON serve nell'app reale, la fornisce il sistema).
2. **Body** = riga orizzontale: `NavigationRail` (sinistra) + `Pannello contenuto` (destra, `Expanded`).
3. **Snackbar** sovrapposta in basso al centro.

### NavigationRail (sinistra)
- Larghezza **96px**, sfondo **`#F7EBE3`**, padding verticale 14/16px.
- In cima: **logo** — quadrato 44×44, `borderRadius 13`, gradiente `linear-gradient(150deg, #C0432A → #9C4A2B)`, ombra `0 6px 14px rgba(156,74,43,0.32)`, icona "mano" bianca (LIS) al centro. Margine sotto 22px.
- 4 voci, ciascuna = colonna `icona + label`:
  - L'**indicatore** attivo è una pillola dietro l'icona: 56×32, `borderRadius 18`, background **`#FFDBCB`** se attiva, altrimenti trasparente.
  - Icona stroke **`#3A0A00`** se attiva, **`#6E5F57`** se inattiva.
  - Label: `font-size 11`, `line-height 1.2`, centrata; **bold (700) `#9C4A2B`** se attiva, `500 #6E5F57` se inattiva. Testo su più righe.
  - Voci (in ordine), label su righe multiple:
    1. `Crea / striscie / comunicative` — icona "fumetto con righe" (`M4 5h16a1 1 0 0 1 1 1v9a1 1 0 0 1-1 1H9l-4 4...`).
    2. `Crea / attività` — icona "checklist in riquadro" (spunta + rettangolo).
    3. `Abbina / striscie ed / attività` — icona "documento con righe" (rettangolo + 3 linee).
    4. `Al / lavoro` — icona "dashboard/colonne" (rettangolo diviso).
  - Spaziatura tra voci: `margin-top 6px`.
- In fondo (spinto giù con spazio flessibile): icona "database" (stroke `#85736B`) + contatore **"{N} righe"** (`font-size 10`, bold, `#85736B`) = numero totale di record nel DB.

### Top bar del pannello contenuto
- Altezza **74px**, padding orizzontale 30px, bordo inferiore `1px solid #EFE0D8`, sfondo `#FFF8F5`.
- A sinistra (`Expanded`): **Titolo** (`font-size 22`, bold, `#26211D`, `letter-spacing -0.3`) + **Sottotitolo** (`font-size 13`, `500`, `#6E5F57`).
- A destra: **azioni contestuali** che cambiano per schermata (vedi singole schermate).
- Titoli/sottotitoli per schermata:
  | Schermata | Titolo | Sottotitolo |
  |---|---|---|
  | Comunicazioni | `Comunicazioni` | `Crea e gestisci le strisce comunicative.` |
  | Crea attività | `Crea attività` | `Crea e gestisci le attività.` |
  | Abbina | `Abbina striscie ed attività` | `Collega soggetto, verbo e complemento per creare una frase.` |
  | Al lavoro | `Esplora dati` | `Consulta tutte le frasi salvate o l'intera tabella componenti.` |

### Area contenuto
- `Expanded`, scrollabile verticalmente, padding `24px 30px 30px`. Sfondo `#FFF8F5`.
- Scrollbar sottile: thumb `#DBC8BF`, larghezza 8px, `borderRadius 8`.

---

## Screens / Views

### 1. Comunicazioni — "Crea striscie comunicative"
**Scopo**: creare una striscia comunicativa dandole un nome e aggiungendo immagini.

**Top bar — azione a destra** (solo qui):
- Campo testo "Nome della striscia…": altezza 44, `borderRadius 22`, bordo `1px #DBC8BF`, sfondo `#FFF8F5`, icona fumetto a sinistra (`#A7958C`), padding `0 16 0 38`. Larghezza 240. Placeholder color `#A7958C`.
- Bottone **Salva**: altezza 44, `borderRadius 22`, sfondo `#9C4A2B`, testo bianco bold 14, icona "salva/floppy", ombra `0 4px 12px rgba(156,74,43,0.28)`. Hover/pressed → `#85391F`. Gap 9px tra campo e bottone.

**Body**:
- Card bianca a tutta larghezza: sfondo `#fff`, bordo `1px #EAD9D0`, `borderRadius 22`, padding 20, ombra `0 8px 24px rgba(40,30,22,0.06)`.
  - Header card: badge numerico circolare (30×30, `#FFDBCB`, testo `#3A0A00` bold) + titolo "Striscia 1" (16 bold `#26211D`). Gap 10px.
  - Contenuto: **box "Aggiungi immagine"** (drop box) centrato: ~138×98, `borderRadius 16`, sfondo `#FCF1EB`, **bordo tratteggiato 2px `#D3A98E`**, colonna centrata con cerchio 46×46 `#9C4A2B` + icona "+" bianca + label "Aggiungi immagine" (13.5 bold `#9C4A2B`). Hover → sfondo `#F7E6DC`, bordo `#9C4A2B`.

**Comportamento da implementare**:
- Tap sul box immagine → `image_picker` (galleria/file). Le immagini scelte popolano la striscia (griglia, come nella schermata attività). Permettere più immagini.
- Tap "Salva" → valida nome non vuoto (altrimenti snackbar "Inserisci un nome per la striscia"), inserisce in `strisce` con nome + lista immagini + data, resetta il campo, snackbar `Striscia «{nome}» salvata`.

---

### 2. Crea attività
**Scopo**: creare un'attività con una raccolta di **immagini** (sinistra) e un **video** dimostrativo (destra).

**Body**:
- Card bianca (stesso stile della card striscia): header badge "1" + "Attività 1".
- Riga di due box affiancati (`gap 16`, ciascuno `Expanded`):
  - **Box Immagini** (sinistra): sfondo `#FCF1EB`, bordo `1px #EFE0D8`, `borderRadius 18`, padding 16. Header: icona "foto" (`#9C4A2B`) + "Immagini" (14 bold). Sotto: **griglia 3 colonne** (`gap 10`) di slot quadrati (`aspect-ratio 1:1`), ciascuno drop box tratteggiato (`#FFF8F5`, dashed 2px `#D3A98E`, cerchio 38×38 `#9C4A2B` + "+", label "Aggiungi immagine"). Tap → aggiungi immagine alla griglia.
  - **Box Video** (destra): stesso contenitore. Header: icona "play" + "Video". Sotto: un solo drop box `aspect-ratio 16:9` a tutta larghezza (cerchio 48×48 + "+", label "Carica video"). Tap → carica/registra un video.
- **Banner "Aggiungi attività"** sotto la card (`margin-top 16`): larghezza piena, altezza 64, `borderRadius 18`, sfondo `#FCF1EB`, dashed 2px `#D3A98E`, riga centrata con cerchio 36×36 `#9C4A2B` + "+" + "Aggiungi attività" (15 bold `#9C4A2B`). Tap → aggiunge una nuova card attività.

**Comportamento**: ogni attività salva N immagini + 1 video su filesystem app (`path_provider`), con i percorsi memorizzati in DB. Il banner clona una nuova attività vuota.

---

### 3. Abbina striscie ed attività
**Scopo**: collegare una striscia a un'attività e salvare l'abbinamento.

**Body** — flusso a 4 step verticali:
1. **`1 · Seleziona striscia`** (etichetta: 13 bold `#6E5F57`, margin bottom 10) + **dropdown** larghezza 320, altezza 50, `borderRadius 14`, bordo `1px #DBC8BF`, sfondo `#FFF8F5`, chevron `#9C4A2B` a destra. Opzioni: le strisce salvate (nel prototipo: Striscia 1–4).
2. **`2 · Anteprima striscia`** + box `#F0E3DB` `borderRadius 18` padding `18 20`: micro-label "STRISCIA SELEZIONATA" (uppercase, 11.5 bold `#6E5F57`) + **chip** con icona fumetto: sfondo `#FFDBCB`, testo `#3A0A00` bold 15, `borderRadius 11`, padding `8 16`.
3. **`3 · Seleziona attività`** + dropdown identico (opzioni Attività 1–4).
4. **`4 · Anteprima attività`** + box `#F0E3DB`: chip **verde** (sfondo `#C9EFD6`, testo `#00210F`) con icona "checklist".
- **Bottone "Salva in archivio"** in basso a destra: altezza 52, `borderRadius 18`, `#9C4A2B`, testo bianco bold 15, icona "salva", ombra `0 6px 16px rgba(156,74,43,0.28)`, hover `#85391F`.

**Comportamento**: salva un record `abbinamenti(id_striscia, id_attivita, creato)`. Snackbar `{Striscia} + {Attività} — salvato in archivio`.

---

### 4. Al lavoro
**Scopo**: vista d'uso a runtime: si seleziona una striscia e la si consulta.

**Top bar — azione a destra**: **dropdown** "Seleziona striscia" (larghezza 280, altezza 44, `borderRadius 22`, stile coerente con la top bar, chevron `#9C4A2B`). Opzioni: strisce salvate.

**Body**: attualmente vuoto nel prototipo — è lo spazio dove mostrare la striscia selezionata (sequenza di immagini/segni a tutto schermo per la consultazione). **Da progettare con il cliente**: griglia/carosello a piena pagina delle immagini della striscia, ottimizzata per la lettura da tablet a distanza.

---

## Interactions & Behavior
- **Navigazione**: tap su una voce del rail → cambia schermata (stato `screen`: `comunica` | `attivita` | `frasi`(abbina) | `esplora`(al lavoro)). Schermata iniziale: **comunica**.
- **Snackbar**: messaggio in basso-centro, sfondo `#382E29`, testo `#FFEDE5` bold 14, `borderRadius 12`, padding `14 20`, icona spunta `#FFB59B`, ombra `0 8px 24px rgba(0,0,0,0.28)`. Animazione di entrata: traslazione dal basso 16px + fade, ~260ms ease. Auto-dismiss dopo **2600ms**.
- **Hover/pressed** drop box: sfondo → `#F7E6DC`, bordo → `#9C4A2B`. Su tablet (touch) usare lo stato `pressed`/`InkWell` con `overlayColor` equivalente.
- **Validazioni**: nome striscia obbligatorio; per l'abbinamento striscia+attività entrambe selezionate.
- **Persistenza**: ogni modifica scrive su SQLite immediatamente.

---

## State Management
Stato a livello app:
- `screen` — schermata corrente.
- `striscaNome` — testo del campo (Comunicazioni).
- `striscaSel` — striscia selezionata (Abbina + Al lavoro, condivisa).
- `attivitaSel` — attività selezionata (Abbina).
- `snack` — messaggio snackbar corrente (+ timer auto-dismiss).
- `dbTotal` — derivato: conteggio record totali per il footer del rail.
Tutto il resto è derivato dalle query al DB (liste strisce/attività/abbinamenti/componenti/frasi).

---

## Design Tokens

### Colori
| Ruolo | Hex |
|---|---|
| Primary (azioni, accenti) | `#9C4A2B` |
| Primary pressed/hover | `#85391F` |
| Primary gradient (logo) | `#C0432A` → `#9C4A2B` |
| Superficie app / contenuto | `#FFF8F5` |
| Superficie rail | `#F7EBE3` |
| Card | `#FFFFFF` |
| Bordo card / divisori | `#EAD9D0` / `#EFE0D8` |
| Superficie soft (drop box, chip area) | `#FCF1EB` / `#F0E3DB` |
| Bordo tratteggiato (drop box) | `#D3A98E` |
| Container accento (badge/indicatore/chip) | `#FFDBCB` |
| Testo accento su container | `#3A0A00` |
| Testo primario | `#26211D` / `#221A15` |
| Testo secondario | `#6E5F57` / `#53433C` |
| Testo placeholder / muto | `#A7958C` / `#85736B` |
| Sfondo esterno (gradiente) | `#CDD2D8` → `#C2C7CE` |
| Snackbar bg / testo / icona | `#382E29` / `#FFEDE5` / `#FFB59B` |

**Chip tipizzati (dominio componenti/frasi)** — coppie container/testo:
| Tipo | Punto/accento | Container | On-container |
|---|---|---|---|
| Soggetto | `#3F5BA9` | `#DEE3FF` | `#00164F` |
| Verbo | `#C0432A` | `#FFDAD0` | `#3A0500` |
| Complemento | `#2E7D52` | `#C9EFD6` | `#00210F` |

### Tipografia
- **UI**: **Roboto Flex** (pesi 400/500/600/700) — corpo, titoli, label.
- **Monospace** (codice/ID/schema/video filename): **Roboto Mono** (400/500).
- Scala usata: 26 (titolo hero) · 22 (titolo barra) · 16 (titolo card) · 15 (chip/bottoni grandi) · 14/13.5 (bottoni, dropdown, body) · 13 (sottotitolo) · 12/11.5 (micro-label uppercase, kicker) · 11 (label rail) · 10 (contatore rail).
- Letter-spacing: titoli leggermente negativo (`-0.3`/`-0.4`); micro-label uppercase `+0.5`; kicker uppercase `+2`.

### Spaziatura & raggi
- Padding contenuto: `24/30px`. Padding card: `20px`. Gap tra box: `14–16px`.
- Raggi: pillole/campi `22`; card `22`; box interni `18`; drop box `16`; chip `11`; badge/indicatori `pill (≈18–30)`.
- Touch target ≥ 44–48.

### Ombre
- Card: `0 8px 24px rgba(40,30,22,0.06)`.
- Bottone primario: `0 4px 12px rgba(156,74,43,0.28)` (grande: `0 6px 16px`).
- Cerchi "+" drop box: `0 4px 10–12px rgba(156,74,43,0.28)`.
- Snackbar: `0 8px 24px rgba(0,0,0,0.28)`.

---

## SQLite Schema (sqflite)

```sql
-- Dizionario dei segni (parole tipizzate)
CREATE TABLE componenti (
  id     INTEGER PRIMARY KEY AUTOINCREMENT,
  parola TEXT NOT NULL,
  tipo   TEXT NOT NULL CHECK (tipo IN ('soggetto','verbo','complemento')),
  video  TEXT                       -- percorso file video del segno
);

-- Frasi (soggetto + verbo + complemento)
CREATE TABLE frasi (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  id_soggetto     INTEGER REFERENCES componenti(id),
  id_verbo        INTEGER REFERENCES componenti(id),
  id_complemento  INTEGER REFERENCES componenti(id),
  creato_il       TEXT DEFAULT (datetime('now'))
);

-- Strisce comunicative
CREATE TABLE strisce (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  nome      TEXT NOT NULL,
  creato_il TEXT DEFAULT (datetime('now'))
);
CREATE TABLE striscia_immagini (      -- immagini ordinate di una striscia
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  id_striscia INTEGER NOT NULL REFERENCES strisce(id) ON DELETE CASCADE,
  percorso    TEXT NOT NULL,          -- file su filesystem app
  ordine      INTEGER NOT NULL DEFAULT 0
);

-- Attività (raccolta immagini + 1 video)
CREATE TABLE attivita (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  nome      TEXT NOT NULL,
  video     TEXT,                     -- percorso video dimostrativo
  creato_il TEXT DEFAULT (datetime('now'))
);
CREATE TABLE attivita_immagini (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  id_attivita  INTEGER NOT NULL REFERENCES attivita(id) ON DELETE CASCADE,
  percorso     TEXT NOT NULL,
  ordine       INTEGER NOT NULL DEFAULT 0
);

-- Abbinamento striscia ↔ attività
CREATE TABLE abbinamenti (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  id_striscia INTEGER NOT NULL REFERENCES strisce(id) ON DELETE CASCADE,
  id_attivita INTEGER NOT NULL REFERENCES attivita(id) ON DELETE CASCADE,
  creato_il   TEXT DEFAULT (datetime('now'))
);
```

> Abilita `PRAGMA foreign_keys = ON;` all'apertura. I **media** (immagini/video) vanno salvati come file nella directory dell'app (`getApplicationDocumentsDirectory()`), memorizzando in DB solo il **percorso relativo**, non i blob.

**Seed dati** (dizionario componenti, presente nel prototipo): Io, Tu, Mamma, Bambino, Amico (soggetto); mangiare, bere, volere, giocare, leggere (verbo); casa, mela, libro, acqua, gelato, palla (complemento) — ognuno con `<parola>.mp4`.

---

## Assets
- **Icone**: tutte SVG stroke 2px stile "lucide/feather" (mano LIS, fumetto, checklist, documento, dashboard, foto, play, +, floppy, cestino, database, chevron, spunta). In Flutter usare un set equivalente (es. `lucide_icons` / `Icons` Material, o asset SVG via `flutter_svg`). L'icona-logo "mano" è l'unica brand-specific: ricrearla come asset SVG bianco su sfondo gradiente.
- **Font**: Roboto Flex + Roboto Mono (Google Fonts) — includere via `google_fonts` o bundlare i `.ttf`.
- **Media utente**: forniti a runtime dall'utente (image/video picker). Nessun asset immagine nel prototipo.

---

## Files
- `Segnami Admin Tablet.dc.html` — prototipo di riferimento completo (4 schermate + navigazione + stato + schema). Aprire in un browser per vedere look & feel e interazioni. (Richiede `support.js`, incluso nel progetto, solo per il rendering del prototipo — **non** è parte dell'app Flutter.)

> Nota: il prototipo HTML usa un runtime proprietario (`<x-dc>`, `support.js`) solo per il preview; in Flutter si ignora completamente e si reimplementa la UI con widget nativi seguendo questo documento.
