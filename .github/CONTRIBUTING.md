# Contributing to Overlord

Thank you for your interest in contributing to **Overlord**! We welcome bug reports, gameplay ideas, documentation updates, and pull requests.

## How to Contribute

### 1. Reporting Bugs
- Search existing issues to ensure the bug hasn't already been reported.
- If not found, open an issue using the **Bug Report** template.
- Include reproduction steps, device info (Android version/model), and any terminal logs if applicable.

### 2. Suggesting Features & Content
- Open an issue using the **Feature Request** template.
- New weapons, armor, enemies, or wasteland lore encounters can easily be contributed to `lib/content/` (`item_database.dart`, `incident_database.dart`, `lore_database.dart`).

### 3. Pull Requests
1. Fork the repository.
2. Create a new topic branch: `git checkout -b feature/my-feature`.
3. Verify your changes pass all invariant gates:
   - Run `dart format .`
   - Run `dart run tool/verify_invariants.dart` (enforces formatting, <400 line limits, offline pledge, zero analyze warnings, and 100% test pass rate).
4. Commit your changes with clear, descriptive commit messages.
5. Push to your fork and submit a Pull Request.

## Local Development Workflow

```bash
# Clone the repository
git clone https://github.com/0xCoderunknown/overlord-game.git
cd overlord-game

# Fetch dependencies
flutter pub get

# Run automated invariant gate
dart run tool/verify_invariants.dart

# Run the app locally
flutter run
```

## Code Style & Guidelines
- Follow standard [Effective Dart](https://dart.dev/effective-dart) practices.
- Keep dependencies minimal to maintain privacy and offline capability (no ad SDKs, analytics, or dynamic font fetchers).
- Maintain documentation comments where appropriate.
