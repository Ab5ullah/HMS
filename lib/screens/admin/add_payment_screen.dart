import 'package:flutter/material.dart';
import '../../models/payment.dart';
import '../../models/student.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/common/modern_card.dart';
import '../../widgets/common/modern_text_field.dart';
import '../../widgets/common/modern_button.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  final _hostelFeeController = TextEditingController();
  final _messFeeController = TextEditingController();
  final _otherChargesController = TextEditingController();
  final _remarksController = TextEditingController();

  String? _selectedStudentId;
  String _selectedMonth = 'January';
  int _selectedYear = DateTime.now().year;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void dispose() {
    _hostelFeeController.dispose();
    _messFeeController.dispose();
    _otherChargesController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    final hostelFee = double.tryParse(_hostelFeeController.text) ?? 0;
    final messFee = double.tryParse(_messFeeController.text) ?? 0;
    final otherCharges = double.tryParse(_otherChargesController.text) ?? 0;
    return hostelFee + messFee + otherCharges;
  }

  Future<void> _savePayment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a student'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final payment = Payment(
        paymentId: '',
        studentId: _selectedStudentId!,
        amount: _totalAmount,
        paymentType: '$_selectedMonth $_selectedYear',
        dueDate: _dueDate,
        status: 'pending',
        paidAmount: 0.0,
        dueAmount: _totalAmount,
        createdAt: DateTime.now(),
        remarks: _remarksController.text.trim().isNotEmpty
            ? _remarksController.text.trim()
            : null,
      );

      await _dbService.createPayment(payment);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Payment',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: EdgeInsets.all(context.responsivePadding),
              children: [
                // Student Information Section
                _buildSectionCard(
                  title: 'Student Information',
                  icon: Icons.person_rounded,
                  color: AppColors.studentColor,
                  child: StreamBuilder<List<Student>>(
                    stream: _dbService.getStudents(status: 'active'),
                    builder: (context, snapshot) {
                      final students = snapshot.data ?? [];

                      return ModernDropdownField<String>(
                        label: 'Select Student',
                        value: _selectedStudentId,
                        prefixIcon: Icons.person_outline,
                        hint: 'Choose a student',
                        required: true,
                        items: students.map((student) {
                          return DropdownMenuItem(
                            value: student.studentId,
                            child: Text('${student.name} - ${student.email}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStudentId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a student';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSizes.paddingLarge),

                // Payment Period Section
                _buildSectionCard(
                  title: 'Payment Period',
                  icon: Icons.calendar_month_rounded,
                  color: AppColors.info,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ModernDropdownField<String>(
                              label: 'Month',
                              value: _selectedMonth,
                              prefixIcon: Icons.calendar_today,
                              required: true,
                              items: _months.map((month) {
                                return DropdownMenuItem(
                                  value: month,
                                  child: Text(month),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMonth = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: AppSizes.paddingMedium),
                          Expanded(
                            child: ModernDropdownField<int>(
                              label: 'Year',
                              value: _selectedYear,
                              required: true,
                              items: List.generate(5, (index) {
                                final year = DateTime.now().year - 1 + index;
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                );
                              }),
                              onChanged: (value) {
                                setState(() {
                                  _selectedYear = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      ModernCard(
                        color: AppColors.backgroundDark,
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        elevated: false,
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _dueDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                _dueDate = date;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.paddingSmall),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSizes.paddingSmall),
                                  decoration: BoxDecoration(
                                    color: AppColors.info.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                                  ),
                                  child: const Icon(
                                    Icons.event_rounded,
                                    color: AppColors.info,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppSizes.paddingMedium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Due Date',
                                        style: AppTextStyles.labelMedium.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textTertiary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.paddingLarge),

                // Fee Details Section
                _buildSectionCard(
                  title: 'Fee Details',
                  icon: Icons.attach_money_rounded,
                  color: AppColors.success,
                  child: Column(
                    children: [
                      ModernTextField(
                        controller: _hostelFeeController,
                        label: 'Hostel Fee',
                        hint: 'Enter hostel fee amount',
                        prefixIcon: Icons.home_rounded,
                        keyboardType: TextInputType.number,
                        required: true,
                        validator: (value) =>
                            Validators.validatePositiveNumber(value, 'Hostel fee'),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      ModernTextField(
                        controller: _messFeeController,
                        label: 'Mess Fee',
                        hint: 'Enter mess fee amount',
                        prefixIcon: Icons.restaurant_rounded,
                        keyboardType: TextInputType.number,
                        required: true,
                        validator: (value) =>
                            Validators.validatePositiveNumber(value, 'Mess fee'),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      ModernTextField(
                        controller: _otherChargesController,
                        label: 'Other Charges',
                        hint: 'Enter other charges (optional)',
                        prefixIcon: Icons.receipt_rounded,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      ModernCard(
                        color: AppColors.success.withValues(alpha: 0.05),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSizes.paddingSmall),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                              ),
                              child: const Icon(
                                Icons.calculate_rounded,
                                color: AppColors.success,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppSizes.paddingMedium),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Amount',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    AppCurrency.format(_totalAmount),
                                    style: AppTextStyles.headlineSmall.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.paddingLarge),

                // Remarks Section
                _buildSectionCard(
                  title: 'Additional Information',
                  icon: Icons.note_rounded,
                  color: AppColors.textSecondary,
                  child: ModernTextField(
                    controller: _remarksController,
                    label: 'Remarks',
                    hint: 'Add any additional notes (optional)',
                    prefixIcon: Icons.edit_note_rounded,
                    maxLines: 3,
                  ),
                ),

                const SizedBox(height: AppSizes.paddingXLarge),

                // Action Buttons
                Row(
                  children: [
                    if (!isMobile) ...[
                      Expanded(
                        child: ModernButton(
                          label: 'Cancel',
                          variant: ModernButtonVariant.outlined,
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          size: ModernButtonSize.large,
                        ),
                      ),
                      const SizedBox(width: AppSizes.paddingMedium),
                    ],
                    Expanded(
                      flex: isMobile ? 1 : 2,
                      child: ModernButton(
                        label: 'Create Payment',
                        icon: Icons.check_circle_rounded,
                        onPressed: _isLoading ? null : _savePayment,
                        color: AppColors.messManagerColor,
                        size: ModernButtonSize.large,
                        loading: _isLoading,
                        fullWidth: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.paddingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return ModernCard(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingSmall),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingLarge),
          child,
        ],
      ),
    );
  }
}
