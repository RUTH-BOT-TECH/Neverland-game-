# Android test builds

## First sideload preview

`/home/user/Five_Missing_Orbs_Test.apk` is a separately supplied debug preview of the current project, not the final game or a Play Store release. It was exported with Godot 4.6.3's Android debug template, before the introductory quest was implemented. The current workspace has newer quest code that is not in this APK. The APK has package ID `com.eldoriapreview.fivemissingorbs`, min Android API 24 (Android 7.0) and ARM 32-bit/64-bit native libraries. Compatibility renderer requires OpenGL ES 3.0. The archive and signature were verified on Linux with `aapt`, `zipalign` and `apksigner`; **it has not been installed or run on an Android device**.

To test: download the APK to the phone, open it from Downloads, and if prompted allow installing apps from that specific trusted browser or file manager. Open **Five Missing Orbs Preview**, walk towards Mira and tap TALK. Report device model, Android version, whether the app installs and launches, performance, and control or visual problems. Play Protect might warn about a debug app installed outside the Play Store. Do not disable device security globally. This preview is offline and does not contain multiplayer, quests, or the final game.

## Preview signing and updates

The preview uses a debug signing key at `/home/user/preview_build_tools/preview-debug.keystore`. It is for development only, is not secret, and must **never** be reused as a commercial release or Play Store signing key. It is deliberately outside the game-project folder. Keep using it for future preview versions with the same package ID, otherwise Android will reject updates and a prior preview must be uninstalled (removing its app data). For a real release, the owner should create and securely back up their own distinct release signing key.

`export_presets.cfg` contains a minimal Android Preview preset without private keys or machine-specific paths. The exporter needs matching export templates, an Android SDK, a Java SDK, and a debug key. The temporary SDK and templates used for the first build are not bundled with the project.

## Godot 4.6.3 manifest workaround

The stock non-Gradle exporter changed both AndroidX InitializationProvider and FileProvider authorities to the same value. Before distribution the preview was patched, aligned and re-signed. The workspace helper `/home/user/preview_build_tools/patch_godot_manifest.py` updates the startup provider's authority to a distinct, equal-length string in binary AXML. For a subsequent export, verify the manifest first; if the duplicate remains, patch the unsigned result, run `zipalign -f -P 16 4`, sign with Android build-tools `apksigner` using the preview debug key, then verify the signature and inspect both provider authorities. Do not silently distribute the unpatched APK. Re-evaluate the workaround when updating Godot or switching to Gradle; the helper intentionally asserts its assumptions and fails if the manifest format changes.
