import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/room_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/leave_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/constants.dart';
import 'warden_leave_approval_screen.dart';
import 'warden_complaint_management_screen.dart';
import 'warden_attendance_report_screen.dart';
import 'warden_student_overview_screen.dart';
import '../admin/rooms_list_screen.dart';

class WardenDashboard extends StatefulWidget {
  const WardenDashboard({super.key});

  @override
  State<WardenDashboard> createState() => _WardenDashboardState();
}

class _WardenDashboardState extends State<WardenDashboard> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    await Future.wait([
      context.read<StudentProvider>().fetchStudents(),
      context.read<RoomProvider>().fetchRooms(),
      context.read<ComplaintProvider>().fetchComplaints(),
      context.read<LeaveProvider>().fetchLeaves(),
      context.read<AttendanceProvider>().fetchAttendance(),
    ]);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warden Dashboard'),
        backgroundColor: AppColors.wardenColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(authProvider),
                    const SizedBox(height: AppSizes.paddingMedium),
                    _buildQuickStats(),
                    const SizedBox(height: AppSizes.paddingMedium),
                    _buildQuickActions(),
                    const SizedBox(height: AppSizes.paddingMedium),
                    _buildPendingTasks(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeCard(AuthProvider authProvider) {
    return Card(
      color: AppColors.wardenColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.wardenColor,
              child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${authProvider.user?.name ?? "Warden"}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hostel Management',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final studentProvider = context.watch<StudentProvider>();
    final roomProvider = context.watch<RoomProvider>();
    final complaintProvider = context.watch<ComplaintProvider>();
    final leaveProvider = context.watch<LeaveProvider>();

    final studentStats = studentProvider.getStatistics();
    final roomStats = roomProvider.getStatistics();
    final complaintStats = complaintProvider.getStatistics();
    
    final pendingLeaves = leaveProvider.getPendingLeaves().length;
    final pendingComplaints = complaintProvider.getPendingComplaints().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSizes.paddingSmall,
          crossAxisSpacing: AppSizes.paddingSmall,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total Students',
              '${studentStats['active'] ?? 0}',
              Icons.people,
              Colors.blue,
            ),
            _buildStatCard(
              'Total Rooms',
              '${roomStats['total'] ?? 0}',
              Icons.meeting_room,
              Colors.green,
            ),
            _buildStatCard(
              'Pending Leaves',
              '$pendingLeaves',
              Icons.event_busy,
              Colors.orange,
            ),
            _buildStatCard(
              'Open Complaints',
              '$pendingComplaints',
              Icons.report_problem,
              Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to relevant screen
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingSmall),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: AppSizes.paddingSmall,
          crossAxisSpacing: AppSizes.paddingSmall,
          childAspectRatio: 1,
          children: [
            _buildActionCard(
              'Students',
              Icons.people,
              AppColors.studentColor,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WardenStudentOverviewScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Rooms',
              Icons.meeting_room,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RoomsListScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Leaves',
              Icons.event_note,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WardenLeaveApprovalScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Complaints',
              Icons.report,
              Colors.red,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WardenComplaintManagementScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Attendance',
              Icons.check_box,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WardenAttendanceReportScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Reports',
              Icons.analytics,
              Colors.purple,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reports coming soon!')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTasks() {
    final complaintProvider = context.watch<ComplaintProvider>();
    final leaveProvider = context.watch<LeaveProvider>();

    final pendingComplaints = complaintProvider.getPendingComplaints().take(3).toList();
    final pendingLeaves = leaveProvider.getPendingLeaves().take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pending Tasks',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        if (pendingComplaints.isEmpty && pendingLeaves.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: Center(child: Text('No pending tasks')),
            ),
          )
        else
          Column(
            children: [
              if (pendingLeaves.isNotEmpty) ...[
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.event_note, color: Colors.blue),
                        title: Text('${pendingLeaves.length} Pending Leave Requests'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WardenLeaveApprovalScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (pendingComplaints.isNotEmpty) ...[
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.report, color: Colors.red),
                        title: Text('${pendingComplaints.length} Open Complaints'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WardenComplaintManagementScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
