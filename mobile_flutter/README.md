# QhewTek Waiter App

This Flutter app is the waiter-facing companion for the QhewTek ordering system.

## Local run

From this folder:

```powershell
flutter pub get
flutter run
```

Default development API behavior:

- Android emulator -> `http://10.0.2.2:8000/api`
- iOS simulator, desktop, and Flutter web -> `http://127.0.0.1:8000/api`

## Point the app to a hosted backend

You can now override the API URL at build time:

```powershell
flutter run --dart-define=API_BASE_URL=https://your-domain.com/api
```

Release example:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://your-domain.com/api
```

Main app entry:

- [lib/main.dart](./lib/main.dart)

For full stack setup and deployment steps, see the root [README.md](../README.md).
