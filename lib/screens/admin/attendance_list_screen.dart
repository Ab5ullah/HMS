import 'package:flutter/material.dart';
import '../../models/attendance.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_widget.dart';

class AttendanceListScreen extends StatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  final DatabaseService _dbService = DatabaseService();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: AppColors.staffColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selected Date:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Attendance>>(
              stream: _dbService.getAttendance(date: _selectedDate),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorDisplayWidget(
                    message: snapshot.error.toString(),
                    onRetry: () {
                      setState(() {});
                    },
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'Loading attendance...');
                }

                final attendanceList = snapshot.data ?? [];

                if (attendanceList.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.check_circle_outline,
                    title: 'No attendance records',
                    message: 'No attendance marked for this date',
                  );
                }

                return ListView.builder(
                  itemCount: attendanceList.length,
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  itemBuilder: (context, index) {
                    final attendance = attendanceList[index];
                    return _buildAttendanceCard(attendance);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _markAttendance,
        backgroundColor: AppColors.staffColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAttendanceCard(Attendance attendance) {
    final isPresent = attendance.status.toLowerCase() == 'present';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPresent
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.red.withValues(alpha: 0.1),
          child: Icon(
            isPresent ? Icons.check : Icons.close,
            color: isPresent ? Colors.green : Colors.red,
          ),
        ),
        title: Text('Student ID: ${attendance.studentId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              attendance.status.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPresent ? Colors.green : Colors.red,
              ),
            ),
            if (attendance.checkInTime != null)
              Text('Check In: ${attendance.checkInTime}'),
            if (attendance.checkOutTime != null)
              Text('Check Out: ${attendance.checkOutTime}'),
            if (attendance.remarks != null)
              Text('Remarks: ${attendance.remarks}'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _markAttendance() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mark attendance feature - Coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
