# See a preview of SkillBridge

Run these in PowerShell from the project folder.

---

## 1. Get dependencies

```powershell
cd c:\Users\Awuor\SkillBridge
flutter pub get
```

---

## 2. (Optional) Enable real login on Web

Right now `firebase_options.dart` only has macOS. To use **real** sign-in in Chrome:

```powershell
& "$env:LOCALAPPDATA\Pub\Cache\bin\flutterfire.bat" configure
```

- Select your Firebase project.
- When asked which platforms, enable **Web** (and Android if you want).
- Finish.

Also in [Firebase Console](https://console.firebase.google.com): **Authentication** → **Sign-in method** → **Email/Password** → Enable.

If you skip this, the app still runs and you’ll see the full UI, but sign-in will show “Firebase is not configured.”

---

## 3. Run the app

**In Chrome (easiest):**

```powershell
flutter run -d chrome
```

**On Windows (desktop):**

```powershell
flutter run -d windows
```

**On Android (emulator or device):**

Start the emulator, then:

```powershell
flutter run -d android
```
or
```powershell
flutter run
```

---

You’ll see the **login screen** first. After signing in (or with stub auth), you’ll see the **Smart Skills dashboard** (readiness score, skills, portfolio count, recommendations).
