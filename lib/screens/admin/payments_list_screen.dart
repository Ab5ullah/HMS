import 'package:flutter/material.dart';
import '../../models/payment.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/modern_card.dart';
import '../../widgets/common/modern_text_field.dart';
import '../../widgets/common/modern_button.dart';
import 'add_payment_screen.dart';
import 'payment_detail_screen.dart';

class PaymentsListScreen extends StatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  State<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends State<PaymentsListScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'all';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header Section - Compact
          Container(
            padding: EdgeInsets.all(context.responsivePadding),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isMobile)
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingSmall),
                      decoration: BoxDecoration(
                        color: AppColors.messManagerColor.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        color: AppColors.messManagerColor,
                        size: AppSizes.iconLarge,
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payments',
                            style: isMobile
                                ? AppTextStyles.titleLarge
                                : AppTextStyles.headlineSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Manage student payments',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile)
                      ModernButton(
                        label: 'Add Payment',
                        icon: Icons.add,
                        onPressed: () => _navigateToAddPayment(),
                        color: AppColors.messManagerColor,
                      ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                Row(
                  children: [
                    Expanded(
                      child: ModernSearchField(
                        controller: _searchController,
                        hint: 'Search by student ID...',
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                        onClear: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingMedium),
                    ModernIconButton(
                      icon: Icons.filter_list_rounded,
                      onPressed: _showFilterDialog,
                      color: _statusFilter == 'all'
                          ? AppColors.textSecondary
                          : AppColors.messManagerColor,
                      outlined: true,
                      tooltip: 'Filter',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Payments List
          Expanded(
            child: StreamBuilder<List<Payment>>(
              stream: _dbService.getPayments(
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
                  return const LoadingWidget(message: 'Loading payments...');
                }

                var payments = snapshot.data ?? [];

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  payments = payments
                      .where(
                        (payment) => payment.studentId.toLowerCase().contains(
                          _searchQuery,
                        ),
                      )
                      .toList();
                }

                if (payments.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.payments_rounded,
                    title: 'No payments found',
                    message: _searchQuery.isNotEmpty
                        ? 'Try adjusting your search or filters'
                        : 'Add your first payment to get started',
                    action: _searchQuery.isEmpty
                        ? ModernButton(
                            label: 'Add Payment',
                            icon: Icons.add,
                            onPressed: () => _navigateToAddPayment(),
                            color: AppColors.messManagerColor,
                          )
                        : null,
                  );
                }

                return _buildPaymentsList(payments, isMobile);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => _navigateToAddPayment(),
              backgroundColor: AppColors.messManagerColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildPaymentsList(List<Payment> payments, bool isMobile) {
    if (isMobile) {
      return ListView.builder(
        itemCount: payments.length,
        padding: EdgeInsets.all(context.responsivePadding),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
            child: _buildPaymentCard(payments[index], true),
          );
        },
      );
    }

    // Desktop/Tablet: Constrained width with list view
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView.builder(
          padding: EdgeInsets.all(context.responsivePadding),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
              child: _buildPaymentCard(payments[index], false),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment, bool isMobile) {
    final statusColor = _getStatusColor(payment.status);

    return ModernCard(
      onTap: () => _navigateToPaymentDetail(payment),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      child: Row(
        children: [
          // Status Icon - Compact
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Icon(
              _getStatusIcon(payment.status),
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),

          // Payment Details - Compact
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${payment.paymentType} - ${payment.dueDate.toString().split(' ')[0]}',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        payment.status.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Student: ${payment.studentId}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total: ',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          AppCurrency.formatWithoutDecimals(
                            payment.totalAmount,
                          ),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    if (!payment.isFullyPaid)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Remaining: ',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            AppCurrency.formatWithoutDecimals(
                              payment.remainingAmount,
                            ),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Chevron
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'overdue':
        return AppColors.error;
      case 'partial':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      case 'overdue':
        return Icons.warning_rounded;
      case 'partial':
        return Icons.hourglass_bottom_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        title: Text('Filter Payments', style: AppTextStyles.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('All', 'all'),
            _buildFilterOption('Paid', 'paid'),
            _buildFilterOption('Pending', 'pending'),
            _buildFilterOption('Overdue', 'overdue'),
            _buildFilterOption('Partial', 'partial'),
          ],
        ),
        actions: [
          ModernButton(
            label: 'Close',
            variant: ModernButtonVariant.text,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _statusFilter,
      activeColor: AppColors.messManagerColor,
      onChanged: (value) {
        setState(() {
          _statusFilter = value!;
        });
        Navigator.pop(context);
      },
    );
  }

  void _navigateToAddPayment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPaymentScreen()),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Payment added successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
        ),
      );
    }
  }

  void _navigateToPaymentDetail(Payment payment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetailScreen(payment: payment),
      ),
    );
  }
}
