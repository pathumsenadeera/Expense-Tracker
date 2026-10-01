import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/screens/expenses/add_edit_expense_screen.dart';
import 'package:expense_tracker/utils/app_theme.dart';
import 'package:expense_tracker/widgets/expense_list_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AllExpensesScreen extends StatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ExpenseProvider>();
    final grouped = provider.groupedByDate;
    final total = provider.totalFiltered;

    final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final cardColor = isDark ? AppTheme.darkCard : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor =
        isDark ? const Color(0xFF888888) : const Color(0xFF999999);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text('Search',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Summary strip ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : Colors.grey.shade100,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TOTAL SPENT',
                            style: TextStyle(
                                color: subColor,
                                fontSize: 11,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          '\$ ${NumberFormat('#,##0.00').format(total)}',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${provider.filteredExpenses.length} transaction${provider.filteredExpenses.length != 1 ? 's' : ''}',
                          style:
                              TextStyle(color: subColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _FilterChip(provider: provider),
                ],
              ),
            ),
          ),

          // ── Search bar ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : Colors.grey.shade200,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: provider.setSearchQuery,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Search expenses...',
                  hintStyle: TextStyle(color: subColor),
                  prefixIcon: Icon(Icons.search, color: subColor, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: subColor, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            provider.setSearchQuery('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  filled: false,
                ),
              ),
            ),
          ),

          // ── Category filter chips ────────────────────────────────
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CatChip(
                  label: 'All',
                  isSelected: provider.categoryFilter == null,
                  onTap: () => provider.setCategoryFilter(null),
                  isDark: isDark,
                ),
                ...ExpenseCategory.values.map((cat) => _CatChip(
                      label: cat.label,
                      emoji: cat.emoji,
                      isSelected: provider.categoryFilter == cat,
                      onTap: () => provider.setCategoryFilter(
                          provider.categoryFilter == cat ? null : cat),
                      isDark: isDark,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Transactions list ────────────────────────────────────
          Expanded(
            child: grouped.isEmpty
                ? _EmptyState(subColor: subColor)
                : ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: grouped.length,
                    itemBuilder: (ctx, index) {
                      final date = grouped.keys.elementAt(index);
                      final expenses = grouped[date]!;
                      final dayTotal =
                          expenses.fold(0.0, (s, e) => s + e.amount);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Text(
                                  DateFormat('EEE, MMM d, yyyy')
                                      .format(date),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: subColor,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '- \$ ${NumberFormat('#,##0.##').format(dayTotal)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.expenseRed,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...expenses.map((e) => ExpenseListItem(
                                expense: e,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AddEditExpenseScreen(expense: e),
                                  ),
                                ),
                              )),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final ExpenseProvider provider;
  const _FilterChip({required this.provider});

  @override
  Widget build(BuildContext context) {
    final labels = {
      ExpenseFilter.today: 'Today',
      ExpenseFilter.thisWeek: 'This Week',
      ExpenseFilter.thisMonth: DateFormat('MMM yyyy').format(DateTime.now()),
      ExpenseFilter.all: 'All Time',
    };
    return PopupMenuButton<ExpenseFilter>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: provider.setFilter,
      itemBuilder: (_) => ExpenseFilter.values
          .map((f) => PopupMenuItem(
                value: f,
                child: Text(labels[f]!),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.accentGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(labels[provider.filter]!,
                style: const TextStyle(
                    color: AppTheme.accentGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                color: AppTheme.accentGreen, size: 16),
          ],
        ),
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _CatChip({
    required this.label,
    this.emoji,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentGreen
              : (isDark ? AppTheme.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentGreen
                : (isDark ? AppTheme.darkBorder : Colors.grey.shade200),
          ),
        ),
        child: Text(
          emoji != null ? '$emoji $label' : label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF1A1A1A)
                : (isDark
                    ? const Color(0xFF888888)
                    : const Color(0xFF666666)),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Color subColor;
  const _EmptyState({required this.subColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: subColor),
          const SizedBox(height: 16),
          Text('No expenses found',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: subColor)),
        ],
      ),
    );
  }
}
