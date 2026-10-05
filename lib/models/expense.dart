class Expense {
  final String id;
  final String description;
  final double amount;
  final String payerId;
  final List<String> splitMemberIds;
  final DateTime date;
  final String category;
  final Map<String, double> exactSplitAmounts;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.payerId,
    required this.splitMemberIds,
    required this.date,
    this.category = 'Other',
    this.exactSplitAmounts = const {},
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'description': description,
    'amount': amount,
    'payerId': payerId,
    'splitMemberIds': splitMemberIds,
    'date': date.toIso8601String(),
    'category': category,
    'exactSplitAmounts': exactSplitAmounts,
  };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
    id: map['id'],
    description: map['description'],
    amount: map['amount'],
    payerId: map['payerId'],
    splitMemberIds: List<String>.from(map['splitMemberIds']),
    date: DateTime.parse(map['date']),
    category: map['category'] ?? 'Other',
    exactSplitAmounts: map['exactSplitAmounts'] != null 
        ? Map<String, double>.from(map['exactSplitAmounts']) 
        : const {},
  );
}
