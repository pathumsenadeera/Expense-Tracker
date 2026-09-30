import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/services/expense_service.dart';
import 'package:flutter/material.dart';

enum ExpenseFilter { all, today, thisWeek, thisMonth }

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _service = ExpenseService();
  final AuthService _authService = AuthService();

  List<Expense> _allExpenses = [];
  bool _isLoading = false;
  String? _error;
  ExpenseFilter _filter = ExpenseFilter.thisMonth;
  ExpenseCategory? _categoryFilter;
  String _searchQuery = '';
  ThemeMode _themeMode = ThemeMode.light;

  List<Expense> get allExpenses => _allExpenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ExpenseFilter get filter => _filter;
  ExpenseCategory? get categoryFilter => _categoryFilter;
  String get searchQuery => _searchQuery;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Stream<List<Expense>>? _expenseStream;

  void startListening() {
    final uid = _authService.currentUserId;
    if (uid == null) return;
    _expenseStream = _service.getExpensesStream(uid);
    _expenseStream!.listen((expenses) {
      _allExpenses = expenses;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      notifyListeners();
    });
  }

  List<Expense> get filteredExpenses {
    List<Expense> result = List.from(_allExpenses);

    // Category filter
    if (_categoryFilter != null) {
      result = result.where((e) => e.category == _categoryFilter).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((e) =>
              e.title.toLowerCase().contains(q) ||
              (e.note?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    // Time filter
    final now = DateTime.now();
    switch (_filter) {
      case ExpenseFilter.today:
        result = result
            .where((e) =>
                e.date.year == now.year &&
                e.date.month == now.month &&
                e.date.day == now.day)
            .toList();
        break;
      case ExpenseFilter.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        result = result
            .where((e) => e.date
                .isAfter(weekStart.subtract(const Duration(seconds: 1))))
            .toList();
        break;
      case ExpenseFilter.thisMonth:
        result = result
            .where(
                (e) => e.date.year == now.year && e.date.month == now.month)
            .toList();
        break;
      case ExpenseFilter.all:
        break;
    }

    return result;
  }

  double get totalForCurrentMonth {
    final now = DateTime.now();
    return _allExpenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalForToday {
    final now = DateTime.now();
    return _allExpenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalFiltered =>
      filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);

  Map<ExpenseCategory, double> get categoryBreakdown {
    final map = <ExpenseCategory, double>{};
    for (final e in filteredExpenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  void setFilter(ExpenseFilter f) {
    _filter = f;
    notifyListeners();
  }

  void setCategoryFilter(ExpenseCategory? c) {
    _categoryFilter = c;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.addExpense(expense);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updateExpense(expense);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    try {
      await _service.deleteExpense(userId, expenseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  void reset() {
    _allExpenses = [];
    _error = null;
    _filter = ExpenseFilter.thisMonth;
    _categoryFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  // Group expenses by date for list display
  Map<DateTime, List<Expense>> get groupedByDate {
    final Map<DateTime, List<Expense>> map = {};
    for (final e in filteredExpenses) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      map.putIfAbsent(day, () => []).add(e);
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }
}
