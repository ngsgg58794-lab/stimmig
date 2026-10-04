# Android (TWA) – Ablauf

1. PWA unter HTTPS hosten (Ordner `web/`, siehe `.github/workflows/pages.yml`).
   **Wichtig:** Eine TWA braucht `/.well-known/assetlinks.json` im **Domain-Root**.
   `https://<user>.github.io/stimmig/` geht daher nicht – eigene Domain
   (z. B. app.juliawimmer.de) oder Repo `<user>.github.io` verwenden.
2. Paket bauen: `npx @bubblewrap/cli init --manifest https://<domain>/manifest.webmanifest`
   dann `npx @bubblewrap/cli build` (erzeugt .aab + Signing-Key – Key sichern!).
3. In der Play Console „Play App Signing" aktivieren, SHA-256 des
   App-Signing-Zertifikats nach `web/.well-known/assetlinks.json` eintragen
   (Vorlage: `assetlinks.json.example`).
4. .aab hochladen, Store-Eintrag, Datenschutz-URL, Data-Safety-Formular
   (keine Daten erhoben/geteilt), Content-Rating. Neue persönliche Konten:
   erst 12 Tester über 14 Tage im Closed Test, dann Produktion.
