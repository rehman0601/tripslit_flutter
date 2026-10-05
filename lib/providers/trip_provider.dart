import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member.dart';
import '../models/expense.dart';
import '../models/settlement.dart';

class TripProvider with ChangeNotifier {
  List<Member> _members = [];
  List<Expense> _expenses = [];
  String? _currentUserId;

  List<Member> get members => _members;
  List<Expense> get expenses => _expenses;
  String? get currentUserId => _currentUserId;

  TripProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final membersJson = prefs.getStringList('members') ?? [];
    _members = membersJson.map((e) => Member.fromMap(jsonDecode(e))).toList();
    
    final expensesJson = prefs.getStringList('expenses') ?? [];
    _expenses = expensesJson.map((e) => Expense.fromMap(jsonDecode(e))).toList();
    
    _currentUserId = prefs.getString('currentUserId');
    
    if (_members.isEmpty && _expenses.isEmpty) {
      _seedData();
    } else {
      notifyListeners();
    }
  }

  void _seedData() {
    final m1 = Member(id: 'm1', name: 'Alice');
    final m2 = Member(id: 'm2', name: 'Bob');
    final m3 = Member(id: 'm3', name: 'Charlie');
    final m4 = Member(id: 'm4', name: 'Diana');
    _members = [m1, m2, m3, m4];

    _expenses = [
      Expense(
        id: 'e1',
        description: 'Airbnb',
        amount: 800.0,
        payerId: 'm1',
        splitMemberIds: ['m1', 'm2', 'm3', 'm4'],
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Expense(
        id: 'e2',
        description: 'Dinner at Mario\'s',
        amount: 120.0,
        payerId: 'm2',
        splitMemberIds: ['m1', 'm2', 'm3'],
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Expense(
        id: 'e3',
        description: 'Taxi',
        amount: 45.0,
        payerId: 'm3',
        splitMemberIds: ['m1', 'm3', 'm4'],
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Expense(
        id: 'e4',
        description: 'Museum Tickets',
        amount: 60.0,
        payerId: 'm4',
        splitMemberIds: ['m1', 'm2', 'm3', 'm4'],
        date: DateTime.now(),
      ),
    ];
    _saveData();
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final membersJson = _members.map((e) => jsonEncode(e.toMap())).toList();
    final expensesJson = _expenses.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('members', membersJson);
    await prefs.setStringList('expenses', expensesJson);
  }

  void addMember(Member member) {
    _members.add(member);
    _saveData();
    notifyListeners();
  }

  void removeMember(String id) {
    _members.removeWhere((m) => m.id == id);
    _saveData();
    notifyListeners();
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    _saveData();
    notifyListeners();
  }

  void clearAllExpenses() {
    _expenses.clear();
    _saveData();
    notifyListeners();
  }

  void setCurrentUser(String id) async {
    _currentUserId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUserId', id);
    notifyListeners();
  }

  Member? getMember(String id) {
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Settlement> getSettlements() {
    Map<String, double> balances = {};
    for (var m in _members) {
      balances[m.id] = 0.0;
    }

    for (var ex in _expenses) {
      if (balances.containsKey(ex.payerId)) {
        balances[ex.payerId] = balances[ex.payerId]! + ex.amount;
      }
      
      if (ex.exactSplitAmounts.isNotEmpty) {
        for (var id in ex.splitMemberIds) {
          if (balances.containsKey(id)) {
            balances[id] = balances[id]! - (ex.exactSplitAmounts[id] ?? 0.0);
          }
        }
      } else {
        double splitAmount = ex.amount / ex.splitMemberIds.length;
        for (var id in ex.splitMemberIds) {
          if (balances.containsKey(id)) {
            balances[id] = balances[id]! - splitAmount;
          }
        }
      }
    }

    List<MapEntry<String, double>> debtors = balances.entries.where((e) => e.value < -0.01).toList();
    List<MapEntry<String, double>> creditors = balances.entries.where((e) => e.value > 0.01).toList();

    debtors.sort((a, b) => a.value.compareTo(b.value)); // most negative first
    creditors.sort((a, b) => b.value.compareTo(a.value)); // most positive first

    List<Settlement> settlements = [];
    int i = 0;
    int j = 0;

    while (i < debtors.length && j < creditors.length) {
      double debt = -debtors[i].value;
      double credit = creditors[j].value;

      double settled = debt < credit ? debt : credit;
      
      if (settled > 0.01) {
        settlements.add(Settlement(payerId: debtors[i].key, payeeId: creditors[j].key, amount: settled));
      }

      debtors[i] = MapEntry(debtors[i].key, debtors[i].value + settled);
      creditors[j] = MapEntry(creditors[j].key, creditors[j].value - settled);

      if (-debtors[i].value < 0.01) i++;
      if (creditors[j].value < 0.01) j++;
    }

    return settlements;
  }
}
