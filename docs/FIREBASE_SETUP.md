# SkillBridge – Firebase setup (Flutter)

You don’t add the “Firebase SDK” manually like in native Android or web. In **Flutter** the SDK is the packages in `pubspec.yaml`. This doc shows what’s already done and what you might still need.

---

## 1. Firebase SDK in Flutter = already in the project

The Firebase “SDK” in this project is these packages in **`pubspec.yaml`**:

- `firebase_core` – connects the app to Firebase
- `firebase_auth` – sign in / sign up / sign out
- `cloud_firestore` – database (for later)

They are already listed. You do **not** need to:

- Add Gradle dependencies for Firebase in Android
- Add `<script>` tags or npm packages for web
- Download any extra SDK

Running `flutter pub get` is enough. **No extra “add Firebase SDK” step in the app code.**

---

## 2. What’s already done in SkillBridge

| Step | Status |
|------|--------|
| Firebase packages in `pubspec.yaml` | Done |
| `firebase_options.dart` (from FlutterFire CLI) | Done |
| `main.dart` calls `Firebase.initializeApp(options: ...)` | Done |
| Android: Google Services plugin in Gradle | Done |
| Web / iOS: configured in Firebase Console | You said done |

---

## 3. What you might still need

### If you run on **Web (Chrome)**

- Firebase project has a **Web** app and you ran `flutterfire configure` and selected **web**.
- Then `lib/firebase_options.dart` includes web. Nothing else to “add” in the app.

### If you run on **Android**

1. **Firebase Console**  
   - Your project → Add app → **Android**  
   - Package name: **`com.skillbridge.skillbridge`**  
   - Download **`google-services.json`**

2. **Put the file in the app**  
   - Path: **`android/app/google-services.json`**  
   - Same folder as `android/app/build.gradle.kts`.

3. **Regenerate options (optional but useful)**  
   - Run:  
     `& "$env:LOCALAPPDATA\Pub\Cache\bin\flutterfire.bat" configure`  
   - Select **Android** (and Web/iOS if you want).  
   - This updates `lib/firebase_options.dart` for Android. No need to “add Firebase SDK” anywhere else.

### If you run on **iOS** (on a Mac)

- Add an **iOS** app in Firebase, download **`GoogleService-Info.plist`**, put it in **`ios/Runner/`** and add it in Xcode.  
- Run `flutterfire configure` and select **iOS** so `firebase_options.dart` has iOS.

---

## 4. Summary: “Add Firebase SDK” in this project

- **In Flutter:** the SDK is the `firebase_core`, `firebase_auth`, and `cloud_firestore` packages. They are already in the project; no extra “add SDK” step.
- **In Firebase Console:** you “add” **apps** (Web, Android, iOS), not the SDK inside the app.
- **In the app:** you only need:
  - `firebase_options.dart` (from `flutterfire configure`)
  - `google-services.json` in `android/app/` for Android
  - `GoogleService-Info.plist` in `ios/Runner/` for iOS

If you’re stuck, say whether you’re on **Web**, **Android**, or **iOS** and what you see (e.g. which screen or error), and we can do the next step for that platform only.

---

## 5. All three apps added – checklist

You’ve added Web, Android, and iOS in Firebase. Do this so the Flutter app works on all of them:

### Step A: Regenerate Firebase options (required)

Right now `lib/firebase_options.dart` only has macOS. Regenerate it so it includes **web**, **android**, and **ios**:

```powershell
cd c:\Users\Awuor\SkillBridge
& "$env:LOCALAPPDATA\Pub\Cache\bin\flutterfire.bat" configure
```

- Select your Firebase project.
- When asked which platforms to use, enable **Web**, **Android**, and **iOS** (and macOS if you want).
- Finish. This overwrites `lib/firebase_options.dart` with config for all selected platforms.

### Step B: Enable Email/Password sign-in (required for login)

1. Open [Firebase Console](https://console.firebase.google.com) → your project.
2. Go to **Build** → **Authentication** → **Sign-in method**.
3. Click **Email/Password**, turn **Enable** on, Save.

Without this, sign in and sign up will fail.

### Step C: Config files in the project

| Platform | File | Where |
|----------|------|--------|
| Android | `google-services.json` | `android/app/google-services.json` (you have this) |
| iOS | `GoogleService-Info.plist` | Download from Firebase → iOS app → put in `ios/Runner/` and add to Xcode project |

### Step D: Run the app

- **Web:** `flutter run -d chrome`
- **Android:** Start emulator or connect device, then `flutter run -d android` or `flutter run`
- **iOS:** On a Mac, `flutter run -d ios` (after adding `GoogleService-Info.plist`)

After Step A and B, Web and Android can use real sign-in. iOS needs the plist file (Step C) and a Mac to run.
