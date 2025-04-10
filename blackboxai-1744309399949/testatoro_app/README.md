# Testa Toro WebView App

A Flutter application that provides a WebView interface for the Testa Toro website.

## Features

- WebView integration for Testa Toro website
- Navigation controls (back, forward, home, cart)
- Pull-to-refresh functionality
- Share button
- External link handling
- Loading indicator

## Getting Started

### Prerequisites

- Flutter (latest stable version)
- Xcode (for iOS build)
- Android Studio (for Android build)

### Installation

1. Clone the repository
```bash
git clone [your-repository-url]
```

2. Install dependencies
```bash
flutter pub get
```

3. For iOS, install pods
```bash
cd ios && pod install
```

### Building

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

## CI/CD

This project includes configurations for both GitHub Actions and Codemagic:

- GitHub Actions: Automated builds for both Android and iOS
- Codemagic: Configured for both platforms with proper signing and distribution setup

## Environment Setup

### iOS
- Minimum iOS version: 12.0
- Requires Xcode 12.0 or later

### Android
- Minimum SDK: 19
- Target SDK: 33
