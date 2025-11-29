import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import 'pending_users_screen.dart';

/// Navigation item model
class _NavItem {
  final IconData icon;
  final String label;
  final int route;

  _NavItem({required this.icon, required this.label, required this.route});
}

/// Main layout wrapper that provides sidebar navigation for web
class MainLayout extends StatefulWidget {
  final Widget child;
  final int selectedIndex;
  final Function(int) onNavigationChanged;

  const MainLayout({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.onNavigationChanged,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', route: 0),
    _NavItem(icon: Icons.people_rounded, label: 'Students', route: 1),
    _NavItem(icon: Icons.meeting_room_rounded, label: 'Rooms', route: 2),
    _NavItem(icon: Icons.payments_rounded, label: 'Payments', route: 3),
    _NavItem(icon: Icons.restaurant_rounded, label: 'Mess', route: 4),
    _NavItem(icon: Icons.feedback_rounded, label: 'Complaints', route: 5),
    _NavItem(icon: Icons.event_note_rounded, label: 'Leaves', route: 6),
    _NavItem(icon: Icons.settings_rounded, label: 'Settings', route: 7),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    if (isMobile) {
      // Mobile: just show the child
      return widget.child;
    }

    // Desktop: Show sidebar layout
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildDesktopAppBar(),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: AppSizes.paddingSmall),
                const Text(
                  'HMS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSizes.paddingSmall),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                return _buildSidebarItem(_navItems[index]);
              },
            ),
          ),

          // Logout
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text(
                'Logout',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
              onTap: _handleLogout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(_NavItem item) {
    final isSelected = widget.selectedIndex == item.route;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        onTap: () => widget.onNavigationChanged(item.route),
      ),
    );
  }

  Widget _buildDesktopAppBar() {
    final user = context.watch<AuthProvider>().currentUser;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXLarge),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.backgroundDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          _buildNotificationButton(),
          const SizedBox(width: AppSizes.paddingMedium),
          _buildUserAvatar(user?.name ?? 'A'),
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
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthProvider>().signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }
}
