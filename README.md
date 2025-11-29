# Hostel Management System (HMS)

A comprehensive, full-stack hostel management system built with Flutter and Firebase. This cross-platform application provides complete management solutions for hostels, including student management, room allocation, payments, mess menu, complaints, and attendance tracking.

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [User Roles](#user-roles)
- [Modules](#modules)
- [Firebase Setup](#firebase-setup)
- [Building and Deployment](#building-and-deployment)
- [Contributing](#contributing)
- [License](#license)

## Features

### Core Features

- **Multi-Role Authentication System**
  - Admin, Warden, Mess Manager, Student, and Staff roles
  - Secure Firebase Authentication
  - User approval workflow for new registrations
  - Profile management with password change

- **Student Management**
  - Complete student profile management
  - Student registration with guardian information
  - Room allocation and deallocation
  - Student status tracking (active, inactive, archived)
  - Advanced search and filtering

- **Room Management**
  - Room creation and management
  - Floor-wise organization
  - Occupancy tracking
  - Room status monitoring (available, occupied, maintenance, reserved)
  - Real-time availability updates

- **Payment Management**
  - Fee payment tracking
  - Multiple payment types (hostel fee, mess fee, security deposit, etc.)
  - Payment status management (pending, paid, overdue)
  - Payment history and reports
  - Due amount calculations

- **Mess Management**
  - Weekly menu planning
  - Meal type management (breakfast, lunch, dinner, snacks)
  - Menu publishing and updates
  - Student meal preferences

- **Complaint Management**
  - Complaint submission and tracking
  - Category-based organization (maintenance, food, security, cleanliness, etc.)
  - Priority levels (low, medium, high, urgent)
  - Status tracking (pending, in-progress, resolved, closed)
  - Admin response system

- **Leave Management**
  - Leave application submission
  - Approval workflow
  - Leave type categorization (home, medical, emergency, vacation)
  - Leave history tracking

- **Attendance Management**
  - Daily attendance marking
  - Attendance reports
  - GPS-based location verification
  - Monthly attendance statistics

- **Modern UI/UX**
  - Responsive design for mobile, tablet, and web
  - Material Design 3 components
  - Dark mode support (coming soon)
  - Smooth animations and transitions
  - Real-time data updates

## Screenshots

*Add screenshots of your application here*

## Tech Stack

### Frontend
- **Flutter 3.9.2+** - Cross-platform UI framework
- **Dart 3.9.2+** - Programming language
- **Material Design 3** - UI design system

### Backend & Services
- **Firebase Authentication** - User authentication and authorization
- **Cloud Firestore** - NoSQL real-time database
- **Firebase Storage** - File storage for documents and images
- **Firebase Cloud Messaging** - Push notifications

### State Management
- **Provider** - State management solution

### Key Packages
- `firebase_core` - Firebase initialization
- `cloud_firestore` - Database operations
- `provider` - State management
- `intl` - Internationalization and date formatting
- `fl_chart` - Charts and graphs
- `pdf` & `printing` - PDF generation and printing
- `geolocator` - GPS location services
- `image_picker` - Image selection
- `shared_preferences` - Local storage
- `flutter_local_notifications` - Local notifications

## Architecture

The project follows a **Clean Architecture** pattern with clear separation of concerns:

```
lib/
├── config/          # Configuration files (Firebase, etc.)
├── models/          # Data models
├── providers/       # State management (Provider)
├── screens/         # UI screens organized by role
├── services/        # Business logic and API calls
├── utils/           # Utility functions and constants
└── widgets/         # Reusable UI components
```

### Design Patterns Used
- **Provider Pattern** - For state management
- **Repository Pattern** - For data access abstraction
- **Singleton Pattern** - For service instances
- **Factory Pattern** - For model creation

## Project Structure

```
lib/
├── config/
│   └── firebase_options.dart        # Firebase configuration
│
├── models/
│   ├── app_user.dart                # User model
│   ├── student.dart                 # Student model
│   ├── room.dart                    # Room model
│   ├── payment.dart                 # Payment model
│   ├── mess.dart                    # Mess menu model
│   ├── complaint.dart               # Complaint model
│   ├── leave.dart                   # Leave model
│   ├── attendance.dart              # Attendance model
│   ├── hostel.dart                  # Hostel model
│   └── user_role.dart               # User role enumeration
│
├── providers/
│   └── auth_provider.dart           # Authentication state management
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart        # Login screen
│   │   ├── modern_login_screen.dart # Modern login UI
│   │   └── register_screen.dart     # Registration screen
│   │
│   ├── admin/
│   │   ├── admin_dashboard.dart     # Classic admin dashboard
│   │   ├── modern_admin_dashboard.dart  # Modern admin dashboard
│   │   ├── main_layout.dart         # Sidebar layout for web/desktop
│   │   ├── students_list_screen.dart    # Student list
│   │   ├── student_detail_screen.dart   # Student details
│   │   ├── add_student_screen.dart      # Add new student
│   │   ├── rooms_list_screen.dart       # Room list
│   │   ├── room_detail_screen.dart      # Room details
│   │   ├── add_room_screen.dart         # Add new room
│   │   ├── payments_list_screen.dart    # Payment list
│   │   ├── payment_detail_screen.dart   # Payment details
│   │   ├── add_payment_screen.dart      # Add payment
│   │   ├── mess_menu_screen.dart        # Mess menu management
│   │   ├── complaints_list_screen.dart  # Complaint list
│   │   ├── leaves_list_screen.dart      # Leave applications
│   │   ├── attendance_list_screen.dart  # Attendance records
│   │   ├── pending_users_screen.dart    # User approval queue
│   │   ├── settings_screen.dart         # Settings
│   │   ├── edit_profile_screen.dart     # Profile editing
│   │   └── change_password_screen.dart  # Password change
│   │
│   ├── warden/
│   │   └── warden_dashboard.dart    # Warden dashboard
│   │
│   ├── mess_manager/
│   │   └── mess_manager_dashboard.dart  # Mess manager dashboard
│   │
│   ├── student/
│   │   └── student_dashboard.dart   # Student dashboard
│   │
│   ├── staff/
│   │   └── staff_dashboard.dart     # Staff dashboard
│   │
│   └── splash_screen.dart           # Initial splash screen
│
├── services/
│   ├── auth_service.dart            # Authentication services
│   ├── database_service.dart        # Firestore database operations
│   └── storage_service.dart         # Firebase Storage operations
│
├── utils/
│   ├── constants.dart               # App constants (colors, routes, etc.)
│   ├── responsive.dart              # Responsive design utilities
│   ├── validators.dart              # Form validators
│   └── date_utils.dart              # Date formatting utilities
│
├── widgets/
│   └── common/
│       ├── custom_text_field.dart   # Custom text input field
│       ├── modern_text_field.dart   # Modern text field
│       ├── modern_button.dart       # Modern button component
│       ├── modern_card.dart         # Card components
│       ├── info_card.dart           # Information card
│       ├── loading_widget.dart      # Loading indicator
│       ├── empty_state_widget.dart  # Empty state display
│       └── error_widget.dart        # Error display
│
└── main.dart                        # Application entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.9.2)
- Dart SDK (>=3.9.2)
- Firebase account
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/hms.git
   cd hms
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android, iOS, and Web apps to your Firebase project
   - Download configuration files:
     - `google-services.json` for Android (place in `android/app/`)
     - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
   - Run FlutterFire CLI to generate Firebase options:
     ```bash
     flutterfire configure
     ```

4. **Run the application**
   ```bash
   # For mobile (Android/iOS)
   flutter run

   # For web
   flutter run -d chrome

   # For specific device
   flutter run -d <device-id>
   ```

## Configuration

### Firebase Configuration

The Firebase configuration is managed in `lib/config/firebase_options.dart`. This file is auto-generated by FlutterFire CLI.

### App Constants

Edit `lib/utils/constants.dart` to customize:
- Color scheme
- Typography
- Spacing and sizing
- Route names
- App breakpoints for responsive design

```dart
// Example customization
class AppColors {
  static const primary = Color(0xFF6366F1);
  static const adminColor = Color(0xFF8B5CF6);
  // ... more colors
}
```

### Responsive Breakpoints

```dart
class AppBreakpoints {
  static const double mobile = 0;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;
}
```

## User Roles

The system supports five distinct user roles, each with specific permissions:

### 1. Admin
**Full System Access**
- Manage all users, students, rooms, and data
- Approve new user registrations
- Configure system settings
- View all reports and analytics
- Manage payments and fees
- Handle complaints and leave applications

### 2. Warden
**Hostel Operations Management**
- Monitor room occupancy
- Handle student complaints
- Approve/reject leave applications
- View attendance records
- Manage room maintenance

### 3. Mess Manager
**Mess Operations Management**
- Create and update mess menus
- Track meal preferences
- View student feedback
- Manage mess-related complaints
- Monitor mess payments

### 4. Student
**Personal Management**
- View personal profile
- Check room details
- Submit complaints
- Apply for leave
- View mess menu
- Check payment status
- Mark attendance

### 5. Staff
**Limited Access**
- View assigned tasks
- Update task status
- Submit reports
- View announcements

## Modules

### 1. Authentication Module

**Features:**
- Email/password authentication
- User registration with role selection
- Admin approval workflow for new users
- Session management
- Password reset
- Profile management

**Screens:**
- Login Screen
- Registration Screen
- Pending Approval Screen

### 2. Student Management Module

**Features:**
- Add, edit, delete students
- Comprehensive student profiles
- Guardian information
- Room allocation/deallocation
- Status management (active, inactive, archived)
- Search and filter functionality
- Student document storage

**Screens:**
- Students List Screen
- Student Detail Screen
- Add Student Screen

### 3. Room Management Module

**Features:**
- Room creation and management
- Floor-wise organization
- Bed/capacity management
- Occupancy tracking
- Room status (available, occupied, maintenance, reserved)
- Student-room assignment

**Screens:**
- Rooms List Screen
- Room Detail Screen
- Add Room Screen

### 4. Payment Module

**Features:**
- Payment recording
- Multiple payment types
- Payment status tracking
- Due amount calculation
- Payment history
- Receipt generation
- Payment reminders

**Screens:**
- Payments List Screen
- Payment Detail Screen
- Add Payment Screen

### 5. Mess Management Module

**Features:**
- Weekly menu planning
- Meal type categorization
- Menu publishing
- Student feedback
- Dietary preferences
- Special meal requests

**Screens:**
- Mess Menu Screen
- Menu Editor Screen

### 6. Complaint Management Module

**Features:**
- Complaint submission
- Category-based organization
- Priority levels
- Status tracking
- Admin responses
- Complaint resolution workflow
- Notification system

**Screens:**
- Complaints List Screen
- Complaint Detail Screen
- Submit Complaint Screen

### 7. Leave Management Module

**Features:**
- Leave application
- Leave type selection
- Approval workflow
- Leave balance tracking
- Leave history
- Calendar integration

**Screens:**
- Leaves List Screen
- Leave Detail Screen
- Apply Leave Screen

### 8. Attendance Module

**Features:**
- Daily attendance marking
- GPS-based verification
- Attendance reports
- Monthly statistics
- Absence tracking
- Attendance analytics

**Screens:**
- Attendance List Screen
- Mark Attendance Screen
- Attendance Reports Screen

## Firebase Setup

### Firestore Database Structure

```
users/
  {userId}/
    - uid: string
    - email: string
    - name: string
    - role: string
    - phoneNumber: string
    - isApproved: boolean
    - createdAt: timestamp

students/
  {studentId}/
    - studentId: string
    - name: string
    - email: string
    - phoneNumber: string
    - roomId: string
    - course: string
    - department: string
    - guardianName: string
    - guardianPhone: string
    - address: string
    - status: string
    - hostelId: string
    - createdAt: timestamp

rooms/
  {roomId}/
    - roomId: string
    - roomNumber: string
    - floor: int
    - capacity: int
    - currentOccupancy: int
    - status: string
    - hostelId: string
    - createdAt: timestamp

payments/
  {paymentId}/
    - paymentId: string
    - studentId: string
    - amount: double
    - paidAmount: double
    - dueAmount: double
    - paymentType: string
    - status: string
    - dueDate: timestamp
    - paidDate: timestamp
    - createdAt: timestamp

complaints/
  {complaintId}/
    - complaintId: string
    - studentId: string
    - category: string
    - priority: string
    - description: string
    - status: string
    - response: string
    - createdAt: timestamp
    - resolvedAt: timestamp

messMenus/
  {menuId}/
    - menuId: string
    - day: string
    - mealType: string
    - items: array
    - isPublished: boolean
    - createdAt: timestamp

leaves/
  {leaveId}/
    - leaveId: string
    - studentId: string
    - leaveType: string
    - fromDate: timestamp
    - toDate: timestamp
    - reason: string
    - status: string
    - approvedBy: string
    - createdAt: timestamp

attendance/
  {attendanceId}/
    - attendanceId: string
    - studentId: string
    - date: timestamp
    - status: string
    - location: geopoint
    - createdAt: timestamp
```

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // User authentication check
    function isSignedIn() {
      return request.auth != null;
    }

    // Check if user is admin
    function isAdmin() {
      return isSignedIn() &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Check if user is warden
    function isWarden() {
      return isSignedIn() &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'warden';
    }

    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update: if isSignedIn() &&
        (request.auth.uid == userId || isAdmin());
      allow delete: if isAdmin();
    }

    // Students collection
    match /students/{studentId} {
      allow read: if isSignedIn();
      allow write: if isAdmin() || isWarden();
    }

    // Rooms collection
    match /rooms/{roomId} {
      allow read: if isSignedIn();
      allow write: if isAdmin() || isWarden();
    }

    // Payments collection
    match /payments/{paymentId} {
      allow read: if isSignedIn();
      allow write: if isAdmin();
    }

    // Complaints collection
    match /complaints/{complaintId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update: if isAdmin() || isWarden();
      allow delete: if isAdmin();
    }

    // Mess menus collection
    match /messMenus/{menuId} {
      allow read: if isSignedIn();
      allow write: if isAdmin();
    }

    // Leaves collection
    match /leaves/{leaveId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update: if isAdmin() || isWarden();
      allow delete: if isAdmin();
    }

    // Attendance collection
    match /attendance/{attendanceId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn();
    }
  }
}
```

### Firebase Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## Building and Deployment

### Android Build

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# Build app bundle for Play Store
flutter build appbundle --release
```

### iOS Build

```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

### Web Build

```bash
# Build for web
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### Environment-Specific Builds

```bash
# Production
flutter build apk --release --dart-define=ENV=production

# Staging
flutter build apk --release --dart-define=ENV=staging
```

## Running the App

### Mobile (Android/iOS)

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in release mode
flutter run --release
```

### Web

```bash
# Run on Chrome
flutter run -d chrome

# Run on specific port
flutter run -d chrome --web-port=8080

# Run in release mode
flutter run -d chrome --release
```

### Desktop (Windows/macOS/Linux)

```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

## Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Integration Tests

```bash
flutter drive --target=test_driver/app.dart
```

## Code Quality

### Linting

```bash
# Analyze code
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

### Formatting

```bash
# Format all Dart files
dart format .

# Check formatting
dart format --set-exit-if-changed .
```

## Performance Optimization

### Best Practices Implemented

1. **Efficient State Management**
   - Provider pattern for global state
   - Local state for UI-specific data
   - StreamBuilder for real-time updates

2. **Image Optimization**
   - Cached network images
   - Lazy loading
   - Proper image sizing

3. **Database Optimization**
   - Indexed queries
   - Pagination for large lists
   - Efficient data structure

4. **Code Splitting**
   - Lazy loading of screens
   - Deferred loading of heavy packages

## Security Features

- Secure Firebase Authentication
- Role-based access control (RBAC)
- Firestore security rules
- Input validation and sanitization
- Secure storage for sensitive data
- HTTPS for all network requests
- Token-based session management

## Accessibility

- Screen reader support
- Semantic labels
- Sufficient color contrast
- Keyboard navigation support
- Scalable text
- Touch target sizing

## Internationalization

The app is designed to support multiple languages (implementation pending):

```dart
// Example usage
Text(AppLocalizations.of(context).translate('welcome'))
```

## Troubleshooting

### Common Issues

1. **Firebase Configuration Error**
   ```
   Solution: Run `flutterfire configure` and ensure all platform configurations are correct
   ```

2. **Build Failed**
   ```bash
   # Clean build
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Hot Reload Not Working**
   ```bash
   # Restart the app
   Press 'R' in terminal or use hot restart
   ```

4. **Package Version Conflicts**
   ```bash
   flutter pub upgrade --major-versions
   ```

## Contributing

We welcome contributions! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Standards

- Follow Dart style guide
- Write meaningful commit messages
- Add comments for complex logic
- Write unit tests for new features
- Update documentation

## Roadmap

### Upcoming Features

- [ ] Dark mode support
- [ ] Multi-language support
- [ ] Push notifications
- [ ] PDF report generation
- [ ] Advanced analytics dashboard
- [ ] QR code for attendance
- [ ] Visitor management
- [ ] Inventory management
- [ ] Staff attendance
- [ ] Emergency alerts
- [ ] Biometric authentication
- [ ] Integration with payment gateways
- [ ] Mobile app for parents
- [ ] Chatbot support

## Version History

### v1.0.0 (Current)
- Initial release
- User authentication and authorization
- Student management
- Room management
- Payment tracking
- Mess menu management
- Complaint system
- Leave management
- Attendance tracking
- Responsive UI for web and mobile

## Authors

- Your Name - Initial work

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Material Design for UI guidelines
- Open source community for packages and inspiration

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@yourdomain.com or join our Slack channel.

## FAQ

**Q: Can I use this for commercial purposes?**
A: Yes, this project is open source under MIT license.

**Q: How do I add a new user role?**
A: Update the `UserRole` enum in `lib/models/user_role.dart` and add corresponding dashboard screen.

**Q: How do I customize the color scheme?**
A: Edit the color constants in `lib/utils/constants.dart`.

**Q: Is there a demo available?**
A: Yes, visit [demo.yourdomain.com](https://demo.yourdomain.com) (update with actual link).

**Q: How do I report a bug?**
A: Please create an issue on GitHub with detailed information.

---

Made with ❤️ using Flutter
