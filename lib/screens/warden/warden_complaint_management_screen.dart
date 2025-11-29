import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/complaint.dart';
import '../../providers/complaint_provider.dart';
import '../../utils/constants.dart';

class WardenComplaintManagementScreen extends StatefulWidget {
  const WardenComplaintManagementScreen({super.key});

  @override
  State<WardenComplaintManagementScreen> createState() => _WardenComplaintManagementScreenState();
}

class _WardenComplaintManagementScreenState extends State<WardenComplaintManagementScreen> {
  String _filterStatus = 'pending';

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    await context.read<ComplaintProvider>().fetchComplaints();
  }

  @override
  Widget build(BuildContext context) {
    final complaintProvider = context.watch<ComplaintProvider>();
    var complaints = complaintProvider.complaints;
    
    if (_filterStatus != 'all') {
      complaints = complaints.where((c) => c.status == _filterStatus).toList();
    }

    // Sort by priority (urgent > high > medium > low)
    complaints.sort((a, b) {
      const priorityOrder = {'urgent': 0, 'high': 1, 'medium': 2, 'low': 3};
      return (priorityOrder[a.priority] ?? 3).compareTo(priorityOrder[b.priority] ?? 3);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Management'),
        backgroundColor: AppColors.wardenColor,
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
              ? Center(
                  child: Text(
                    _filterStatus == 'pending' 
                        ? 'No pending complaints'
                        : 'No complaints',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadComplaints,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingSmall),
                    itemCount: complaints.length,
                    itemBuilder: (context, index) => _buildComplaintCard(complaints[index]),
                  ),
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
      default:
        statusColor = Colors.orange;
    }

    Color priorityColor;
    switch (complaint.priority) {
      case 'urgent':
        priorityColor = Colors.red[700]!;
        break;
      case 'high':
        priorityColor = Colors.orange[700]!;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: ExpansionTile(
        leading: Icon(
          Icons.priority_high,
          color: priorityColor,
          size: 32,
        ),
        title: Text(complaint.title),
        subtitle: Text(
          '${complaint.category} • ${complaint.priority}',
          style: TextStyle(fontSize: 12, color: priorityColor),
        ),
        trailing: Chip(
          label: Text(
            complaint.status.toUpperCase(),
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
                _buildDetailRow('Student ID', complaint.studentId),
                _buildDetailRow('Category', complaint.category),
                _buildDetailRow('Priority', complaint.priority),
                _buildDetailRow('Description', complaint.description),
                _buildDetailRow('Submitted', _formatDate(complaint.createdAt)),
                if (complaint.response != null)
                  _buildDetailRow('Response', complaint.response!),
                const SizedBox(height: 16),
                if (complaint.status == 'pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateStatus(complaint, 'in-progress'),
                          child: const Text('Mark In Progress'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _resolveComplaint(complaint),
                          child: const Text('Resolve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (complaint.status == 'in-progress') ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _resolveComplaint(complaint),
                      child: const Text('Resolve Complaint'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
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

  Future<void> _updateStatus(Complaint complaint, String status) async {
    final success = await context.read<ComplaintProvider>()
        .updateComplaintStatus(complaint.complaintId, status);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Status updated' : 'Failed to update status',
          ),
        ),
      );
    }
  }

  Future<void> _resolveComplaint(Complaint complaint) async {
    final responseController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Complaint'),
        content: TextField(
          controller: responseController,
          decoration: const InputDecoration(
            labelText: 'Resolution details *',
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      if (responseController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide resolution details')),
        );
        return;
      }

      final success = await context.read<ComplaintProvider>()
          .resolveComplaint(complaint.complaintId, responseController.text);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Complaint resolved' : 'Failed to resolve complaint',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
