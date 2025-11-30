import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/common/modern_button.dart';
import '../../widgets/common/modern_card.dart';

class ActiveSessionsScreen extends StatefulWidget {
  const ActiveSessionsScreen({super.key});

  @override
  State<ActiveSessionsScreen> createState() => _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends State<ActiveSessionsScreen> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);

    try {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        final sessions = await _authService.getActiveSessions(user.uid);
        if (mounted) {
          setState(() {
            _sessions = sessions;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sessions: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Sessions'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_sessions.length > 1)
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Sign out all other devices',
              onPressed: _signOutAllOtherDevices,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSessions,
              child: _sessions.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.paddingLarge),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Active Devices',
                                style: AppTextStyles.headlineMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_sessions.length} active session${_sessions.length != 1 ? 's' : ''}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Sessions List
                        ..._sessions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final session = entry.value;
                          final isCurrentSession = index == 0; // Most recent is current

                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
                            child: _buildSessionCard(session, isCurrentSession),
                          );
                        }),

                        const SizedBox(height: AppSizes.paddingMedium),

                        // Info Card
                        Container(
                          padding: const EdgeInsets.all(AppSizes.paddingMedium),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            border: Border.all(
                              color: AppColors.info.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.info,
                                size: 20,
                              ),
                              const SizedBox(width: AppSizes.paddingSmall),
                              Expanded(
                                child: Text(
                                  'Sessions are automatically cleaned up. Only the 5 most recent sessions are shown.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSizes.paddingXLarge),
                      ],
                    ),
            ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, bool isCurrentSession) {
    final loginTime = (session['loginTime'] as dynamic)?.toDate() as DateTime?;
    final deviceInfo = session['deviceInfo'] as Map<String, dynamic>? ?? {};
    final platform = deviceInfo['platform'] ?? 'Unknown';

    return ModernCard(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCurrentSession
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Icon(
                  _getPlatformIcon(platform),
                  color: isCurrentSession ? AppColors.success : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getPlatformName(platform),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isCurrentSession) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            ),
                            child: const Text(
                              'Current',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loginTime != null
                          ? 'Active since ${DateFormat('MMM d, y h:mm a').format(loginTime)}'
                          : 'Active now',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCurrentSession)
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  color: AppColors.error,
                  tooltip: 'Sign out',
                  onPressed: () => _terminateSession(session['sessionId']),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.devices_other_rounded,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              'No Active Sessions',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              'You don\'t have any active sessions',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return Icons.android_rounded;
      case 'ios':
        return Icons.phone_iphone_rounded;
      case 'web':
        return Icons.language_rounded;
      case 'windows':
        return Icons.computer_rounded;
      case 'macos':
        return Icons.laptop_mac_rounded;
      case 'linux':
        return Icons.laptop_rounded;
      default:
        return Icons.devices_rounded;
    }
  }

  String _getPlatformName(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return 'Android Device';
      case 'ios':
        return 'iPhone/iPad';
      case 'web':
        return 'Web Browser';
      case 'windows':
        return 'Windows PC';
      case 'macos':
        return 'Mac';
      case 'linux':
        return 'Linux PC';
      default:
        return 'Unknown Device';
    }
  }

  Future<void> _terminateSession(String sessionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text(
          'This will sign you out from this device. You will need to sign in again.',
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
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        await _authService.terminateSession(user.uid, sessionId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session terminated'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadSessions();
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
    }
  }

  Future<void> _signOutAllOtherDevices() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out All Other Devices?'),
        content: const Text(
          'This will sign you out from all devices except this one. '
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

    if (confirm != true || !mounted) return;

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
          _loadSessions();
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
    }
  }
}
