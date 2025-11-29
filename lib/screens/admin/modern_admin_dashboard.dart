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
    if (_selectedIndex == 2) return const RoomsListScreen();
    if (_selectedIndex == 3) return const PaymentsListScreen();
    if (_selectedIndex == 4) return const MessMenuScreen();
    if (_selectedIndex == 5) return const ComplaintsListScreen();
    if (_selectedIndex == 6) return const LeavesListScreen();
    if (_selectedIndex == 7) return const SettingsScreen();
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
}
