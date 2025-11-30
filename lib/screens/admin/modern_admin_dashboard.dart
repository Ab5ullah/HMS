import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/modern_card.dart';
import 'students_list_screen.dart';
import 'rooms_list_screen.dart';
import 'payments_list_screen.dart';
import 'mess_menu_screen.dart';
import 'complaints_list_screen.dart';
import 'leaves_list_screen.dart';
import 'settings_screen.dart';
import 'pending_users_screen.dart';
import 'users_management_screen.dart';
import 'fix_student_uids_screen.dart';
import 'debug_student_screen.dart';
import 'main_layout.dart';

class ModernAdminDashboard extends StatefulWidget {
  const ModernAdminDashboard({super.key});

  @override
  State<ModernAdminDashboard> createState() => _ModernAdminDashboardState();
}

class _ModernAdminDashboardState extends State<ModernAdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildMobileAppBar(),
      body: _buildContent(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTabletLayout() {
    // For web, always show sidebar layout even on tablet breakpoint
    return MainLayout(
      selectedIndex: _selectedIndex,
      onNavigationChanged: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: _buildContent(),
    );
  }

  Widget _buildDesktopLayout() {
    return MainLayout(
      selectedIndex: _selectedIndex,
      onNavigationChanged: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: _buildContent(),
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    final user = context.watch<AuthProvider>().currentUser;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: const Icon(
              Icons.home_work_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSizes.paddingSmall),
          const Text(
            'HMS',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: [
        _buildNotificationButton(),
        const SizedBox(width: AppSizes.paddingSmall),
        _buildUserAvatar(user?.name ?? 'A'),
        const SizedBox(width: AppSizes.paddingMedium),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex > 4 ? 4 : _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_rounded),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_rounded),
            label: 'Mess',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return StreamBuilder<List<dynamic>>(
      stream: DatabaseService().getPendingUsers(),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: AppColors.textPrimary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PendingUsersScreen(),
                  ),
                );
              },
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildUserAvatar(String name) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Text(
        name[0].toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedIndex == 0) return _buildDashboardContent();
    if (_selectedIndex == 1) return const StudentsListScreen();
    if (_selectedIndex == 2) return const PaymentsListScreen();
    if (_selectedIndex == 3) return const MessMenuScreen();
    if (_selectedIndex == 4) return _buildMoreScreen();
    if (_selectedIndex == 5) return const RoomsListScreen();
    if (_selectedIndex == 6) return const ComplaintsListScreen();
    if (_selectedIndex == 7) return const LeavesListScreen();
    if (_selectedIndex == 8) return const SettingsScreen();
    return _buildDashboardContent();
  }

  Widget _buildDashboardContent() {
    final user = context.watch<AuthProvider>().currentUser;
    final isDesktop = context.isDesktop;
    final isMobile = context.isMobile;
    final gridCount = Responsive.getGridCrossAxisCount(
      context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.responsivePadding),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Text(
              'Good ${_getGreeting()}, ${user?.name ?? "Admin"}',
              style: isDesktop
                  ? AppTextStyles.headlineMedium
                  : AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Here\'s what\'s happening today',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.paddingXLarge),

            // Stats Grid - Fetch from Firebase
            StreamBuilder<List<dynamic>>(
              stream: DatabaseService().getStudents(),
              builder: (context, studentsSnapshot) {
                return StreamBuilder<List<dynamic>>(
                  stream: DatabaseService().getRooms(),
                  builder: (context, roomsSnapshot) {
                    return StreamBuilder<List<dynamic>>(
                      stream: DatabaseService().getPayments(),
                      builder: (context, paymentsSnapshot) {
                        // Calculate stats
                        final totalStudents =
                            studentsSnapshot.data?.length ?? 0;
                        final activeStudents =
                            studentsSnapshot.data
                                ?.where((s) => s.status == 'active')
                                .length ??
                            0;

                        final totalRooms = roomsSnapshot.data?.length ?? 0;
                        final occupiedRooms =
                            roomsSnapshot.data
                                ?.where((r) => !r.isAvailable)
                                .length ??
                            0;
                        final occupancyRate = totalRooms > 0
                            ? ((occupiedRooms / totalRooms) * 100)
                                  .toStringAsFixed(0)
                            : '0';

                        final payments = paymentsSnapshot.data ?? [];
                        final currentMonth = DateTime.now().month;
                        final currentYear = DateTime.now().year;
                        final monthRevenue = payments
                            .where(
                              (p) =>
                                  p.paymentType.contains(
                                    _getMonthName(currentMonth),
                                  ) &&
                                  p.paymentType.contains(
                                    currentYear.toString(),
                                  ),
                            )
                            .fold<double>(
                              0,
                              (sum, p) => sum + (p.paidAmount ?? 0),
                            );

                        final pendingPayments = payments
                            .where((p) => p.status == 'pending')
                            .length;

                        return GridView.count(
                          crossAxisCount: gridCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: isMobile ? 1 : 1.5,
                          children: [
                            ModernStatsCard(
                              title: 'Total Students',
                              value: totalStudents.toString(),
                              icon: Icons.people_rounded,
                              color: AppColors.studentColor,
                              subtitle: '$activeStudents active',
                            ),
                            ModernStatsCard(
                              title: 'Occupied Rooms',
                              value: '$occupancyRate%',
                              icon: Icons.meeting_room_rounded,
                              color: AppColors.wardenColor,
                              subtitle: '$occupiedRooms/$totalRooms rooms',
                            ),
                            ModernStatsCard(
                              title: 'Total Revenue',
                              value: AppCurrency.formatCompact(monthRevenue),
                              icon: Icons.attach_money_rounded,
                              color: AppColors.success,
                              subtitle: 'This month',
                            ),
                            ModernStatsCard(
                              title: 'Pending Payments',
                              value: pendingPayments.toString(),
                              icon: Icons.pending_rounded,
                              color: AppColors.warning,
                              subtitle: 'Requires attention',
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: AppSizes.paddingXLarge),

            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),

            GridView.count(
              crossAxisCount: gridCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isMobile
                  ? 1.8
                  : 2.2, // Very compact action cards
              children: [
                _buildQuickAction(
                  'Add Students',
                  Icons.people_rounded,
                  AppColors.studentColor,
                  () => setState(() => _selectedIndex = 1),
                ),
                _buildQuickAction(
                  'Add Rooms',
                  Icons.meeting_room_rounded,
                  AppColors.wardenColor,
                  () => setState(() => _selectedIndex = 2),
                ),
                _buildQuickAction(
                  'Add Payments',
                  Icons.payments_rounded,
                  AppColors.messManagerColor,
                  () => setState(() => _selectedIndex = 3),
                ),
                _buildQuickAction(
                  'Check Complaints',
                  Icons.feedback_rounded,
                  AppColors.error,
                  () => setState(() => _selectedIndex = 5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSizes.paddingSmall),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Widget _buildMoreScreen() {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'More Options',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Access additional admin features',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.paddingSmall),

          // Management Section
          _buildSectionHeader('Management'),
          ModernCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildMoreMenuItem(
                  icon: Icons.meeting_room_rounded,
                  title: 'Rooms',
                  subtitle: 'Manage hostel rooms',
                  color: AppColors.wardenColor,
                  onTap: () => setState(() => _selectedIndex = 5),
                ),
                const Divider(height: 1),
                _buildMoreMenuItem(
                  icon: Icons.feedback_rounded,
                  title: 'Complaints',
                  subtitle: 'Handle student complaints',
                  color: AppColors.error,
                  onTap: () => setState(() => _selectedIndex = 6),
                ),
                const Divider(height: 1),
                _buildMoreMenuItem(
                  icon: Icons.event_available_rounded,
                  title: 'Leaves',
                  subtitle: 'Approve leave requests',
                  color: AppColors.info,
                  onTap: () => setState(() => _selectedIndex = 7),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.paddingLarge),

          // User Management Section
          _buildSectionHeader('User Management'),
          ModernCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                StreamBuilder<List<dynamic>>(
                  stream: DatabaseService().getPendingUsers(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.length ?? 0;
                    return _buildMoreMenuItem(
                      icon: Icons.pending_actions_rounded,
                      title: 'Pending Users',
                      subtitle: count > 0 ? '$count pending approvals' : 'No pending approvals',
                      color: AppColors.warning,
                      badge: count > 0 ? count.toString() : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PendingUsersScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
                const Divider(height: 1),
                _buildMoreMenuItem(
                  icon: Icons.person_search_rounded,
                  title: 'All Users',
                  subtitle: 'View and manage all users',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UsersManagementScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildMoreMenuItem(
                  icon: Icons.bug_report_rounded,
                  title: 'Debug Student Links',
                  subtitle: 'Diagnose student-user linking issues',
                  color: AppColors.warning,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DebugStudentScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                _buildMoreMenuItem(
                  icon: Icons.link_rounded,
                  title: 'Fix Student Links',
                  subtitle: 'Link students to user accounts',
                  color: AppColors.info,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FixStudentUidsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.paddingLarge),

          // Settings Section
          _buildSectionHeader('Account'),
          ModernCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildMoreMenuItem(
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  subtitle: 'App preferences',
                  color: AppColors.textSecondary,
                  onTap: () => setState(() => _selectedIndex = 8),
                ),
                const Divider(height: 1),
                _buildMoreMenuItem(
                  icon: Icons.person_rounded,
                  title: 'Profile',
                  subtitle: user?.email ?? '',
                  color: AppColors.primary,
                  onTap: () => setState(() => _selectedIndex = 8),
                ),
                const Divider(height: 1),
                _buildMoreMenuItem(
                  icon: Icons.logout_rounded,
                  title: 'Sign Out',
                  subtitle: 'Logout from admin account',
                  color: AppColors.error,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text('Are you sure you want to sign out?'),
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

                    if (confirm == true && mounted) {
                      await context.read<AuthProvider>().signOut();
                      if (mounted) {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      }
                    }
                  },
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

  Widget _buildMoreMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return InkWell(
      onTap: onTap,
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
                  color: AppColors.error,
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
}
