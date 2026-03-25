# Add SHA-1 for Android (Firebase)

Firebase needs your app’s **SHA-1 fingerprint** before it can give you the latest Android config (and for Google Sign-in). Add it once, then download or refresh `google-services.json`.

---

## 1. Get your SHA-1

### Option A: Using Gradle (recommended)

In PowerShell, from the **project root** (SkillBridge folder):

```powershell
cd c:\Users\Awuor\SkillBridge
.\android\gradlew -p android signingReport
```

Or with full path to gradlew:

```powershell
cd c:\Users\Awuor\SkillBridge\android
.\gradlew signingReport
```

In the output, find **Variant: debug** (or release) and copy the **SHA1** line, e.g.:

```
SHA1: AA:BB:CC:DD:...
```

### Option B: Using keytool (if you have Java)

Debug keystore (default for `flutter run`):

```powershell
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Copy the **SHA1** value from the output.

---

## 2. Add SHA-1 in Firebase

1. Open [Firebase Console](https://console.firebase.google.com) → your project.
2. Click the **gear** → **Project settings**.
3. Scroll to **Your apps**.
4. Click your **Android** app (`com.skillbridge.skillbridge`).
5. Find **SHA certificate fingerprints** → **Add fingerprint**.
6. Paste your SHA-1 (e.g. `AA:BB:CC:DD:...`) → Save.

---

## 3. Download the config again

After saving the SHA-1:

- In the same “Download latest configuration file” dialog, the Android app should allow **download** of `google-services.json`.
- Download it and **replace** the file at:
  **`android/app/google-services.json`**

---

## 4. iOS / macOS

In that dialog you can **download** **GoogleService-Info.plist** now. Put it in **`ios/Runner/`** and add it to the Runner target in Xcode (so it’s in the app bundle).

---

**Note:** SHA-1 is required for Google Sign-in and for Firebase to offer the latest Android config. For **Email/Password** only, a previously downloaded `google-services.json` may still work, but adding SHA-1 and using the latest config is recommended.
