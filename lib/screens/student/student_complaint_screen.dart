import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/complaint.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../utils/constants.dart';

class StudentComplaintScreen extends StatefulWidget {
  const StudentComplaintScreen({super.key});

  @override
  State<StudentComplaintScreen> createState() => _StudentComplaintScreenState();
}

class _StudentComplaintScreenState extends State<StudentComplaintScreen> {
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    final authProvider = context.read<AuthProvider>();
    final uid = authProvider.user?.uid;
    if (uid != null) {
      await context.read<ComplaintProvider>().fetchComplaints(studentId: uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaintProvider = context.watch<ComplaintProvider>();
    
    var complaints = complaintProvider.complaints;
    if (_filterStatus != 'all') {
      complaints = complaints.where((c) => c.status == _filterStatus).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
        backgroundColor: AppColors.studentColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: complaintProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : complaints.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadComplaints,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingSmall),
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      return _buildComplaintCard(complaints[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSubmitComplaintDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Complaint'),
        backgroundColor: AppColors.studentColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.report_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No complaints found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showSubmitComplaintDialog,
            icon: const Icon(Icons.add),
            label: const Text('Submit Complaint'),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    Color statusColor;
    switch (complaint.status) {
      case 'resolved':
        statusColor = Colors.green;
        break;
      case 'in-progress':
        statusColor = Colors.blue;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    Color priorityColor;
    switch (complaint.priority) {
      case 'urgent':
        priorityColor = Colors.red[700]!;
        break;
      case 'high':
        priorityColor = Colors.orange[700]!;
        break;
      case 'medium':
        priorityColor = Colors.blue;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: InkWell(
        onTap: () => _showComplaintDetails(complaint),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      complaint.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(
                      complaint.status.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: statusColor,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                complaint.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.category, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    complaint.category,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.priority_high, size: 14, color: priorityColor),
                  const SizedBox(width: 4),
                  Text(
                    complaint.priority,
                    style: TextStyle(fontSize: 12, color: priorityColor),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(complaint.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComplaintDetails(Complaint complaint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(complaint.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Category', complaint.category),
              _buildDetailRow('Priority', complaint.priority),
              _buildDetailRow('Status', complaint.status),
              _buildDetailRow('Submitted', _formatDate(complaint.createdAt)),
              const Divider(),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(complaint.description),
              if (complaint.response != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const Text(
                  'Response:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(complaint.response!),
                if (complaint.resolvedAt != null)
                  Text(
                    '\nResolved on: ${_formatDate(complaint.resolvedAt!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
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
            width: 80,
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
            _buildFilterOption('In Progress', 'in-progress'),
            _buildFilterOption('Resolved', 'resolved'),
            _buildFilterOption('Closed', 'closed'),
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

  void _showSubmitComplaintDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String category = 'maintenance';
    String priority = 'medium';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Submit Complaint'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: ['maintenance', 'food', 'security', 'cleanliness', 'other']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => category = val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: ['low', 'medium', 'high', 'urgent']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) => setState(() => priority = val!),
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
                if (titleController.text.isEmpty || descController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final authProvider = context.read<AuthProvider>();
                final complaint = Complaint(
                  complaintId: const Uuid().v4(),
                  studentId: authProvider.user!.uid,
                  title: titleController.text,
                  description: descController.text,
                  category: category,
                  priority: priority,
                  status: 'pending',
                  createdAt: DateTime.now(),
                );

                Navigator.pop(context);
                final success = await context.read<ComplaintProvider>().addComplaint(complaint);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Complaint submitted successfully'
                            : 'Failed to submit complaint',
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
}
