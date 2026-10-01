import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late ExpenseCategory _selectedCategory;
  late DateTime _selectedDate;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.expense != null;
    if (_isEditing) {
      final e = widget.expense!;
      _titleController.text = e.title;
      _amountController.text = e.amount.toStringAsFixed(2);
      _noteController.text = e.note ?? '';
      _selectedCategory = e.category;
      _selectedDate = e.date;
    } else {
      _selectedCategory = ExpenseCategory.food;
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryPurple,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = AuthService().currentUserId;
    if (uid == null) return;

    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a valid amount'),
        backgroundColor: AppTheme.expenseRed,
      ));
      return;
    }

    final provider = context.read<ExpenseProvider>();

    if (_isEditing) {
      final updated = widget.expense!.copyWith(
        title: _titleController.text.trim(),
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      await provider.updateExpense(updated);
    } else {
      final expense = Expense(
        userId: uid,
        title: _titleController.text.trim(),
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      await provider.addExpense(expense);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ExpenseProvider>();
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final cardColor = isDark ? AppTheme.darkCard : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor =
        isDark ? const Color(0xFF8888AA) : const Color(0xFF999999);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text(
          _isEditing ? 'Edit Expense' : 'Add Expense',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppTheme.expenseRed),
              onPressed: _confirmDelete,
            ),
        ],
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          children: [
            // ── Amount hero card ───────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Rs ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: const InputDecoration(
                            hintText: '0.00',
                            hintStyle:
                                TextStyle(color: Colors.white38, fontSize: 38),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Enter amount';
                            final n = double.tryParse(v);
                            if (n == null || n <= 0) return 'Invalid amount';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Category Selector ──────────────────────────────────
            _SectionLabel(label: 'Category', isDark: isDark),
            const SizedBox(height: 10),
            SizedBox(
              height: 94,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ExpenseCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.cardGradient : null,
                        color: isSelected
                            ? null
                            : (isDark ? AppTheme.darkCard : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (isDark
                                  ? AppTheme.darkBorder
                                  : Colors.grey.shade200),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat.emoji,
                              style: const TextStyle(fontSize: 26)),
                          const SizedBox(height: 6),
                          Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? const Color(0xFF8888AA)
                                      : const Color(0xFF666666)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // ── Title ──────────────────────────────────────────────
            _SectionLabel(label: 'Title', isDark: isDark),
            const SizedBox(height: 10),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'e.g. Grocery shopping',
                hintStyle: TextStyle(color: subColor),
                prefixIcon: Icon(Icons.title, color: subColor),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Please enter a title';
                if (v.trim().length < 2) return 'Title too short';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Date ───────────────────────────────────────────────
            _SectionLabel(label: 'Date', isDark: isDark),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppTheme.darkBorder
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: AppTheme.primaryPurple, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                      style: TextStyle(fontSize: 15, color: textColor),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right,
                        color: isDark
                            ? const Color(0xFF8888AA)
                            : const Color(0xFFBBBBBB)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Note ───────────────────────────────────────────────
            _SectionLabel(label: 'Note (optional)', isDark: isDark),
            const SizedBox(height: 10),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Add any extra details...',
                hintStyle: TextStyle(color: subColor),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.notes_outlined, color: subColor),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Save button ────────────────────────────────────────
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: provider.isLoading ? null : _save,
                  child: Center(
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _isEditing ? 'Save Changes' : 'Add Expense',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Expense'),
        content: const Text(
            'Are you sure you want to delete this expense? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.expenseRed)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final uid = AuthService().currentUserId!;
      await context
          .read<ExpenseProvider>()
          .deleteExpense(uid, widget.expense!.id);
      if (mounted) Navigator.pop(context);
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? const Color(0xFF8888AA) : AppTheme.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}
