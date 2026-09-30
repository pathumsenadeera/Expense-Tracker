import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/expense.dart';

class ExpenseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('expenses');
  }

  Stream<List<Expense>> getExpensesStream(String userId) {
    return _collection(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Expense.fromMap(doc.data()))
            .toList());
  }

  Future<void> addExpense(Expense expense) async {
    await _collection(expense.userId)
        .doc(expense.id)
        .set(expense.toMap());
  }

  Future<void> updateExpense(Expense expense) async {
    await _collection(expense.userId)
        .doc(expense.id)
        .update(expense.toMap());
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    await _collection(userId).doc(expenseId).delete();
  }

  Future<List<Expense>> getExpensesByMonth(
      String userId, int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    final snap = await _collection(userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .get();
    return snap.docs.map((doc) => Expense.fromMap(doc.data())).toList();
  }

  Map<ExpenseCategory, double> groupByCategory(List<Expense> expenses) {
    final Map<ExpenseCategory, double> result = {};
    for (final e in expenses) {
      result[e.category] = (result[e.category] ?? 0) + e.amount;
    }
    return result;
  }

  Map<DateTime, double> groupByDay(List<Expense> expenses) {
    final Map<DateTime, double> result = {};
    for (final e in expenses) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      result[day] = (result[day] ?? 0) + e.amount;
    }
    return result;
  }
}
