import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/leave.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';
import '../../utils/constants.dart';

class StudentLeaveScreen extends StatefulWidget {
  const StudentLeaveScreen({super.key});

  @override
  State<StudentLeaveScreen> createState() => _StudentLeaveScreenState();
}

class _StudentLeaveScreenState extends State<StudentLeaveScreen> {
  @override
  void initState() {
    super.initState();
    _loadLeaves();
  }

  Future<void> _loadLeaves() async {
    final authProvider = context.read<AuthProvider>();
    final uid = authProvider.user?.uid;
    if (uid != null) {
      await context.read<LeaveProvider>().fetchLeaves(studentId: uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaveProvider = context.watch<LeaveProvider>();
    final leaves = leaveProvider.leaves;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Leaves'),
        backgroundColor: AppColors.studentColor,
      ),
      body: leaveProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : leaves.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadLeaves,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingSmall),
                    itemCount: leaves.length,
                    itemBuilder: (context, index) => _buildLeaveCard(leaves[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showApplyLeaveDialog,
        icon: const Icon(Icons.add),
        label: const Text('Apply Leave'),
        backgroundColor: AppColors.studentColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No leave applications',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showApplyLeaveDialog,
            icon: const Icon(Icons.add),
            label: const Text('Apply for Leave'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveCard(Leave leave) {
    Color statusColor;
    IconData statusIcon;
    switch (leave.status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: InkWell(
        onTap: () => _showLeaveDetails(leave),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    leave.leaveType.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      leave.status.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: statusColor,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(leave.fromDate)} - ${_formatDate(leave.toDate)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_calculateDays(leave.fromDate, leave.toDate)} days',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                leave.reason,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLeaveDetails(Leave leave) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${leave.leaveType} Leave'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', leave.leaveType),
              _buildDetailRow('Status', leave.status),
              _buildDetailRow('From', _formatDate(leave.fromDate)),
              _buildDetailRow('To', _formatDate(leave.toDate)),
              _buildDetailRow('Duration', '${_calculateDays(leave.fromDate, leave.toDate)} days'),
              _buildDetailRow('Applied', _formatDate(leave.createdAt)),
              const Divider(),
              const Text(
                'Reason:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(leave.reason),
              if (leave.status == 'approved' && leave.approvedBy != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                _buildDetailRow('Approved By', leave.approvedBy!),
                if (leave.approvedAt != null)
                  _buildDetailRow('Approved On', _formatDate(leave.approvedAt!)),
              ],
              if (leave.status == 'rejected') ...[
                const SizedBox(height: 16),
                const Divider(),
                const Text(
                  'Rejection Reason:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(leave.rejectionReason ?? 'No reason provided'),
              ],
            ],
          ),
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

  void _showApplyLeaveDialog() {
    String leaveType = 'home';
    final reasonController = TextEditingController();
    DateTime fromDate = DateTime.now();
    DateTime toDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Apply for Leave'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: leaveType,
                  decoration: const InputDecoration(
                    labelText: 'Leave Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['home', 'medical', 'emergency', 'vacation']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (val) => setState(() => leaveType = val!),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('From Date'),
                  subtitle: Text(_formatDate(fromDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: fromDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => fromDate = date);
                  },
                ),
                ListTile(
                  title: const Text('To Date'),
                  subtitle: Text(_formatDate(toDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: toDate,
                      firstDate: fromDate,
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => toDate = date);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (reasonController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a reason')),
                  );
                  return;
                }

                final authProvider = context.read<AuthProvider>();
                final leave = Leave(
                  leaveId: const Uuid().v4(),
                  studentId: authProvider.user!.uid,
                  leaveType: leaveType,
                  fromDate: fromDate,
                  toDate: toDate,
                  reason: reasonController.text,
                  status: 'pending',
                  createdAt: DateTime.now(),
                );

                Navigator.pop(context);
                final success = await context.read<LeaveProvider>().submitLeave(leave);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Leave application submitted successfully'
                            : 'Failed to submit leave application',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int _calculateDays(DateTime from, DateTime to) {
    return to.difference(from).inDays + 1;
  }
}
