import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/screens/analytics/analytics_screen.dart';
import 'package:expense_tracker/screens/expenses/add_edit_expense_screen.dart';
import 'package:expense_tracker/screens/expenses/all_expenses_screen.dart';
import 'package:expense_tracker/screens/home/home_screen.dart';
import 'package:expense_tracker/screens/settings/settings_screen.dart';
import 'package:expense_tracker/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AllExpensesScreen(),
    SizedBox(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppTheme.darkCard : Colors.white;
    final inactiveColor =
        isDark ? const Color(0xFF555570) : const Color(0xFFBBBBBB);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,
        children: _screens,
      ),

      // ── Gradient FAB ─────────────────────────────────────────────
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.cardGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPurple.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddEditExpenseScreen()),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── Bottom navigation ─────────────────────────────────────────
      bottomNavigationBar: BottomAppBar(
        color: navBg,
        elevation: 0,
        notchMargin: 10,
        shape: const CircularNotchedRectangle(),
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: navBg,
            border: Border(
              top: BorderSide(
                color: isDark ? AppTheme.darkBorder : Colors.grey.shade100,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                isActive: _currentIndex == 0,
                inactiveColor: inactiveColor,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavItem(
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart_rounded,
                label: 'Stats',
                isActive: _currentIndex == 3,
                inactiveColor: inactiveColor,
                onTap: () => setState(() => _currentIndex = 3),
              ),
              const SizedBox(width: 50),
              _NavItem(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                label: 'Expenses',
                isActive: _currentIndex == 1,
                inactiveColor: inactiveColor,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                isActive: _currentIndex == 4,
                inactiveColor: inactiveColor,
                onTap: () => setState(() => _currentIndex = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: isActive ? AppTheme.cardGradient : null,
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? Colors.white : inactiveColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppTheme.primaryPurple : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
