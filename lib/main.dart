import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'providers/room_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/leave_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/mess_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/modern_admin_dashboard.dart';
import 'screens/warden/warden_dashboard.dart';
import 'screens/mess_manager/mess_manager_dashboard.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/staff/staff_dashboard.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // Note: Before running the app, you need to:
  // 1. Create a Firebase project at https://console.firebase.google.com
  // 2. Install FlutterFire CLI: dart pub global activate flutterfire_cli
  // 3. Run: flutterfire configure
  // 4. This will generate firebase_options.dart with your configuration

  // For now, we'll comment this out until Firebase is configured
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => MessProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appFullName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingLarge,
                vertical: AppSizes.paddingMedium,
              ),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.adminDashboard: (context) => const ModernAdminDashboard(),
          AppRoutes.wardenDashboard: (context) => const WardenDashboard(),
          AppRoutes.messManagerDashboard: (context) =>
              const MessManagerDashboard(),
          AppRoutes.studentDashboard: (context) => const StudentDashboard(),
          AppRoutes.staffDashboard: (context) => const StaffDashboard(),
        },
      ),
    );
  }
}
