import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/utils/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final breakdown = provider.categoryBreakdown;
    final total = provider.totalFiltered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'By Category'),
            Tab(text: 'By Day'),
          ],
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryGreen,
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryTab(breakdown: breakdown, total: total),
          _DailyTab(provider: provider),
        ],
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final Map<ExpenseCategory, double> breakdown;
  final double total;

  const _CategoryTab({required this.breakdown, required this.total});

  static const List<Color> _colors = [
    Color(0xFF1A3C2B),
    Color(0xFFB5E550),
    Color(0xFF2E7D52),
    Color(0xFF6DBF7E),
    Color(0xFF94D468),
    Color(0xFF4A9463),
    Color(0xFFD4F0A0),
    Color(0xFF3B7A57),
    Color(0xFF8BC34A),
    Color(0xFF558B2F),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (breakdown.isEmpty) {
      return const Center(
          child: Text('No data for selected period',
              style: TextStyle(color: AppTheme.textSecondary)));
    }

    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Pie Chart
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: sorted.asMap().entries.map((e) {
                final pct = total > 0 ? e.value.value / total * 100 : 0;
                return PieChartSectionData(
                  value: e.value.value,
                  color: _colors[e.key % _colors.length],
                  title: '${pct.toStringAsFixed(0)}%',
                  radius: 80,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
              sectionsSpace: 3,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Legend
        ...sorted.asMap().entries.map((entry) {
          final idx = entry.key;
          final cat = entry.value.key;
          final amount = entry.value.value;
          final pct = total > 0 ? amount / total * 100 : 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                      )
                    ],
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _colors[idx % _colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(cat.emoji),
                const SizedBox(width: 8),
                Text(
                  cat.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs ${NumberFormat('#,##0.##').format(amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _DailyTab extends StatelessWidget {
  final ExpenseProvider provider;
  const _DailyTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expenses = provider.filteredExpenses;
    if (expenses.isEmpty) {
      return const Center(
          child: Text('No data for selected period',
              style: TextStyle(color: AppTheme.textSecondary)));
    }

    // Build daily data for last 14 days
    final now = DateTime.now();
    final days = List.generate(
        14, (i) => DateTime(now.year, now.month, now.day - (13 - i)));
    final dailyMap = <DateTime, double>{};
    for (final e in expenses) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      dailyMap[day] = (dailyMap[day] ?? 0) + e.amount;
    }
    final maxVal =
        dailyMap.values.isEmpty ? 1.0 : dailyMap.values.reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Last 14 Days',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxVal * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, _, rod, __) {
                    final day = days[group.x.toInt()];
                    return BarTooltipItem(
                      '${DateFormat('MMM d').format(day)}\nRs ${NumberFormat('#,##0').format(rod.toY)}',
                      const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, _) {
                      final day = days[val.toInt()];
                      if (val.toInt() % 2 != 0) return const SizedBox();
                      return Text(
                        DateFormat('d').format(day),
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.textSecondary),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: days.asMap().entries.map((e) {
                final amount = dailyMap[e.value] ?? 0;
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: amount,
                      color: amount > 0
                          ? AppTheme.primaryGreen
                          : (isDark
                              ? Colors.white12
                              : Colors.grey.shade200),
                      width: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Daily breakdown list
        ...days.reversed.where((d) => (dailyMap[d] ?? 0) > 0).map((day) {
          final amount = dailyMap[day]!;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Text(
                  DateFormat('EEE, MMM d').format(day),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Rs ${NumberFormat('#,##0.##').format(amount)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
