# TrustGuard Flutter App

AI-powered content moderation frontend built in Flutter.
Runs on **Web**, **Android**, **iOS**, **macOS**, **Windows**, and **Linux**.

---

## Project Structure

```
lib/
├── main.dart                  # App entry, shell navigation
├── theme.dart                 # Colors, typography
├── models/
│   └── analysis.dart          # ScanRecord, AnalysisResult models
├── services/
│   ├── api_service.dart       # POST /analyze → Go backend
│   └── history_service.dart   # LocalStorage via shared_preferences
├── widgets/
│   └── shared.dart            # Logo, Navbar, Footer, Badges, TrustScoreBar
└── screens/
    ├── home_screen.dart        # Landing page with hero + features
    ├── detect_screen.dart      # Threat detector input + results
    └── history_screen.dart     # Scan history with expand/collapse
```

---

## Setup

### 1. Install Flutter
https://docs.flutter.dev/get-started/install

### 2. Get dependencies
```bash
cd trustguard
flutter pub get
```

### 3. Run on Web
```bash
flutter run -d chrome
```

### 4. Run on Android
```bash
flutter run -d android
```

### 5. Build for Web (production)
```bash
flutter build web
# Output in build/web/ — deploy anywhere (Vercel, Netlify, Firebase Hosting)
```

### 6. Build APK for Android
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## API Configuration

The backend URL is set in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://localhost:8080';
```

**For production**, change this to your deployed backend URL:
```dart
static const String baseUrl = 'https://your-api.com';
```

**For Android emulator** (connecting to localhost on your machine):
```dart
static const String baseUrl = 'http://10.0.2.2:8080';
```

**For physical Android device** (on same WiFi):
```dart
static const String baseUrl = 'http://192.168.x.x:8080';
```

---

## CORS (Web)

Your Go/Gin backend already has CORS enabled. If you hit CORS issues in the browser, make sure the backend allows `http://localhost:PORT` as an origin.

---

## Features

- ✅ Home page with hero, stats, feature grid
- ✅ Detect page with Text/URL tabs, analysis form
- ✅ Results display: toxicity badge, spam badge, animated trust score bar, summary
- ✅ History page with expand/collapse cards, clear all
- ✅ Persistent history via `shared_preferences`
- ✅ Loading state with spinner
- ✅ Error handling (network errors, API errors, empty input)
- ✅ Hover states and smooth animations
- ✅ Pixel-perfect match to the design screenshots
