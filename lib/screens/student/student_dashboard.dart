import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/leave_provider.dart';
import '../../utils/constants.dart';
import 'student_profile_screen.dart';
import 'student_complaint_screen.dart';
import 'student_leave_screen.dart';
import 'student_payment_screen.dart';
import 'student_attendance_screen.dart';
import 'student_mess_menu_screen.dart';
import 'student_room_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Student? _currentStudent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final uid = authProvider.user?.uid;

      if (uid == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not authenticated')),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      // Load student data
      final studentProvider = context.read<StudentProvider>();
      final student = await studentProvider.getStudentByUid(uid);

      if (student != null && mounted) {
        setState(() => _currentStudent = student);

        // Load related data
        if (mounted) {
          context.read<PaymentProvider>().fetchPayments(studentId: student.studentId);
          context.read<AttendanceProvider>().fetchAttendance(studentId: uid);
          context.read<ComplaintProvider>().fetchComplaints(studentId: uid);
          context.read<LeaveProvider>().fetchLeaves(studentId: uid);
        }
      } else if (mounted) {
        // Student profile not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student profile not found. Please contact administration.'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: AppColors.studentColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentStudent == null
              ? _buildNoProfileState()
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
                        _buildRecentActivity(),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildNoProfileState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Student Profile Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your student profile has not been created yet.\nPlease contact the administration.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.studentColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                final authProvider = context.read<AuthProvider>();
                await authProvider.signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(AuthProvider authProvider) {
    return Card(
      color: AppColors.studentColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.studentColor,
              child: Text(
                _currentStudent!.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${_currentStudent!.name.split(' ').first}!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Student ID: ${_currentStudent!.studentId}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _currentStudent!.course != null && _currentStudent!.department != null
                        ? '${_currentStudent!.course} - ${_currentStudent!.department}'
                        : _currentStudent!.course ?? _currentStudent!.department ?? 'Student',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
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
    final paymentProvider = context.watch<PaymentProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final complaintProvider = context.watch<ComplaintProvider>();
    final leaveProvider = context.watch<LeaveProvider>();

    final payments = paymentProvider.payments;
    final duePayments = payments.where((p) => p.status != 'paid').toList();
    final totalDue = duePayments.fold<double>(0, (sum, p) => sum + p.dueAmount);

    final studentUid = _currentStudent?.uid;
    final attendanceStats = studentUid != null
        ? attendanceProvider.getStudentStatistics(studentUid)
        : <String, dynamic>{};
    final attendancePercentage = attendanceStats['percentage'] ?? '0';

    final pendingComplaints = complaintProvider.complaints
        .where((c) => c.status == 'pending' || c.status == 'in-progress')
        .length;

    final pendingLeaves = leaveProvider.leaves
        .where((l) => l.status == 'pending')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Overview',
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
              'Attendance',
              '$attendancePercentage%',
              Icons.check_circle,
              Colors.green,
            ),
            _buildStatCard(
              'Due Amount',
              '₹${totalDue.toStringAsFixed(0)}',
              Icons.payment,
              Colors.orange,
            ),
            _buildStatCard(
              'Open Complaints',
              '$pendingComplaints',
              Icons.report_problem,
              Colors.red,
            ),
            _buildStatCard(
              'Pending Leaves',
              '$pendingLeaves',
              Icons.event_busy,
              Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
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
                fontSize: 20,
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
              'Profile',
              Icons.person,
              AppColors.studentColor,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentProfileScreen(student: _currentStudent!),
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
                  builder: (context) => const StudentComplaintScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Leave',
              Icons.event_note,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentLeaveScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Payments',
              Icons.payment,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentPaymentScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Attendance',
              Icons.check_box,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentAttendanceScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Mess Menu',
              Icons.restaurant_menu,
              Colors.amber,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentMessMenuScreen(),
                ),
              ),
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

  Widget _buildRecentActivity() {
    final complaintProvider = context.watch<ComplaintProvider>();
    final leaveProvider = context.watch<LeaveProvider>();

    final recentComplaints = complaintProvider.complaints.take(3).toList();
    final recentLeaves = leaveProvider.leaves.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        if (recentComplaints.isEmpty && recentLeaves.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: Center(child: Text('No recent activity')),
            ),
          )
        else
          Column(
            children: [
              ...recentComplaints.map((complaint) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.report, color: Colors.red),
                      title: Text(complaint.title),
                      subtitle: Text(complaint.status),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  )),
              ...recentLeaves.map((leave) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.event_note, color: Colors.blue),
                      title: Text('${leave.leaveType} Leave'),
                      subtitle: Text(leave.status),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  )),
            ],
          ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.studentColor,
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            // Home - already here
            break;
          case 1:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon!')),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentProfileScreen(student: _currentStudent!),
              ),
            );
            break;
          case 3:
            _showLogoutDialog();
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Logout',
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
