# Flutter Commands

Run these commands from the project root.

## Setup

```powershell
flutter doctor
flutter pub get
```

If needed, create `config\cloudinary.local.json` from the example file and add
your Cloudinary cloud name and unsigned upload preset:

```powershell
Copy-Item config\cloudinary.example.json config\cloudinary.local.json
```

## Run the app

```powershell
flutter devices
flutter run -d DEVICE_ID --dart-define-from-file=config/cloudinary.local.json
```

Replace `DEVICE_ID` with the ID shown by `flutter devices`. Connect your phone
with USB debugging enabled. Flutter installs a debug app once, then applies
code changes without manually rebuilding and reinstalling an APK:

- Press `r` in the running terminal for hot reload.
- Press `R` for hot restart if hot reload is not enough.
- Press `q` to stop the app.

You can also select **Kayra Craft (local Cloudinary)** in VS Code's Run and
Debug panel and use **Start Debugging**. Changes to the Cloudinary config or
native Android files require a full stop and run again.

## Check and test

```powershell
flutter analyze
flutter test
```

Run only the Cloudinary uploader tests:

```powershell
flutter test test/cloudinary_image_uploader_test.dart
```

## Build an Android debug APK

```powershell
flutter build apk --debug --dart-define-from-file=config/cloudinary.local.json
```
