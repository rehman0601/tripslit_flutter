# TripSplit 💸

A cross-platform Flutter application designed to simplify tracking shared expenses and calculating settlements for group trips.

## 🌟 Features

- **Dashboard**: Quick overview of total trip expenses and recent activity.
- **Expense Tracking**: Add expenses with categories (Food, Transit, Lodging, etc.) and specify exactly who paid.
- **Flexible Splitting**: Split expenses equally, unequally (by exact amounts), or by shares.
- **Settlement Engine**: An optimized greedy algorithm calculates the minimum number of transactions needed to settle all debts among the group.
- **Persistent Storage**: All data is securely saved locally on your device using `shared_preferences`.
- **Responsive UI**: Dynamically adjusts layouts for both mobile (bottom navigation) and desktop/tablet (side navigation rail) with a custom dark theme.

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Dart SDK

### Installation
1. Navigate to the project directory.
2. Fetch the required dependencies:
   ```bash
   flutter pub get
   ```

### Running the App
To run the app locally during development, use your IDE's run button, or run the following command in the terminal:

**For Mobile, Desktop, or Default Simulator:**
```bash
flutter run
```

**For Web (Chrome):**
```bash
flutter run -d chrome
```
*Troubleshooting:* If you encounter a "Dart compiler exited unexpectedly" error while running on Web (like you saw recently), try cleaning your build directory and fetching packages again:
```bash
flutter clean
flutter pub get
flutter run -d chrome
```
Alternatively, you can force a different web renderer:
```bash
flutter run -d chrome --web-renderer html
```

---

## 🏗️ Building for Production

When you are ready to distribute your app, you can compile it into a highly-optimized release build. 

**Android**
To build an APK for direct testing and sharing:
```bash
flutter build apk --release
```
To build an AppBundle (AAB) for uploading to the Google Play Store:
```bash
flutter build appbundle
```

**iOS** (Requires a Mac with Xcode installed)
```bash
flutter build ios --release
```
You will then need to open the `ios/Runner.xcworkspace` in Xcode to handle code signing and uploading to App Store Connect.

**Web**
```bash
flutter build web --release
```
The compiled static files will be placed in the `build/web/` directory. You can host this folder on Firebase Hosting, Vercel, Netlify, GitHub Pages, or any standard web server.

**macOS**
```bash
flutter build macos --release
```
The compiled application will be located in `build/macos/Build/Products/Release/`.
