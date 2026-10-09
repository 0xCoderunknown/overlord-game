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
3. Follow the code formatting conventions:
   - Run `flutter format .`
   - Ensure `flutter analyze` passes with zero issues.
   - Run `flutter test` to ensure all tests pass.
4. Commit your changes with clear, descriptive commit messages.
5. Push to your fork and submit a Pull Request.

## Local Development Workflow

```bash
# Clone the repository
git clone https://github.com/0xCoderunknown/overlord-game.git
cd overlord-game

# Fetch dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run unit and widget tests
flutter test

# Run the app locally
flutter run
```

## Code Style & Guidelines
- Follow standard [Effective Dart](https://dart.dev/effective-dart) practices.
- Keep dependencies minimal to maintain privacy and offline capability (no ad SDKs, analytics, or dynamic font fetchers).
- Maintain documentation comments where appropriate.
