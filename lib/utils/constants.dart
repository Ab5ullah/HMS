import 'package:flutter/material.dart';

// UOG Brand Color Palette
class AppColors {
  // Primary Colors - UOG Blue
  static const primary = Color(0xFF096EA2); // UOG Primary Blue
  static const primaryLight = Color(0xFF22455B); // UOG Dark Blue-Gray
  static const primaryDark = Color(0xFF063046); // UOG Very Dark Blue

  // Secondary Colors - UOG Orange/Amber
  static const secondary = Color(0xFFF99D48); // UOG Orange
  static const secondaryLight = Color(0xFFFFA84B); // UOG Lighter Orange
  static const secondaryDark = Color(0xFFE68A35);

  // Accent Colors
  static const accent = Color(0xFFF99D48); // UOG Orange
  static const accentLight = Color(0xFFFFA84B);

  // Status Colors
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Neutral Colors - Modern Gray Scale
  static const background = Color(0xFFF9FAFB);
  static const backgroundDark = Color(0xFFF3F4F6);
  static const surface = Colors.white;
  static const surfaceLight = Color(0xFFFAFAFA);

  // Text Colors
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const textDisabled = Color(0xFFD1D5DB);

  // Border Colors
  static const border = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFF3F4F6);

  // Role-based Colors - UOG Theme
  static const adminColor = Color(0xFF063046); // UOG Very Dark Blue
  static const wardenColor = Color(0xFF10B981); // Green
  static const messManagerColor = Color(0xFFF99D48); // UOG Orange
  static const staffColor = Color(0xFFEC4899); // Pink
  static const studentColor = Color(0xFF096EA2); // UOG Primary Blue

  // Gradient Colors - UOG Theme
  static const gradientStart = Color(0xFF096EA2); // UOG Primary Blue
  static const gradientEnd = Color(0xFF22455B); // UOG Dark Blue-Gray

  // Dark Mode Colors (for future implementation)
  static const darkBackground = Color(0xFF111827);
  static const darkSurface = Color(0xFF1F2937);
  static const darkBorder = Color(0xFF374151);
}

// Modern Typography
class AppTextStyles {
  // Display Styles
  static const displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.16,
  );

  static const displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.22,
  );

  // Headline Styles
  static const headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static const headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static const headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // Title Styles
  static const titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // Body Styles
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Label Styles
  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );
}

// Responsive Breakpoints
class AppBreakpoints {
  static const double mobile = 640;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1280;
  static const double extraLargeDesktop = 1536;
}

// Modern Spacing System
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

// Modern Sizing System
class AppSizes {
  // Padding
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  static const double paddingXXLarge = 48.0;

  // Border Radius
  static const double radiusXSmall = 4.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 24.0;
  static const double radiusFull = 9999.0;

  // Icon Sizes
  static const double iconXSmall = 16.0;
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;
  static const double iconXXLarge = 64.0;

  // Button Sizes
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 52.0;

  // Card Sizes
  static const double cardElevation = 0.0;
  static const double cardElevationHover = 4.0;

  // Avatar Sizes
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;
  static const double avatarXLarge = 96.0;
}

// Currency Configuration
class AppCurrency {
  static const String symbol = 'PKR';
  static const String code = 'PKR';
  static const String name = 'Pakistani Rupee';

  static String format(double amount) {
    return 'PKR ${amount.toStringAsFixed(2)}';
  }

  static String formatWithoutDecimals(double amount) {
    return 'PKR ${amount.toStringAsFixed(0)}';
  }

  static String formatCompact(double amount) {
    if (amount >= 100000) {
      return 'PKR ${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return 'PKR ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }
}

// App Strings
class AppStrings {
  static const appName = 'UOG Boys Hostel';
  static const appFullName = 'UOG Boys Hostel';
  static const appTagline = 'University of Gujrat Hostel Management';

  // Authentication
  static const login = 'Login';
  static const register = 'Register';
  static const email = 'Email';
  static const password = 'Password';
  static const name = 'Name';
  static const phoneNumber = 'Phone Number';
  static const forgotPassword = 'Forgot Password?';
  static const dontHaveAccount = "Don't have an account?";
  static const alreadyHaveAccount = 'Already have an account?';
  static const signIn = 'Sign In';
  static const signUp = 'Sign Up';

  // Navigation
  static const dashboard = 'Dashboard';
  static const students = 'Students';
  static const rooms = 'Rooms';
  static const attendance = 'Attendance';
  static const mess = 'Mess';
  static const payments = 'Payments';
  static const leaves = 'Leaves';
  static const complaints = 'Complaints';
  static const reports = 'Reports';
  static const settings = 'Settings';
  static const logout = 'Logout';

  // Common Actions
  static const add = 'Add';
  static const edit = 'Edit';
  static const delete = 'Delete';
  static const save = 'Save';
  static const cancel = 'Cancel';
  static const search = 'Search';
  static const filter = 'Filter';
  static const refresh = 'Refresh';
  static const viewAll = 'View All';
  static const viewDetails = 'View Details';
}

// App Routes
class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const adminDashboard = '/admin';
  static const wardenDashboard = '/warden';
  static const messManagerDashboard = '/mess-manager';
  static const studentDashboard = '/student';
  static const staffDashboard = '/staff';
}

// Animation Durations
class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

// Shadow Styles
class AppShadows {
  static const BoxShadow sm = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const BoxShadow md = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 6,
    offset: Offset(0, 2),
  );

  static const BoxShadow lg = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 15,
    offset: Offset(0, 4),
  );

  static const BoxShadow xl = BoxShadow(
    color: Color(0x26000000),
    blurRadius: 25,
    offset: Offset(0, 10),
  );
}
