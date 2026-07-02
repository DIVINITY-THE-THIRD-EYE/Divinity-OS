# App Signing & Transport Security

How the Divinity apps are signed for release, and the transport-security posture.
Nothing secret lives in git — keystores and `key.properties` are git-ignored.

---

## Android signing (already wired)

**Status (verified 2026-07-02): steps 1–2 below are already done.** An upload
keystore exists at `android/app/upload-keystore.jks` with a matching
`android/key.properties` (both git-ignored, not committed). The corresponding
secrets (`ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`,
`ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`) are set in GitHub Actions on
`DIVINITY-THE-THIRD-EYE/Divinity-OS` (confirmed via `gh secret list`). CI can
already build a signed AAB. What's still missing is a Play Console app listing
to actually publish it (see the root [`docs/VERIFIED_AUDIT_2026-07-02.md`](../../docs/VERIFIED_AUDIT_2026-07-02.md), item O8).

`android/app/build.gradle.kts` reads `android/key.properties` and applies a
`release` signing config; if `key.properties` is absent it falls back to debug
signing (so CI / fresh clones still build). To (re)produce a **store-ready** release:

### 1. Generate an upload keystore (one time)

```bash
keytool -genkey -v \
  -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

(Windows / PowerShell: same command on one line, `keytool` ships with the JDK.)
Keep the resulting `.jks` somewhere safe and backed up — losing it means you can
**never** update the app under the same listing.

### 2. Create `key.properties`

Copy `android/key.properties.example` → `android/key.properties` and fill in the
passwords, `keyAlias` (`upload`), and `storeFile` (`upload-keystore.jks`).

### 3. Build

```bash
flutter build appbundle --release   # Play Store (.aab)
flutter build apk --release         # direct distribution (.apk)
```

### What's protected

- `key.properties` → git-ignored.
- `**/*.jks`, `**/*.keystore` → git-ignored.
- Verify any time: `git check-ignore android/key.properties` should print the path.

> If you use Play App Signing (recommended), this keystore is your **upload** key;
> Google holds the app-signing key. Register the upload key's SHA in the Play
> Console and in Firebase (for FCM / OAuth) so deep links and auth keep working.

---

## iOS signing (requires macOS + Apple Developer account)

iOS code-signing can't be done on this Windows machine — it needs Xcode and a
paid Apple Developer account. On a Mac:

1. In Xcode, open `ios/Runner.xcworkspace`.
2. Signing & Capabilities → select your **Team**, set a unique **Bundle ID**
   (e.g. `com.divinity.thethirdeye`), enable **Automatically manage signing**.
3. Add the deep-link URL scheme (`io.supabase.divinity`) under URL Types to match
   the Android `AndroidManifest.xml` Supabase callback.
4. Build: `flutter build ipa --release`, then upload via Xcode Organizer or
   `xcrun altool` / Transporter.

> Provisioning profiles and the distribution certificate live in your Apple
> account / Keychain — do not commit them.

---

## Transport security

- **Website**: HTTPS is terminated by Vercel (auto-managed TLS + HSTS, see
  `next.config.mjs`). No certificate work needed.
- **App (Android)**: `res/xml/network_security_config.xml` enforces TLS for all
  production traffic (cleartext allowed only for local-dev backends). Supabase and
  Firebase are HTTPS-only.
- **Certificate pinning**: intentionally **not** enabled — Supabase/Firebase rotate
  their managed certificates, and a pinned client would brick on rotation. The
  rationale and a safe approach (pin an intermediate + ship a kill-switch) are
  documented inline in `network_security_config.xml`.
