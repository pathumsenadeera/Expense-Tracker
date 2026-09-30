import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/screens/expenses/add_edit_expense_screen.dart';
import 'package:expense_tracker/screens/expenses/all_expenses_screen.dart';
import 'package:expense_tracker/utils/app_theme.dart';
import 'package:expense_tracker/widgets/expense_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ExpenseProvider>();
    final user = FirebaseAuth.instance.currentUser;

    // Today's expenses
    final now = DateTime.now();
    final todayExpenses = provider.allExpenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .toList();
    final todayTotal = todayExpenses.fold(0.0, (s, e) => s + e.amount);
    final monthTotal = provider.totalForCurrentMonth;

    final firstName = user?.displayName?.split(' ').first ??
        user?.email?.split('@').first ??
        'User';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {},
          color: AppTheme.accentGreen,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, $firstName',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              DateFormat('EEEE, MMM d').format(now),
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkCard
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline,
                                size: 14,
                                color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'Personal',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white70
                                      : AppTheme.textSecondary),
                            ),
                            const Icon(Icons.keyboard_arrow_down,
                                size: 14,
                                color: AppTheme.textSecondary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Period Filter Tabs
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _PeriodTabBar(provider: provider),
                ),
              ),

              // Summary Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _SummaryCard(
                    filter: provider.filter,
                    todayTotal: todayTotal,
                    monthTotal: monthTotal,
                    total: provider.totalFiltered,
                    count: provider.filteredExpenses.length,
                  ),
                ),
              ),

              // Recent Expenses Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getLabel(provider.filter),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : AppTheme.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const AllExpensesScreen()),
                        ),
                        child: const Text(
                          'See all',
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Expense List
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primaryGreen)),
                )
              else if (provider.filteredExpenses.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 56,
                            color: isDark
                                ? Colors.white24
                                : Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'No expenses yet',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? Colors.white38
                                : Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap + to add your first expense',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white24
                                : Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, index) {
                        final grouped = provider.groupedByDate;
                        final dates =
                            grouped.keys.toList();
                        if (index >= dates.length) return null;
                        final date = dates[index];
                        final dayExpenses = grouped[date]!;
                        final isDayToday = date.day == now.day &&
                            date.month == now.month &&
                            date.year == now.year;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                isDayToday
                                    ? 'Today'
                                    : DateFormat('MMM d').format(date),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white60
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                            ...dayExpenses.map((e) => ExpenseListItem(
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
                      childCount: provider.groupedByDate.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLabel(ExpenseFilter filter) {
    switch (filter) {
      case ExpenseFilter.today:
        return 'Today';
      case ExpenseFilter.thisWeek:
        return 'This Week';
      case ExpenseFilter.thisMonth:
        return DateFormat('MMMM yyyy').format(DateTime.now());
      case ExpenseFilter.all:
        return 'All Expenses';
    }
  }
}

class _PeriodTabBar extends StatelessWidget {
  final ExpenseProvider provider;
  const _PeriodTabBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final options = [
      (ExpenseFilter.today, 'Today'),
      (ExpenseFilter.thisWeek, 'This Week'),
      (ExpenseFilter.thisMonth, 'This Month'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = provider.filter == opt.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => provider.setFilter(opt.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accentGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  opt.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : (isDark
                            ? Colors.white54
                            : AppTheme.textSecondary),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ExpenseFilter filter;
  final double todayTotal;
  final double monthTotal;
  final double total;
  final int count;

  const _SummaryCard({
    required this.filter,
    required this.todayTotal,
    required this.monthTotal,
    required this.total,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _cardTitle(filter),
                    style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        letterSpacing: 1),
                  ),
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Rs ${NumberFormat('#,##0.##').format(total)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.arrow_upward,
                    color: AppTheme.accentGreen,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$count transaction${count != 1 ? 's' : ''}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  if (filter != ExpenseFilter.thisMonth)
                    Text(
                      '| Month: Rs ${NumberFormat('#,##0').format(monthTotal)}',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _cardTitle(ExpenseFilter filter) {
    switch (filter) {
      case ExpenseFilter.today:
        return "TODAY'S EXPENSE";
      case ExpenseFilter.thisWeek:
        return "THIS WEEK'S EXPENSE";
      case ExpenseFilter.thisMonth:
        return "THIS MONTH'S EXPENSE";
      case ExpenseFilter.all:
        return 'TOTAL EXPENSE';
    }
  }
}
