import 'package:flutter/material.dart';
import '../../models/leave.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_widget.dart';

class LeavesListScreen extends StatefulWidget {
  const LeavesListScreen({super.key});

  @override
  State<LeavesListScreen> createState() => _LeavesListScreenState();
}

class _LeavesListScreenState extends State<LeavesListScreen> {
  final DatabaseService _dbService = DatabaseService();
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Requests'),
        backgroundColor: AppColors.wardenColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: StreamBuilder<List<Leave>>(
        stream: _dbService.getLeaves(
          status: _statusFilter == 'all' ? null : _statusFilter,
        ),
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
            return const LoadingWidget(message: 'Loading leave requests...');
          }

          final leaves = snapshot.data ?? [];

          if (leaves.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.event_available,
              title: 'No leave requests',
              message: 'No leave requests found',
            );
          }

          return ListView.builder(
            itemCount: leaves.length,
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            itemBuilder: (context, index) {
              final leave = leaves[index];
              return _buildLeaveCard(leave);
            },
          );
        },
      ),
    );
  }

  Widget _buildLeaveCard(Leave leave) {
    final statusColor = _getStatusColor(leave.status);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(
            _getStatusIcon(leave.status),
            color: statusColor,
          ),
        ),
        title: Text(
          'Student ID: ${leave.studentId}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('From: ${_formatDate(leave.fromDate)}'),
            Text('To: ${_formatDate(leave.toDate)}'),
            Text('Reason: ${leave.reason}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                leave.status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        trailing: leave.status == 'pending'
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'approve') {
                    _updateLeaveStatus(leave.leaveId, 'approved');
                  } else if (value == 'reject') {
                    _updateLeaveStatus(leave.leaveId, 'rejected');
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'approve',
                    child: Text('Approve'),
                  ),
                  const PopupMenuItem(
                    value: 'reject',
                    child: Text('Reject'),
                  ),
                ],
              )
            : null,
        isThreeLine: true,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Leaves'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('All', 'all'),
            _buildFilterOption('Pending', 'pending'),
            _buildFilterOption('Approved', 'approved'),
            _buildFilterOption('Rejected', 'rejected'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String title, String value) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: _statusFilter,
      onChanged: (val) {
        setState(() {
          _statusFilter = val!;
        });
        Navigator.pop(context);
      },
    );
  }

  void _updateLeaveStatus(String leaveId, String status) async {
    try {
      await _dbService.updateLeave(leaveId, {'status': status});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Leave $status successfully'),
            backgroundColor: Colors.green,
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
    }
  }
}
