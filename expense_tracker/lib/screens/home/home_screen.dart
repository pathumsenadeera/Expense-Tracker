import 'dart:ui';

import 'package:expense_tracker/models/expense.dart';
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
    final now = DateTime.now();

    final monthTotal = provider.totalForCurrentMonth;
    final todayTotal = provider.totalForToday;

    final firstName =
        user?.displayName?.split(' ').first ??
        user?.email?.split('@').first ??
        'User';

    final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor = isDark ? const Color(0xFF8888AA) : const Color(0xFF999999);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // ── Hero balance card with gradient ───────────────────────
          SliverToBoxAdapter(
            child: _HeroBalanceCard(
              firstName: firstName,
              monthTotal: monthTotal,
              todayTotal: todayTotal,
              onSearchTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllExpensesScreen()),
              ),
            ),
          ),

          // ── Period filter tabs ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _PeriodTabBar(provider: provider, isDark: isDark),
            ),
          ),

          // ── Quick stats row ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _QuickStats(provider: provider, isDark: isDark),
            ),
          ),

          // ── Section header ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllExpensesScreen(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.cardGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expense list ───────────────────────────────────────────
          if (provider.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryPurple),
              ),
            )
          else if (provider.filteredExpenses.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryPurple.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 40,
                        color: AppTheme.primaryPurple.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No expenses yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add your first expense',
                      style: TextStyle(fontSize: 13, color: subColor),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((ctx, index) {
                  final grouped = provider.groupedByDate;
                  final dates = grouped.keys.toList();
                  if (index >= dates.length) return null;
                  final date = dates[index];
                  final dayExpenses = grouped[date]!;
                  final isDayToday =
                      date.day == now.day &&
                      date.month == now.month &&
                      date.year == now.year;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          isDayToday
                              ? 'Today'
                              : DateFormat('EEE, MMM d').format(date),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: subColor,
                          ),
                        ),
                      ),
                      ...dayExpenses.map(
                        (e) => ExpenseListItem(
                          expense: e,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditExpenseScreen(expense: e),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }, childCount: provider.groupedByDate.length),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Hero gradient balance card ──────────────────────────────────────────────
class _HeroBalanceCard extends StatelessWidget {
  final String firstName;
  final double monthTotal;
  final double todayTotal;
  final VoidCallback onSearchTap;

  const _HeroBalanceCard({
    required this.firstName,
    required this.monthTotal,
    required this.todayTotal,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hey, $firstName! 👋',
                          style: const TextStyle(
                            color: Color(0xFFBFDBFE),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Track your expenses',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onSearchTap,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Glass balance card
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'This Month\'s Spending',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.more_horiz,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Rs ${NumberFormat('#,##0.00').format(monthTotal)}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _GlassStat(
                              icon: Icons.arrow_downward_rounded,
                              iconColor: AppTheme.incomeGreen,
                              label: 'Income',
                              value: 0.0,
                            ),
                            const SizedBox(width: 24),
                            _GlassStat(
                              icon: Icons.arrow_upward_rounded,
                              iconColor: AppTheme.expenseRed,
                              label: 'Expense',
                              value: monthTotal,
                            ),
                            const SizedBox(width: 24),
                            _GlassStat(
                              icon: Icons.today_rounded,
                              iconColor: const Color(0xFFBFDBFE),
                              label: 'Today',
                              value: todayTotal,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final double value;

  const _GlassStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
                Text(
                  'Rs.${NumberFormat('#,##0').format(value)}',
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Stats ─────────────────────────────────────────────────────────────
class _QuickStats extends StatelessWidget {
  final ExpenseProvider provider;
  final bool isDark;
  const _QuickStats({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppTheme.darkCard : Colors.white;
    final breakdown = provider.categoryBreakdown;
    final topCat = breakdown.entries.isEmpty
        ? null
        : (breakdown.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .first;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Transactions',
            value: provider.filteredExpenses.length.toString(),
            icon: Icons.receipt_long_rounded,
            iconColor: AppTheme.primaryPurple,
            cardColor: cardColor,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Top Category',
            value: topCat == null
                ? 'None'
                : '${topCat.key.emoji} ${topCat.key.label}',
            icon: Icons.category_rounded,
            iconColor: AppTheme.catShopping,
            cardColor: cardColor,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color cardColor;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.cardColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor = isDark ? const Color(0xFF8888AA) : const Color(0xFF999999);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 11, color: subColor)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Period tab bar ──────────────────────────────────────────────────────────
class _PeriodTabBar extends StatelessWidget {
  final ExpenseProvider provider;
  final bool isDark;
  const _PeriodTabBar({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final options = [
      (ExpenseFilter.today, 'Today'),
      (ExpenseFilter.thisWeek, 'Weekly'),
      (ExpenseFilter.thisMonth, 'Monthly'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = provider.filter == opt.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => provider.setFilter(opt.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.cardGradient : null,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  opt.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? const Color(0xFF8888AA)
                              : const Color(0xFF999999)),
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
