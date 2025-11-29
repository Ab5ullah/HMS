import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/constants.dart';

class WardenAttendanceReportScreen extends StatefulWidget {
  const WardenAttendanceReportScreen({super.key});

  @override
  State<WardenAttendanceReportScreen> createState() => _WardenAttendanceReportScreenState();
}

class _WardenAttendanceReportScreenState extends State<WardenAttendanceReportScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    await context.read<AttendanceProvider>().fetchAttendance(date: _selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final stats = attendanceProvider.getStatistics();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Report'),
        backgroundColor: AppColors.wardenColor,
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          _buildStatsCard(stats),
          Expanded(
            child: attendanceProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : attendanceProvider.attendance.isEmpty
                    ? const Center(child: Text('No attendance records'))
                    : RefreshIndicator(
                        onRefresh: _loadAttendance,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSizes.paddingSmall),
                          itemCount: attendanceProvider.attendance.length,
                          itemBuilder: (context, index) {
                            final record = attendanceProvider.attendance[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: record.status == 'present' 
                                      ? Colors.green 
                                      : Colors.red,
                                  child: Icon(
                                    record.status == 'present' 
                                        ? Icons.check 
                                        : Icons.close,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text('Student: ${record.studentId}'),
                                subtitle: Text(
                                  '${_formatDate(record.date)} - ${record.status.toUpperCase()}',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: AppColors.wardenColor),
        title: const Text('Select Date'),
        subtitle: Text(_formatDate(_selectedDate)),
        trailing: const Icon(Icons.arrow_drop_down),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (date != null) {
            setState(() => _selectedDate = date);
            _loadAttendance();
          }
        },
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('Present', '${stats['presentToday'] ?? 0}', Colors.green),
            _buildStatItem('Absent', '${stats['absentToday'] ?? 0}', Colors.red),
            _buildStatItem('Total', '${stats['total'] ?? 0}', Colors.blue),
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
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
