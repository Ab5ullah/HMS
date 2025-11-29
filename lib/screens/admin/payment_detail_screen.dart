import 'package:flutter/material.dart';
import '../../models/payment.dart';
import '../../models/student.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/common/loading_widget.dart';

class PaymentDetailScreen extends StatefulWidget {
  final Payment payment;

  const PaymentDetailScreen({super.key, required this.payment});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment - ${widget.payment.paymentType}'),
        backgroundColor: AppColors.messManagerColor,
        actions: [
          if (widget.payment.status != 'paid')
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'mark_paid') {
                  _markAsPaid();
                } else if (value == 'record_partial') {
                  _recordPartialPayment();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_paid',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Mark as Paid'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'record_partial',
                  child: Row(
                    children: [
                      Icon(Icons.payment, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Record Partial Payment'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(widget.payment.status),
                    size: 60,
                    color: _getStatusColor(widget.payment.status),
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  Text(
                    widget.payment.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(widget.payment.status),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          const Text(
            'Student Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          FutureBuilder<Student?>(
            future: _dbService.getStudent(widget.payment.studentId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget();
              }

              final student = snapshot.data;
              if (student == null) {
                return InfoCard(
                  label: 'Student ID',
                  value: widget.payment.studentId,
                  icon: Icons.person,
                );
              }

              return Column(
                children: [
                  InfoCard(
                    label: 'Name',
                    value: student.name,
                    icon: Icons.person,
                  ),
                  InfoCard(
                    label: 'Email',
                    value: student.email,
                    icon: Icons.email,
                  ),
                  if (student.phoneNumber != null)
                    InfoCard(
                      label: 'Phone',
                      value: student.phoneNumber!,
                      icon: Icons.phone,
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          const Text(
            'Payment Period',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          InfoCard(
            label: 'Month',
            value: widget.payment.paymentType,
            icon: Icons.calendar_today,
          ),
          InfoCard(
            label: 'Year',
            value: widget.payment.dueDate.year.toString(),
            icon: Icons.event,
          ),

          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹${widget.payment.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          const Text(
            'Payment Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          InfoCard(
            label: 'Paid Amount',
            value: '₹${widget.payment.paidAmount.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
          if (!widget.payment.isFullyPaid)
            InfoCard(
              label: 'Remaining Amount',
              value: '₹${widget.payment.remainingAmount.toStringAsFixed(2)}',
              icon: Icons.money_off,
              color: Colors.red,
            ),
          InfoCard(
            label: 'Due Date',
            value: _formatDate(widget.payment.dueDate),
            icon: Icons.event,
            color: _isDue(widget.payment.dueDate) ? Colors.red : Colors.blue,
          ),
          if (widget.payment.paidDate != null)
            InfoCard(
              label: 'Payment Date',
              value: _formatDate(widget.payment.paidDate!),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
          if (widget.payment.transactionId != null)
            InfoCard(
              label: 'Transaction ID',
              value: widget.payment.transactionId!,
              icon: Icons.confirmation_number,
            ),
          if (widget.payment.remarks != null) ...[
            const SizedBox(height: AppSizes.paddingLarge),
            const Text(
              'Remarks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Text(widget.payment.remarks!),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'partial':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'overdue':
        return Icons.warning;
      case 'partial':
        return Icons.hourglass_bottom;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _isDue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  void _markAsPaid() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Paid'),
        content: const Text(
          'Are you sure you want to mark this payment as paid?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await _dbService.updatePayment(widget.payment.paymentId, {
        'status': 'paid',
        'paidAmount': widget.payment.totalAmount,
        'paymentDate': DateTime.now(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment marked as paid'),
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

  void _recordPartialPayment() async {
    final amountController = TextEditingController();
    final transactionIdController = TextEditingController();
    String paymentMethod = 'Cash';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Partial Payment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: ['Cash', 'Card', 'UPI', 'Net Banking', 'Cheque']
                    .map(
                      (method) =>
                          DropdownMenuItem(value: method, child: Text(method)),
                    )
                    .toList(),
                onChanged: (value) {
                  paymentMethod = value!;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: transactionIdController,
                decoration: const InputDecoration(
                  labelText: 'Transaction ID (Optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Record'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newPaidAmount = widget.payment.paidAmount + amount;
    final newStatus = newPaidAmount >= widget.payment.totalAmount
        ? 'paid'
        : 'partial';

    try {
      await _dbService.updatePayment(widget.payment.paymentId, {
        'paidAmount': newPaidAmount,
        'status': newStatus,
        'paymentMethod': paymentMethod,
        if (transactionIdController.text.isNotEmpty)
          'transactionId': transactionIdController.text,
        if (newStatus == 'paid') 'paymentDate': DateTime.now(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Partial payment recorded'),
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
