import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../models/user_role.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      } else {
        String route;
        switch (user.role) {
          case UserRole.admin:
            route = AppRoutes.adminDashboard;
            break;
          case UserRole.warden:
            route = AppRoutes.wardenDashboard;
            break;
          case UserRole.messManager:
            route = AppRoutes.messManagerDashboard;
            break;
          case UserRole.staff:
            route = AppRoutes.staffDashboard;
            break;
          case UserRole.student:
            route = AppRoutes.studentDashboard;
            break;
        }
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(route);
        }
      }
    } catch (e) {
      // If auth check fails, navigate to login screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.home_work,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.appFullName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
