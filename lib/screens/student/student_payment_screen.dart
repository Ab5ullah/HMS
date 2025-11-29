import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/student_provider.dart';
import '../../utils/constants.dart';

class StudentPaymentScreen extends StatefulWidget {
  const StudentPaymentScreen({super.key});

  @override
  State<StudentPaymentScreen> createState() => _StudentPaymentScreenState();
}

class _StudentPaymentScreenState extends State<StudentPaymentScreen> {
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final authProvider = context.read<AuthProvider>();
    final uid = authProvider.user?.uid;
    if (uid != null) {
      final student = await context.read<StudentProvider>().getStudentByUid(uid);
      if (student != null) {
        await context.read<PaymentProvider>().fetchPayments(studentId: student.studentId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentProvider>();
    
    var payments = paymentProvider.payments;
    if (_filterStatus != 'all') {
      payments = payments.where((p) => p.status == _filterStatus).toList();
    }

    final totalDue = payments.fold<double>(0, (sum, p) => sum + p.dueAmount);
    final totalPaid = payments.fold<double>(0, (sum, p) => sum + p.paidAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Payments'),
        backgroundColor: AppColors.studentColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: paymentProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSummaryCard(totalPaid, totalDue),
                Expanded(
                  child: payments.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadPayments,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(AppSizes.paddingSmall),
                            itemCount: payments.length,
                            itemBuilder: (context, index) => _buildPaymentCard(payments[index]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(double totalPaid, double totalDue) {
    return Card(
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      color: AppColors.studentColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'Total Paid',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '₹${totalPaid.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 60,
              color: Colors.grey[300],
            ),
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.pending, color: Colors.orange, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'Total Due',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '₹${totalDue.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No payment records',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    Color statusColor;
    IconData statusIcon;
    switch (payment.status) {
      case 'paid':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'partial':
        statusColor = Colors.blue;
        statusIcon = Icons.pending;
        break;
      case 'overdue':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: InkWell(
        onTap: () => _showPaymentDetails(payment),
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
                  Expanded(
                    child: Text(
                      payment.paymentType.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(
                      payment.status.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: statusColor,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '₹${payment.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paid',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '₹${payment.paidAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '₹${payment.dueAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${_formatDate(payment.dueDate)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (payment.status == 'paid' && payment.paidDate != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.check, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Paid: ${_formatDate(payment.paidDate!)}',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentDetails(Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(payment.paymentType),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Payment ID', payment.paymentId),
              _buildDetailRow('Type', payment.paymentType),
              _buildDetailRow('Status', payment.status),
              const Divider(),
              _buildDetailRow('Total Amount', '₹${payment.amount.toStringAsFixed(2)}'),
              _buildDetailRow('Paid Amount', '₹${payment.paidAmount.toStringAsFixed(2)}'),
              _buildDetailRow('Due Amount', '₹${payment.dueAmount.toStringAsFixed(2)}'),
              const Divider(),
              _buildDetailRow('Due Date', _formatDate(payment.dueDate)),
              if (payment.paidDate != null)
                _buildDetailRow('Paid Date', _formatDate(payment.paidDate!)),
              if (payment.transactionId != null)
                _buildDetailRow('Transaction ID', payment.transactionId!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (payment.status != 'paid')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Online payment coming soon!')),
                );
              },
              child: const Text('Pay Now'),
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
            width: 120,
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
            _buildFilterOption('Partial', 'partial'),
            _buildFilterOption('Paid', 'paid'),
            _buildFilterOption('Overdue', 'overdue'),
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
