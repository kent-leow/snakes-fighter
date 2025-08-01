# Firebase Credentials Setup

## Security Notice
This project does not commit Firebase credentials to version control. You need to set up your own Firebase project and configure the credentials locally.

## Quick Setup
Run the setup script to create template files:
```bash
./scripts/setup-credentials.sh
```

## Manual Setup

### 1. Environment Configuration
Copy the environment template:
```bash
cp .env.example .env.development
```

Edit `.env.development` with your Firebase project details:
- `FIREBASE_PROJECT_ID`: Your Firebase project ID
- `FIREBASE_API_KEY`: Your Firebase API key
- `FIREBASE_AUTH_DOMAIN`: Your project's auth domain
- `FIREBASE_DATABASE_URL`: Your Realtime Database URL
- `FIREBASE_STORAGE_BUCKET`: Your Storage bucket

### 2. Firebase Options
Generate Firebase options using FlutterFire CLI:
```bash
# Install FlutterFire CLI if not already installed
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

### 3. Platform-Specific Configuration

#### Android
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/google-services.json`

#### iOS
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/GoogleService-Info.plist`

### 4. Verify Setup
Run tests to ensure everything is configured correctly:
```bash
flutter test --exclude-tags=firebase
```

## Files Ignored by Git
The following credential files are automatically ignored:
- `.env*` (except `.env.example`)
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `firebase-debug.log*`
- `.firebase/`

## Troubleshooting
- If you see Firebase initialization errors, verify your credentials
- Ensure your Firebase project has Authentication and Realtime Database enabled
- Check that your Firebase project region matches the configuration
