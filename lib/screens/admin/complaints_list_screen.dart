import 'package:flutter/material.dart';
import '../../models/complaint.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_widget.dart';

class ComplaintsListScreen extends StatefulWidget {
  const ComplaintsListScreen({super.key});

  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  final DatabaseService _dbService = DatabaseService();
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
        backgroundColor: AppColors.wardenColor,
        automaticallyImplyLeading: context.isMobile,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: StreamBuilder<List<Complaint>>(
        stream: _dbService.getComplaints(
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
            return const LoadingWidget(message: 'Loading complaints...');
          }

          final complaints = snapshot.data ?? [];

          if (complaints.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.feedback_outlined,
              title: 'No complaints',
              message: 'No complaints found',
            );
          }

          return ListView.builder(
            itemCount: complaints.length,
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              return _buildComplaintCard(complaint);
            },
          );
        },
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    final statusColor = _getStatusColor(complaint.status);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(
            _getStatusIcon(complaint.status),
            color: statusColor,
          ),
        ),
        title: Text(
          complaint.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Category: ${complaint.category}'),
            Text('Student ID: ${complaint.studentId}'),
            Text(
              'Date: ${_formatDate(complaint.createdAt)}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                complaint.status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        trailing: complaint.status == 'pending'
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'assign') {
                    _assignComplaint(complaint);
                  } else if (value == 'resolve') {
                    _resolveComplaint(complaint);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'assign',
                    child: Text('Assign'),
                  ),
                  const PopupMenuItem(
                    value: 'resolve',
                    child: Text('Resolve'),
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
      case 'resolved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'in_progress':
        return Icons.hourglass_bottom;
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
        title: const Text('Filter Complaints'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('All', 'all'),
            _buildFilterOption('Pending', 'pending'),
            _buildFilterOption('In Progress', 'in_progress'),
            _buildFilterOption('Resolved', 'resolved'),
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

  void _assignComplaint(Complaint complaint) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Assign complaint feature - Coming soon'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _resolveComplaint(Complaint complaint) async {
    try {
      await _dbService.updateComplaint(complaint.complaintId, {
        'status': 'resolved',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint resolved'),
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
