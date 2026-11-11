# GitHub setup and preview update plan

## Status

The update checker is configured for the public repository `RUTH-BOT-TECH/Neverland-game-`, with build number 2. The repository was found public and empty when setup began. No end-to-end Android update flow has been tested. Arena's GitHub connector is unavailable; use an explicitly authorised workflow for repository operations. Never send passwords, personal access tokens, or signing keys in chat.

## Preparing the repository on a phone

1. Sign in or create a GitHub account. Create a new repository with a name of your choice. For a no-login update checker, it needs to be public; a public repository and public releases can be seen/downloaded by anyone. Initialise it with a README so that a first commit exists. Share only the public repository URL (for example, the URL shown on the repository home page).
2. The source project can be uploaded later through a Git client on Android. Do not upload build caches or signing credentials. `.gitignore` already excludes `.godot/`, APKs, AABs, keystores and common secret files; it does not remove anything previously committed.
3. To publish a preview APK, open the repository's **Releases** page → **Draft a new release**. Create a tag following `preview-N`, e.g. `preview-2`; N must match both `version/code` in `export_presets.cfg` and `current_build_number` in `resources/settings/update_config.tres` at build time. Attach the signed APK as `Five_Missing_Orbs_Test.apk` and publish the release. Pre-releases are supported; drafts are ignored. Each subsequent preview must use a higher number. If no expected APK is attached, the app will ignore that release. GitHub Releases are versioned packages and their stated per-file limit is under 2 GiB: https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases.
4. The GitHub page must contain the **newly built** preview APK. Publishing, uploading and signing do not happen automatically just because the project is on GitHub. A CI pipeline can be added and tested later; none is configured now.

## Enabling update checks in a future build

The current values are set to `enabled = true`, owner `RUTH-BOT-TECH`, and repository `Neverland-game-` in `res://resources/settings/update_config.tres`. The owner and repository fields must contain the actual names without URLs, slashes, or credentials. The current workspace is set to build number 2; the previously distributed APK is build 1 and has no update checker. The user must install a newly built APK once before the checker can run.

When enabled, the game requests GitHub's public releases API once at startup (10-second timeout, 256 KiB response cap), looks through up to 20 releases for valid `preview-N` tags with the expected APK, and shows the newest higher build number. Offline errors and rate limiting do not block play. The app opens only a validated GitHub release page in the phone's browser. The user chooses the APK to download and must approve Android's installer; it is **not** a silent install or an automatic APK download. Data charges may apply, and full APK downloads can be large. The checker uses the public API and stores no account credentials.

Always sign updates with the **same preview signing key and package ID**, and increase Android version code. Android normally rejects an update with a different signer. The current preview debug key is kept separately in `/home/user/preview_build_tools/preview-debug.keystore`; it is development-only and must never be used for production. Never upload it to a public repo. A production app needs a separate owner-controlled release key backed up securely.

The Android preset includes the internet permission for future update checks. When the checker is disabled, it sends no update-check request. The public repository name is in the build, but no access token or signing key is included.

## Verification checklist

- Before any real release: review the source and third-party licenses, ensure no secret files are tracked, and verify all tests.
- The Godot 4.6.3 non-Gradle Android exporter may duplicate provider authorities. See `TEST_BUILDS.md` and `tools/patch_godot_manifest.py`; inspect, patch if needed, zipalign, re-sign, and verify the result.
- Confirm Android package ID, version code, and signing certificate match the installed preview, and that the downloadable APK is exactly the tested one.
- Publish a higher numbered tag with the correctly named asset. Test on an Android phone: open older checker-enabled build online, tap Open update, download and approve installation, then verify the new version starts. Also test offline mode and reject wrong-key updates. This end-to-end flow is not yet tested.
