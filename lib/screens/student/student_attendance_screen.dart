import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/attendance.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/constants.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  bool _isMarkingAttendance = false;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    final authProvider = context.read<AuthProvider>();
    final uid = authProvider.user?.uid;
    if (uid != null) {
      await context.read<AttendanceProvider>().fetchAttendance(studentId: uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final authProvider = context.watch<AuthProvider>();
    final userUid = authProvider.user?.uid;
    final stats = userUid != null
        ? attendanceProvider.getStudentStatistics(userUid)
        : <String, dynamic>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
        backgroundColor: AppColors.studentColor,
      ),
      body: attendanceProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsCard(stats),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadAttendance,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSizes.paddingSmall),
                      itemCount: attendanceProvider.attendance.length,
                      itemBuilder: (context, index) {
                        return _buildAttendanceCard(
                          attendanceProvider.attendance[index],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _markAttendance,
        icon: _isMarkingAttendance
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.check),
        label: const Text('Mark Attendance'),
        backgroundColor: AppColors.studentColor,
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    final percentage = double.tryParse(stats['percentage'] ?? '0') ?? 0;
    final total = stats['total'] ?? 0;
    final present = stats['present'] ?? 0;
    final absent = stats['absent'] ?? 0;

    Color percentageColor;
    if (percentage >= 80) {
      percentageColor = Colors.green;
    } else if (percentage >= 60) {
      percentageColor = Colors.orange;
    } else {
      percentageColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      color: AppColors.studentColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: percentageColor,
              ),
            ),
            const Text(
              'Attendance Percentage',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Total', total.toString(), Colors.blue),
                _buildStatItem('Present', present.toString(), Colors.green),
                _buildStatItem('Absent', absent.toString(), Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAttendanceCard(Attendance attendance) {
    final isPresent = attendance.status == 'present';
    final color = isPresent ? Colors.green : Colors.red;
    final icon = isPresent ? Icons.check_circle : Icons.cancel;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(_formatDate(attendance.date)),
        subtitle: Text(
          attendance.status.toUpperCase(),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          _formatTime(attendance.date),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  Future<void> _markAttendance() async {
    setState(() => _isMarkingAttendance = true);

    try {
      // Check if already marked
      final authProvider = context.read<AuthProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();
      final userUid = authProvider.user?.uid;

      if (userUid == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not authenticated')),
          );
        }
        return;
      }

      final isMarked = await attendanceProvider.isAttendanceMarkedToday(userUid);

      if (isMarked) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Attendance already marked for today'),
            ),
          );
        }
        return;
      }

      // Get location (with permission)
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          return;
        }
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (e) {
        // If location fetch fails, continue without it
        position = null;
      }

      // Mark attendance
      final attendance = Attendance(
        attendanceId: const Uuid().v4(),
        studentId: userUid,
        date: DateTime.now(),
        status: 'present',

        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      final success = await attendanceProvider.markAttendance(attendance);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Attendance marked successfully'
                  : 'Failed to mark attendance',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isMarkingAttendance = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
