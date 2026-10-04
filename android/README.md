# Android-App

WebView-Hülle um `../web` (Assets werden lokal eingebunden, läuft offline, keine Domain nötig).

Build: `ANDROID_HOME=… gradle :app:bundleRelease` → `app/build/outputs/bundle/release/app-release.aab`
Signierung über `keystore.properties` (nicht im Repo). `stimmig-1.1.aab` ist das fertige, signierte Upload-Paket.
Für Updates `versionCode` in `app/build.gradle.kts` erhöhen.
