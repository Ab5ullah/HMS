import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../providers/auth_provider.dart';
import '../../models/user_role.dart';
import '../../utils/constants.dart';
import '../../widgets/common/modern_button.dart';
import '../../widgets/common/modern_text_field.dart';

class ModernLoginScreen extends StatefulWidget {
  const ModernLoginScreen({super.key});

  @override
  State<ModernLoginScreen> createState() => _ModernLoginScreenState();
}

class _ModernLoginScreenState extends State<ModernLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        final user = authProvider.currentUser;
        if (user != null) {
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
          Navigator.of(context).pushReplacementNamed(route);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Login failed'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            margin: const EdgeInsets.all(AppSizes.paddingMedium),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
            margin: const EdgeInsets.all(AppSizes.paddingMedium),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < AppBreakpoints.tablet;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Gradient Background (only on desktop/tablet)
          if (!isMobile)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                ),
              ),
            ),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  isMobile ? AppSizes.paddingXSmall : AppSizes.paddingXXLarge,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildLoginCard(isMobile),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(bool isMobile) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420, // Compact max width
        ),
        child: isMobile ? _buildMobileCard() : _buildDesktopCard(),
      ),
    );
  }

  Widget _buildMobileCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLogo(),
            const SizedBox(height: AppSizes.paddingXLarge),
            _buildHeader(),
            const SizedBox(height: AppSizes.paddingXLarge),
            _buildFormFields(),
            const SizedBox(height: AppSizes.paddingXLarge),
            _buildSignInButton(),
            const SizedBox(height: AppSizes.paddingMedium),
            _buildHelpText(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(40), // Compact padding
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: const [AppShadows.xl],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(),
                const SizedBox(height: AppSizes.paddingLarge),
                _buildHeader(),
                const SizedBox(height: AppSizes.paddingXLarge),
                _buildFormFields(),
                const SizedBox(height: AppSizes.paddingXLarge),
                _buildSignInButton(),
                const SizedBox(height: AppSizes.paddingMedium),
                _buildHelpText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Image.asset(
        'assets/logo.png',
        height: 150,
        width: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to gradient container with icon
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.home_work_rounded,
              color: Colors.white,
              size: 40,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          AppStrings.appFullName,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Text(
          'Sign in with your credentials provided by admin',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        ModernTextField(
          controller: _emailController,
          label: 'Email Address',
          hint: 'your.email@example.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required';
            }
            if (!value.contains('@')) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        ModernTextField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Enter your password',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return ModernButton(
      label: 'Sign In',
      onPressed: _isLoading ? null : _handleSignIn,
      size: ModernButtonSize.large,
      fullWidth: true,
      loading: _isLoading,
    );
  }

  Widget _buildHelpText() {
    return Text(
      "Don't have login credentials? Contact your administrator",
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      textAlign: TextAlign.center,
    );
  }
}
