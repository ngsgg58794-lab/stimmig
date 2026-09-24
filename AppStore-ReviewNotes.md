# App Review – Antwort auf Guideline 2.1 (Information Needed)

Text unten (Englisch) 1:1 in **beide** Stellen kopieren:
1. Antwort im Resolution Center (App Store Connect → App Review → Nachricht)
2. App Store Connect → Version 1.0 → **App-Review-Informationen → Notizen**
   (Limit 4000 Zeichen – Text passt)

"Anmeldung erforderlich" in den App-Review-Informationen: **deaktiviert** lassen.

Bildschirmaufnahme separat anhängen (siehe Checkliste unten).

---

```
Thank you for the review. Please find the requested information below. A screen recording captured on a physical iPhone running the latest iOS is attached to this reply.

1. SCREEN RECORDING
The attached recording starts with launching the app from the Home Screen and shows the complete user flow: start screen -> selecting a core feeling on the wheel -> refining it in two further steps -> result screen with optional note -> saving the entry -> opening the journal -> deleting an entry.
The app has NO account registration/login (so no account deletion is needed), NO user-generated content shared with other users, and NO paid content or In-App Purchases.

2. PURPOSE AND TARGET AUDIENCE
stimmig is a self-reflection tool based on the concept of a "feelings wheel". Many people can only describe how they feel as "good" or "bad". The app guides the user in three short steps from a broad core feeling (e.g. "sad") to a more precise word (e.g. "lonely"), which helps with emotional awareness and self-reflection. Users can add a short private note and save the result to a local journal to look back on later.
Target audience: adults and teenagers interested in mindfulness, journaling and self-reflection. The app is not a medical device, does not diagnose or treat any condition and makes no health claims.

3. SETUP AND ACCESS
No login, account, credentials, sample files or internet connection are required. All features are available immediately after launch:
- Start screen: tap "Los geht's" (Let's go).
- Step 1: tap a core feeling in the center of the wheel.
- Step 2 and 3: tap a more specific feeling, then the precise word ("‹ zurück" = back).
- Result screen: optionally type a note, then tap "Im Tagebuch speichern" (Save to journal). "Nochmal fühlen" starts over.
- Journal: tap "Tagebuch" (book icon) in the top bar. Each entry can be deleted with the "x" button on the entry.
All data is stored only locally on the device (a file in the app's Documents directory) and is removed when the app is deleted.

4. EXTERNAL SERVICES
None. The app uses no backend, no authentication service, no payment processor, no analytics, no advertising SDKs and no AI services. It makes no network requests. It is built exclusively with Apple frameworks (SwiftUI, Foundation).

5. REGIONAL DIFFERENCES
None. The app functions identically in all regions. The user interface and content are in German.

6. REGULATED INDUSTRY / THIRD-PARTY MATERIAL
Not applicable. The app does not operate in a regulated industry and provides no medical, financial or legal services. It contains no protected third-party material; all texts, the emotion vocabulary, the design and the icon were created by the developer.
```

---

## Checkliste Bildschirmaufnahme (selbst machen, echtes iPhone, aktuelles iOS)

1. Kontrollzentrum → Bildschirmaufnahme hinzufügen (Einstellungen → Kontrollzentrum).
2. App vorher **löschen und frisch aus TestFlight installieren** (zeigt leeren Zustand).
3. Aufnahme starten → Home-Screen → **App-Icon antippen** (Aufnahme muss mit dem Start beginnen).
4. Ablauf: Start → Grundgefühl → Verfeinerung → Wort → Notiz tippen → Speichern.
5. Zweiten Durchlauf mit anderem Gefühl, speichern.
6. Tagebuch öffnen → Einträge zeigen → **einen Eintrag löschen**.
7. Aufnahme stoppen. Länge ca. 1–2 Min. reicht.
8. Als .mov/.mp4 an die Antwort im Resolution Center anhängen (Limit beachten; ggf. vorher in Fotos kürzen).

## Offene Punkte / Risiken

- Punkt 6 im Text behauptet: Gefühls-Vokabular selbst erstellt. Falls die Wortliste
  von einem bestehenden Gefühlsrad (z. B. Gloria Willcox "The Feeling Wheel")
  übernommen/übersetzt wurde: Satz anpassen ("inspired by the widely used
  feelings wheel concept; the German wording was created by the developer").
  Nicht falsch angeben.
