import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseListItem({super.key, required this.expense, this.onTap});

  static Color _iconBg(ExpenseCategory cat) {
    switch (cat) {
      case ExpenseCategory.food:
        return AppTheme.catFood;
      case ExpenseCategory.transport:
        return AppTheme.catTransport;
      case ExpenseCategory.shopping:
        return AppTheme.catShopping;
      case ExpenseCategory.bills:
        return AppTheme.catBills;
      case ExpenseCategory.health:
        return AppTheme.catHealth;
      case ExpenseCategory.entertainment:
        return AppTheme.catEntertain;
      case ExpenseCategory.education:
        return AppTheme.catEducation;
      case ExpenseCategory.travel:
        return AppTheme.catTravel;
      case ExpenseCategory.subscription:
        return AppTheme.catOther;
      case ExpenseCategory.other:
        return AppTheme.catOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.darkCard : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor =
        isDark ? const Color(0xFF8888AA) : const Color(0xFF999999);
    final bg = _iconBg(expense.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : Colors.grey.shade100,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Coloured circular icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bg.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(expense.category.emoji,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 13),

            // Title & subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          expense.category.label,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (expense.note != null && expense.note!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            expense.note!,
                            style: TextStyle(fontSize: 11, color: subColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Amount + date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '- Rs ${NumberFormat('#,##0.##').format(expense.amount)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.expenseRed,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('d MMM').format(expense.date),
                  style: TextStyle(fontSize: 11, color: subColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
