import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/leave.dart';
import '../../providers/leave_provider.dart';
import '../../utils/constants.dart';

class WardenLeaveApprovalScreen extends StatefulWidget {
  const WardenLeaveApprovalScreen({super.key});

  @override
  State<WardenLeaveApprovalScreen> createState() => _WardenLeaveApprovalScreenState();
}

class _WardenLeaveApprovalScreenState extends State<WardenLeaveApprovalScreen> {
  String _filterStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _loadLeaves();
  }

  Future<void> _loadLeaves() async {
    await context.read<LeaveProvider>().fetchLeaves();
  }

  @override
  Widget build(BuildContext context) {
    final leaveProvider = context.watch<LeaveProvider>();
    var leaves = leaveProvider.leaves;
    
    if (_filterStatus != 'all') {
      leaves = leaves.where((l) => l.status == _filterStatus).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Approvals'),
        backgroundColor: AppColors.wardenColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: leaveProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : leaves.isEmpty
              ? Center(
                  child: Text(
                    _filterStatus == 'pending' 
                        ? 'No pending leave requests'
                        : 'No leave requests',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLeaves,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingSmall),
                    itemCount: leaves.length,
                    itemBuilder: (context, index) => _buildLeaveCard(leaves[index]),
                  ),
                ),
    );
  }

  Widget _buildLeaveCard(Leave leave) {
    Color statusColor;
    switch (leave.status) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(Icons.event_note, color: statusColor),
        ),
        title: Text('${leave.leaveType} Leave'),
        subtitle: Text(
          '${_formatDate(leave.fromDate)} - ${_formatDate(leave.toDate)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Chip(
          label: Text(
            leave.status.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          backgroundColor: statusColor,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Student ID', leave.studentId),
                _buildDetailRow('Duration', '${_calculateDays(leave.fromDate, leave.toDate)} days'),
                _buildDetailRow('Reason', leave.reason),
                _buildDetailRow('Applied', _formatDate(leave.createdAt)),
                if (leave.status == 'pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _approveLeave(leave),
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _rejectLeave(leave),
                          icon: const Icon(Icons.close),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _approveLeave(Leave leave) async {
    final leaveProvider = context.read<LeaveProvider>();
    final success = await leaveProvider.approveLeave(leave.leaveId, 'warden');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Leave approved successfully' : 'Failed to approve leave',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectLeave(Leave leave) async {
    final reasonController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Leave'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final leaveProvider = context.read<LeaveProvider>();
      final success = await leaveProvider.rejectLeave(
        leave.leaveId,
        'warden',
        reasonController.text.isEmpty ? null : reasonController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Leave rejected' : 'Failed to reject leave',
            ),
            backgroundColor: success ? Colors.red : Colors.grey,
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('All', 'all'),
            _buildFilterOption('Pending', 'pending'),
            _buildFilterOption('Approved', 'approved'),
            _buildFilterOption('Rejected', 'rejected'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _filterStatus,
      onChanged: (val) {
        setState(() => _filterStatus = val!);
        Navigator.pop(context);
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateDays(DateTime from, DateTime to) {
    return to.difference(from).inDays + 1;
  }
}
