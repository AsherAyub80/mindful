# 🌿 MindfulMeals – Flutter App

AI-powered mindful meal planning app with glassmorphism UI.

## Screens
- **Home** — Mood selector, AI meal suggestions, streak tracker
- **Recipe** — Ingredients & step-by-step cooking with checkable steps
- **AR View** — Animated surface scan & 3D dish preview
- **Community** — Stories, trending feed, like/save/share
- **Profile** — Stats, nutrition bars, preference toggles

## Design
- Glassmorphism: `BackdropFilter` frosted glass cards
- Neumorphic buttons with animated press states
- Radial ambient blobs for depth
- Playfair Display + DM Sans typography
- Deep teal/emerald palette on dark background

## Quick Start

### Prerequisites
- Flutter SDK ≥ 3.0.0 — https://flutter.dev/docs/get-started/install
- Android Studio or Xcode (for simulators)

### Run
```bash
cd mindful_meals
flutter pub get
flutter run
```

### Build APK (Android)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build for iOS
```bash
flutter build ios --release
# Open ios/Runner.xcworkspace in Xcode to archive
```

## Project Structure
```
lib/
├── main.dart              # Entry point + MainShell navigation
├── theme/
│   └── app_colors.dart    # Color palette & gradients
├── models/
│   └── app_data.dart      # Data models & static content
├── widgets/
│   └── glass_widgets.dart # GlassCard, NeuButton, GlassChip, AmbientBlob
└── screens/
    ├── home_screen.dart
    ├── recipe_screen.dart
    ├── ar_screen.dart
    ├── community_screen.dart
    └── profile_screen.dart
```

## Dependencies
| Package | Purpose |
|---|---|
| `google_fonts` | Playfair Display + DM Sans |
| `flutter_svg` | SVG rendering |
| `percent_indicator` | Progress indicators |
| `smooth_page_indicator` | Page dots |
| `lottie` | Animation support |
