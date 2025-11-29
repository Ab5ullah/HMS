# HMS - Quick Setup Guide

## Step-by-Step Setup Instructions

### 1. Install Prerequisites

Make sure you have the following installed:

- **Flutter SDK 3.9.2+**: [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Node.js**: [Download Node.js](https://nodejs.org/)
- **Git**: [Download Git](https://git-scm.com/)
- **Android Studio** (for Android development)
- **Xcode** (for iOS development, macOS only)
- **VS Code** or **Android Studio** (recommended IDEs)

Verify Flutter installation:
```bash
flutter doctor
```

### 2. Clone and Setup Project

```bash
# Navigate to your projects directory
cd "d:\Flutter Projects"

# Already cloned at d:\Flutter Projects\hms

# Navigate to project
cd hms

# Get dependencies
flutter pub get
```

### 3. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name: "HMS" or "hostel-management-system"
4. Disable Google Analytics (optional)
5. Click "Create project"

### 4. Enable Firebase Services

In your Firebase project:

#### Enable Authentication
1. Go to **Build → Authentication**
2. Click "Get started"
3. Enable **Email/Password** sign-in method
4. Save

#### Enable Firestore Database
1. Go to **Build → Firestore Database**
2. Click "Create database"
3. Select **Start in test mode** (we'll add security rules later)
4. Choose your region (closest to your users)
5. Click "Enable"

#### Enable Storage
1. Go to **Build → Storage**
2. Click "Get started"
3. Start in **test mode**
4. Click "Done"

#### Enable Cloud Messaging (Optional - for notifications)
1. Go to **Build → Cloud Messaging**
2. Click "Get started"

### 5. Configure FlutterFire

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Make sure FlutterFire is in PATH
# Windows: Add %USERPROFILE%\AppData\Local\Pub\Cache\bin to PATH
# macOS/Linux: Add ~/.pub-cache/bin to PATH

# Configure Firebase for your Flutter project
flutterfire configure
```

When running `flutterfire configure`:
1. Select your Firebase project
2. Select platforms to support (Android, iOS, Web, Windows, macOS)
3. This will create `lib/config/firebase_options.dart`

### 6. Update main.dart

After `flutterfire configure` completes, update `lib/main.dart`:

1. Add import at the top:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
```

2. Uncomment Firebase initialization in `main()`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
```

### 7. Set Up Firestore Security Rules

1. Copy content from `firestore.rules` file
2. Go to Firebase Console → **Firestore Database → Rules**
3. Replace existing rules with the copied content
4. Click "Publish"

### 8. Set Up Storage Security Rules

In Firebase Console → **Storage → Rules**, use these rules:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /students/{studentId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                     (request.auth.uid == studentId ||
                      isAdminOrWarden());
    }

    match /complaints/{complaintId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    function isAdminOrWarden() {
      return exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
             (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' ||
              get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'warden');
    }
  }
}
```

### 9. Run the Application

#### For Android
```bash
# Connect Android device or start emulator
flutter run
```

#### For Web
```bash
flutter run -d chrome
```

#### For Windows Desktop
```bash
flutter run -d windows
```

#### For iOS (macOS only)
```bash
cd ios
pod install
cd ..
flutter run -d ios
```

### 10. Create First Admin Account

1. Run the app
2. Click "Register"
3. Fill in details:
   - Name: Your name
   - Email: admin@hms.com
   - Password: (choose a strong password)
   - Role: Admin
4. Click "Register"
5. Login with the created credentials

### 11. Initial Setup in App

After logging in as admin:

1. **Create Hostel** (will be implemented in Settings)
   - Hostel Name
   - Address
   - Contact details
   - Fees structure

2. **Create Rooms**
   - Room numbers
   - Capacity
   - Type (single, double, etc.)

3. **Create Staff Accounts**
   - Warden account
   - Mess Manager account
   - Staff accounts

4. **Configure Mess Menu**
   - Weekly menu planning

### Troubleshooting

#### Issue: Firebase not initialized
**Solution**: Make sure you uncommented Firebase initialization in `main.dart`

#### Issue: `flutterfire` command not found
**Solution**:
```bash
# Windows
set PATH=%PATH%;%USERPROFILE%\AppData\Local\Pub\Cache\bin

# macOS/Linux
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

#### Issue: Build errors after adding Firebase
**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

#### Issue: Permission denied in Firestore
**Solution**: Make sure Firestore security rules are properly published

#### Issue: Android build fails
**Solution**:
- Update `android/build.gradle` - set `minSdkVersion` to 21 or higher
- Make sure you have latest Android SDK installed

### Next Steps

After successful setup:

1. Explore the dashboards for each role
2. Test user creation and authentication
3. Start implementing specific features:
   - Student management screens
   - Room allocation
   - Attendance tracking
   - Mess menu management
   - Payment tracking
   - Leave requests
   - Complaint management

### Platform-Specific Notes

#### Android
- Minimum SDK: 21
- Target SDK: 34
- Firebase requires Google Play Services

#### iOS
- Minimum iOS version: 12.0
- Requires Xcode 14+
- Pod dependencies installed via CocoaPods

#### Web
- Works on all modern browsers
- Firebase works out of the box
- Requires HTTPS in production

#### Desktop (Windows/macOS/Linux)
- Firebase support available
- May require additional platform-specific setup

### Development Tips

1. Use hot reload during development: Press `r` in terminal
2. Use hot restart for major changes: Press `R` in terminal
3. Check logs for debugging: `flutter logs`
4. Test on multiple devices/platforms
5. Use Flutter DevTools for debugging

### Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Provider State Management](https://pub.dev/packages/provider)

### Support

If you encounter issues:
1. Check the error messages carefully
2. Verify Firebase configuration
3. Check Firestore security rules
4. Ensure all dependencies are installed
5. Run `flutter doctor` to check for issues

---

**Ready to start developing!** 🚀
