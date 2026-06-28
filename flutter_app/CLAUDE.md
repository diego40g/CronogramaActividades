# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Context

This Flutter app is part of **CronogramaActividades**, a task/schedule management system with a timeline UI (Structured-style) and task management (TickTick-style), Google Calendar sync, and Firebase backend.

**Monorepo structure:**
- `flutter_app/` - Mobile app (Android/iOS) - this project
- `angular_app/` - Web dashboard
- `firebase/` - Firestore rules, indexes, Cloud Functions
- `shared/` - TypeScript interfaces for Firestore schema

## Commands

```bash
# Development environment (from monorepo root)
nix develop                     # Enter Nix shell with Flutter, Android SDK, JDK17

# Flutter commands (from flutter_app/)
flutter pub get                 # Install dependencies
flutter run                     # Run on connected device/emulator
flutter run -d chrome           # Run on web
flutter build apk               # Build Android APK
flutter build ios               # Build iOS (requires macOS)

# Testing and analysis
flutter test                    # Run widget tests
flutter test test/widget_test.dart  # Run single test file
flutter analyze                 # Run linter (flutter_lints rules)

# Firebase emulators (from firebase/functions/)
firebase emulators:start        # Start local emulators
```

## Architecture

**Current state:** Minimal Flutter template with counter demo. No architecture pattern implemented yet.

**Firestore data model (to be integrated):**
```
users/{uid}
  └─ tasks/{taskId}
       └─ subtasks/{subtaskId}
  └─ tags/{tagId}
  └─ timeBlocks/{blockId}
```

See `shared/schema/` for TypeScript interfaces that define the data model.

## Platform Configuration

- **Android:** Package `com.example.flutter_app`, Kotlin 2.2.20, JDK 17, AGP 8.11.1
- **iOS:** Bundle `com.example.flutterApp`
- **Web:** PWA-capable with service worker

## Environment

The project uses a Nix flake (`flake.nix` at monorepo root) for reproducible development:
- Flutter/Dart SDK
- Android SDK (API 34-36) with emulator
- JDK 17
- Auto-installs Angular CLI and Firebase CLI via npm
- Configures AAPT2 override for NixOS compatibility
