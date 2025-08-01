# Firebase Setup Documentation

## Project Configuration
- **Project ID**: snakes-fight-dev
- **Project Name**: Snakes Fight Dev
- **Region**: asia-southeast1 (Database), us-central1 (Functions)
- **Created**: August 1, 2025

## Services Enabled
✅ **Realtime Database**: Configured with authentication-based rules
✅ **Authentication**: Ready for Anonymous and Google Sign-In providers
✅ **Firebase Hosting**: Configured for Flutter web builds
✅ **Cloud Functions**: Setup complete (requires Blaze plan for deployment)
✅ **Analytics**: Integrated and ready

## Environment Configuration
### Development
- Firebase Project: snakes-fight-dev
- Database URL: https://snakes-fight-dev-default-rtdb.asia-southeast1.firebasedatabase.app
- Auth Domain: snakes-fight-dev.firebaseapp.com

## Flutter Integration
- Firebase Core: v3.15.2
- Firebase Auth: v5.7.0
- Firebase Database: v11.3.10
- Firebase Analytics: v11.6.0
- Configuration file: `lib/firebase_options.dart`

## Database Rules
```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null",
    "games": {
      "$gameId": {
        ".read": "auth != null",
        ".write": "auth != null"
      }
    },
    "players": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "lobbies": {
      ".read": "auth != null",
      ".write": "auth != null"
    }
  }
}
```

## Next Steps Required
1. **Upgrade to Blaze Plan**: Required for Cloud Functions deployment
   - Visit: https://console.firebase.google.com/project/snakes-fight-dev/usage/details
   
2. **Enable Authentication Providers**:
   - Anonymous Authentication
   - Google Sign-In
   - Visit: https://console.firebase.google.com/project/snakes-fight-dev/authentication/providers

3. **Deploy Functions**: After Blaze plan upgrade
   ```bash
   firebase deploy --only functions
   ```

4. **Deploy Hosting**: For web deployment
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

## Firebase CLI Commands
```bash
# Login to Firebase
firebase login

# List projects
firebase projects:list

# Deploy database rules
firebase deploy --only database

# Deploy all services
firebase deploy

# Open Firebase console
firebase open
```

## Development Workflow
1. Make changes to Flutter app
2. Test locally: `flutter run -d chrome`
3. Build web version: `flutter build web --release`
4. Deploy to Firebase Hosting: `firebase deploy --only hosting`

## Monitoring & Debugging
- **Console**: https://console.firebase.google.com/project/snakes-fight-dev
- **Database**: Real-time monitoring in Firebase console
- **Authentication**: User management in Firebase console
- **Functions**: Logs and metrics available after deployment
- **Analytics**: User behavior tracking enabled
