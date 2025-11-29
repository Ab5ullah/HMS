import 'package:flutter/material.dart';
import 'constants.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < AppBreakpoints.tablet;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppBreakpoints.tablet &&
      MediaQuery.of(context).size.width < AppBreakpoints.desktop;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppBreakpoints.desktop;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppBreakpoints.largeDesktop;

  static double getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return AppSizes.paddingXXLarge;
    } else if (isTablet(context)) {
      return AppSizes.paddingXLarge;
    }
    return AppSizes.paddingMedium;
  }

  static int getGridCrossAxisCount(BuildContext context, {int mobile = 1, int tablet = 2, int desktop = 3}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  static double getMaxWidth(BuildContext context) {
    if (isLargeDesktop(context)) return AppBreakpoints.largeDesktop;
    if (isDesktop(context)) return AppBreakpoints.desktop;
    return double.infinity;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    if (size.width >= AppBreakpoints.desktop) {
      return desktop ?? tablet ?? mobile;
    } else if (size.width >= AppBreakpoints.tablet) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}

// Responsive Extension
extension ResponsiveExtension on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < AppBreakpoints.tablet;
  bool get isTablet =>
      MediaQuery.of(this).size.width >= AppBreakpoints.tablet &&
      MediaQuery.of(this).size.width < AppBreakpoints.desktop;
  bool get isDesktop => MediaQuery.of(this).size.width >= AppBreakpoints.desktop;

  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  double get responsivePadding {
    if (isDesktop) return AppSizes.paddingXXLarge;
    if (isTablet) return AppSizes.paddingXLarge;
    return AppSizes.paddingMedium;
  }
}

// Responsive Value Helper
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  T value(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (Responsive.isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}
