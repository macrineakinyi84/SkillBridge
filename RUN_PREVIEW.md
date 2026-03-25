# How to run the SkillBridge preview

Flutter wasn’t found because it’s either not installed or not on your **PATH**. Use one of the options below.

---

## Find Flutter on your PC (run this first)

In **PowerShell**, run this to search for `flutter.bat` (may take a minute):

```powershell
Get-ChildItem -Path C:\ -Filter flutter.bat -Recurse -ErrorAction SilentlyContinue -Depth 5 | Select-Object -First 3 FullName
```

If it finds a path like `C:\Users\Awuor\AppData\Local\flutter\bin\flutter.bat`, your **bin** folder is `C:\Users\Awuor\AppData\Local\flutter\bin`. Use that in the commands below.

To search only your user folder (faster):

```powershell
Get-ChildItem -Path $env:USERPROFILE -Filter flutter.bat -Recurse -ErrorAction SilentlyContinue | Select-Object -First 3 FullName
```

---

## Option A: Flutter is already installed

If you’ve installed Flutter before, find the folder that contains `flutter.bat` (often one of these):

- `C:\flutter\bin\`
- `C:\src\flutter\bin\`
- `%USERPROFILE%\flutter\bin\`
- `%USERPROFILE%\development\flutter\bin\`

### Run using the full path

In PowerShell, use the path where **your** Flutter is (replace with your actual path):

```powershell
cd c:\Users\Awuor\SkillBridge
& "C:\flutter\bin\flutter.bat" run -d chrome
```

If Flutter is in another folder, e.g. `C:\src\flutter\bin\`:

```powershell
& "C:\src\flutter\bin\flutter.bat" run -d chrome
```

### Or add Flutter to PATH (permanent)

1. Press **Win + R**, type `sysdm.cpl`, Enter.
2. **Advanced** tab → **Environment Variables**.
3. Under **User variables**, select **Path** → **Edit** → **New**.
4. Add the **bin** folder, e.g. `C:\flutter\bin` (no `flutter.bat`, just the folder).
5. OK out, **close and reopen** PowerShell (or Cursor).
6. Then run:
   ```powershell
   cd c:\Users\Awuor\SkillBridge
   flutter run -d chrome
   ```

---

## Option B: Install Flutter (if not installed)

1. **Download:** https://docs.flutter.dev/get-started/install/windows  
   Or direct: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_*.zip  

2. **Unzip** to a folder without spaces, e.g. `C:\flutter` (so you get `C:\flutter\bin\flutter.bat`).

3. **Add to PATH** (same steps as in Option A, add `C:\flutter\bin`).

4. **First run** (in a new PowerShell):
   ```powershell
   flutter doctor
   ```
   Fix any issues it reports (e.g. accept Android licenses, install Chrome).

5. **Run the app:**
   ```powershell
   cd c:\Users\Awuor\SkillBridge
   flutter pub get
   flutter run -d chrome
   ```

---

## If the project has no platform folders

If you see errors about missing `android/` or `ios/`:

```powershell
flutter create . --org com.skillbridge
flutter run -d chrome
```

---

## Quick test: find Flutter on your PC

In PowerShell you can search for `flutter.bat` (run from a folder you have access to, e.g. `C:\`):

```powershell
Get-ChildItem -Path C:\ -Filter flutter.bat -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 FullName
```

Use the folder that contains `flutter.bat` (the `bin` folder) as the path in the commands above.
