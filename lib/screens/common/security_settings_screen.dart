import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/common/modern_button.dart';
import '../../widgets/common/modern_card.dart';
import 'change_password_screen.dart';
import 'active_sessions_screen.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  int _activeSessionsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadActiveSessions();
  }

  Future<void> _loadActiveSessions() async {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      final sessions = await _authService.getActiveSessions(user.uid);
      if (mounted) {
        setState(() => _activeSessionsCount = sessions.length);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Security',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your account security and sessions',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Password Management Section
          _buildSectionHeader('Password Management'),
          ModernCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSecurityMenuItem(
                  icon: Icons.lock_reset_rounded,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildSecurityMenuItem(
                  icon: Icons.email_rounded,
                  title: 'Reset Password via Email',
                  subtitle: 'Send password reset link to ${user?.email ?? "your email"}',
                  color: AppColors.info,
                  onTap: _sendPasswordResetEmail,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.paddingLarge),

          // Session Management Section
          _buildSectionHeader('Active Sessions'),
          ModernCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSecurityMenuItem(
                  icon: Icons.devices_rounded,
                  title: 'Manage Devices',
                  subtitle: '$_activeSessionsCount active session${_activeSessionsCount != 1 ? 's' : ''}',
                  color: AppColors.success,
                  badge: _activeSessionsCount > 1 ? _activeSessionsCount.toString() : null,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ActiveSessionsScreen(),
                      ),
                    );
                    _loadActiveSessions(); // Reload after returning
                  },
                ),
                const Divider(height: 1),
                _buildSecurityMenuItem(
                  icon: Icons.logout_rounded,
                  title: 'Sign Out All Devices',
                  subtitle: 'Terminate all other active sessions',
                  color: AppColors.warning,
                  onTap: _signOutAllDevices,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.paddingLarge),

          // Account Information
          _buildSectionHeader('Account Information'),
          ModernCard(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Email', user?.email ?? 'N/A'),
                const SizedBox(height: AppSizes.paddingSmall),
                _buildInfoRow('Account Status', _getStatusText(user?.status)),
                const SizedBox(height: AppSizes.paddingSmall),
                _buildInfoRow('Role', _getRoleText(user?.role.toString())),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.paddingXLarge),

          // Danger Zone
          _buildSectionHeader('Danger Zone'),
          ModernCard(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            color: AppColors.error.withValues(alpha: 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: AppSizes.paddingSmall),
                    Text(
                      'Permanent Actions',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                Text(
                  'These actions cannot be undone. Please be certain.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                ModernButton(
                  label: 'Delete Account',
                  icon: Icons.delete_forever_rounded,
                  onPressed: () {
                    // TODO: Implement account deletion
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Account deletion feature coming soon'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                  variant: ModernButtonVariant.outlined,
                  color: AppColors.error,
                  fullWidth: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.paddingXLarge),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.paddingSmall,
        bottom: AppSizes.paddingSmall,
      ),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSecurityMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMedium,
          vertical: AppSizes.paddingMedium,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: AppSizes.paddingSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(width: AppSizes.paddingSmall),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getStatusText(String? status) {
    if (status == null) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1);
  }

  String _getRoleText(String? role) {
    if (role == null) return 'Unknown';
    final roleText = role.split('.').last;
    return roleText[0].toUpperCase() + roleText.substring(1);
  }

  Future<void> _sendPasswordResetEmail() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user?.email == null) return;

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(user!.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset link sent to ${user.email}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOutAllDevices() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out All Devices?'),
        content: const Text(
          'This will sign you out from all other devices. '
          'You will remain signed in on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Sign Out All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        await _authService.terminateAllOtherSessions(user.uid);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All other sessions terminated'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadActiveSessions();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
