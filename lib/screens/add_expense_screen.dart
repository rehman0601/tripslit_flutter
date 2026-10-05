import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../providers/trip_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedPayerId;
  Set<String> _selectedSplitMembers = {};
  String _selectedCategory = 'Food';
  String _splitMethod = 'Equally';

  final Map<String, TextEditingController> _customSplitControllers = {};

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TripProvider>(context, listen: false);
    if (provider.members.isNotEmpty) {
      _selectedPayerId = provider.members.first.id;
      _selectedSplitMembers = provider.members.map((m) => m.id).toSet();
      for (var m in provider.members) {
        _customSplitControllers[m.id] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (var c in _customSplitControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveExpense() {
    if (_amountController.text.trim().isEmpty) return;
    double totalAmount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (totalAmount <= 0) return;
    if (_selectedSplitMembers.isEmpty) return;

    Map<String, double> exactSplits = {};
    if (_splitMethod == 'Unequal') {
      double sum = 0;
      for (var id in _selectedSplitMembers) {
        double amt = double.tryParse(_customSplitControllers[id]?.text ?? '0') ?? 0;
        exactSplits[id] = amt;
        sum += amt;
      }
      if ((sum - totalAmount).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unequal splits must add up exactly to the total amount.')));
        return;
      }
    } else if (_splitMethod == 'Shares') {
      double totalShares = 0;
      for (var id in _selectedSplitMembers) {
        totalShares += double.tryParse(_customSplitControllers[id]?.text ?? '1') ?? 1;
      }
      if (totalShares <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Total shares must be greater than 0.')));
        return;
      }
      for (var id in _selectedSplitMembers) {
        double shares = double.tryParse(_customSplitControllers[id]?.text ?? '1') ?? 1;
        exactSplits[id] = totalAmount * (shares / totalShares);
      }
    }
    
    final expense = Expense(
      id: const Uuid().v4(),
      description: _descController.text.trim().isEmpty ? _selectedCategory : _descController.text.trim(),
      amount: totalAmount,
      payerId: _selectedPayerId!,
      splitMemberIds: _selectedSplitMembers.toList(),
      date: DateTime.now(),
      category: _selectedCategory,
      exactSplitAmounts: exactSplits,
    );

    Provider.of<TripProvider>(context, listen: false).addExpense(expense);
    Navigator.pop(context);
  }

  void _addAmount(double add) {
    double current = double.tryParse(_amountController.text) ?? 0;
    _amountController.text = (current + add).toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final members = Provider.of<TripProvider>(context).members;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('NEW EXPENSE', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('\$', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.secondary)),
                      ),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          style: Theme.of(context).textTheme.displayLarge,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            hintText: '0.00',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildQuickAddBtn(10),
                    const SizedBox(width: 8),
                    _buildQuickAddBtn(50),
                    const SizedBox(width: 8),
                    _buildQuickAddBtn(100),
                  ],
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'What was this for?',
                    prefixIcon: Icon(Icons.edit),
                  ),
                ),
                const SizedBox(height: 24),
                Text('CATEGORY', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Transit', 'Food', 'Lodging', 'Activities'].map((c) {
                    final isSel = _selectedCategory == c;
                    return ChoiceChip(
                      label: Text(c),
                      selected: isSel,
                      onSelected: (val) => setState(() => _selectedCategory = c),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                Text('WHO PAID?', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: members.map((m) {
                      final isSel = _selectedPayerId == m.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPayerId = m.id),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: isSel ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                                child: Text(m.name[0].toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                              ),
                              if (isSel) ...[
                                const SizedBox(width: 8),
                                Text(m.name, style: Theme.of(context).textTheme.labelSmall),
                                const SizedBox(width: 8),
                              ]
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
                Text('SPLIT METHOD', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildSplitMethodBtn('Equally', Icons.pie_chart)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSplitMethodBtn('Unequal', Icons.bar_chart)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSplitMethodBtn('Shares', Icons.share)),
                  ],
                ),
                const SizedBox(height: 32),
                Text('SPLIT WITH', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                ...members.map((m) {
                  return CheckboxListTile(
                    title: Text(m.name),
                    subtitle: (_splitMethod != 'Equally' && _selectedSplitMembers.contains(m.id))
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextField(
                              controller: _customSplitControllers[m.id],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: _splitMethod == 'Unequal' ? 'Amount (\$)' : 'Shares (e.g. 1 or 2)',
                                isDense: true,
                              ),
                            ),
                          )
                        : null,
                    value: _selectedSplitMembers.contains(m.id),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedSplitMembers.add(m.id);
                        } else {
                          _selectedSplitMembers.remove(m.id);
                        }
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
            ),
            child: SafeArea(
              child: FilledButton(
                onPressed: _saveExpense,
                style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                child: const Text('Save & Split Expense'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddBtn(int amount) {
    return InkWell(
      onTap: () => _addAmount(amount.toDouble()),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Text('+\$$amount', style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }

  Widget _buildSplitMethodBtn(String method, IconData icon) {
    final isSel = _splitMethod == method;
    return InkWell(
      onTap: () => setState(() => _splitMethod = method),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSel ? Theme.of(context).colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSel ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: isSel ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 8),
            Text(method, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isSel ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary)),
          ],
        ),
      ),
    );
  }
}
