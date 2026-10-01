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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ExpenseProvider>();
    final breakdown = provider.categoryBreakdown;
    final total = provider.totalFiltered;
    final bgColor = isDark ? AppTheme.darkBg : AppTheme.lightBg;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text('Statistics',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Monthly'),
            Tab(text: 'Yearly'),
          ],
          labelColor: AppTheme.accentGreen,
          unselectedLabelColor: const Color(0xFF888888),
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          indicatorColor: AppTheme.accentGreen,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryTab(breakdown: breakdown, total: total, isDark: isDark),
          _DailyTab(provider: provider, isDark: isDark),
        ],
      ),
    );
  }
}

// ── Category breakdown tab ─────────────────────────────────────────────────
class _CategoryTab extends StatelessWidget {
  final Map<ExpenseCategory, double> breakdown;
  final double total;
  final bool isDark;

  const _CategoryTab(
      {required this.breakdown, required this.total, required this.isDark});

  static const List<Color> _colors = [
    Color(0xFFB5E550),
    Color(0xFFFF4D4D),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
    Color(0xFFFF5722),
    Color(0xFF607D8B),
  ];

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppTheme.darkCard : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor =
        isDark ? const Color(0xFF888888) : const Color(0xFF999999);

    if (breakdown.isEmpty) {
      return Center(
          child: Text('No data for selected period',
              style: TextStyle(color: subColor)));
    }

    final sorted = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // ── Bar chart (green/red style) ────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Spending by Category',
                  style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: sorted.asMap().entries.map((e) {
                      final pct =
                          total > 0 ? e.value.value / total * 100 : 0;
                      return PieChartSectionData(
                        value: e.value.value,
                        color: _colors[e.key % _colors.length],
                        title: '${pct.toStringAsFixed(0)}%',
                        radius: 72,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 4,
                    centerSpaceRadius: 44,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Legend / breakdown rows ────────────────────────────────
        ...sorted.asMap().entries.map((entry) {
          final idx = entry.key;
          final cat = entry.value.key;
          final amount = entry.value.value;
          final pct = total > 0 ? amount / total * 100 : 0;
          final barFrac = total > 0 ? amount / total : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _colors[idx % _colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(cat.emoji,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(cat.label,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            fontSize: 14)),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$ ${NumberFormat('#,##0.##').format(amount)}',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              fontSize: 14),
                        ),
                        Text(
                          '${pct.toStringAsFixed(1)}%',
                          style: TextStyle(
                              fontSize: 11, color: subColor),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: barFrac.toDouble(),
                    minHeight: 4,
                    backgroundColor:
                        _colors[idx % _colors.length].withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _colors[idx % _colors.length]),
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

// ── Daily bar chart tab ─────────────────────────────────────────────────────
class _DailyTab extends StatelessWidget {
  final ExpenseProvider provider;
  final bool isDark;
  const _DailyTab({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final expenses = provider.filteredExpenses;
    final cardColor = isDark ? AppTheme.darkCard : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor =
        isDark ? const Color(0xFF888888) : const Color(0xFF999999);

    if (expenses.isEmpty) {
      return Center(
          child: Text('No data for selected period',
              style: TextStyle(color: subColor)));
    }

    final now = DateTime.now();
    final days = List.generate(
        14, (i) => DateTime(now.year, now.month, now.day - (13 - i)));
    final dailyMap = <DateTime, double>{};
    for (final e in expenses) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      dailyMap[day] = (dailyMap[day] ?? 0) + e.amount;
    }
    final maxVal = dailyMap.values.isEmpty
        ? 1.0
        : dailyMap.values.reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // ── Bar chart ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last 14 Days',
                  style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxVal * 1.25,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, _, rod, _) {
                          final day = days[group.x.toInt()];
                          return BarTooltipItem(
                            '${DateFormat('MMM d').format(day)}\n\$${NumberFormat('#,##0').format(rod.toY)}',
                            const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, _) {
                            final day = days[val.toInt()];
                            if (val.toInt() % 2 != 0) {
                              return const SizedBox();
                            }
                            return Text(
                              DateFormat('d').format(day),
                              style: TextStyle(
                                  fontSize: 10, color: subColor),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: isDark
                            ? const Color(0xFF2A2A2A)
                            : Colors.grey.shade100,
                        strokeWidth: 1,
                      ),
                    ),
                    barGroups: days.asMap().entries.map((e) {
                      final amount = dailyMap[e.value] ?? 0;
                      final hasData = amount > 0;
                      return BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: amount,
                            gradient: hasData
                                ? const LinearGradient(
                                    colors: [
                                      AppTheme.accentGreen,
                                      Color(0xFF4CAF50),
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  )
                                : null,
                            color: hasData
                                ? null
                                : (isDark
                                    ? const Color(0xFF2A2A2A)
                                    : Colors.grey.shade100),
                            width: 14,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Daily breakdown rows ───────────────────────────────────
        ...days.reversed
            .where((d) => (dailyMap[d] ?? 0) > 0)
            .map((day) {
          final amount = dailyMap[day]!;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  DateFormat('EEE, MMM d').format(day),
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: textColor),
                ),
                const Spacer(),
                Text(
                  '- \$ ${NumberFormat('#,##0.##').format(amount)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.expenseRed),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
