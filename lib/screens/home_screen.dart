import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/trip_provider.dart';
import 'add_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Consumer<TripProvider>(
        builder: (context, provider, child) {
          final totalExpenses = provider.expenses.fold(0.0, (sum, item) => sum + item.amount);
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Theme.of(context).colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Trip Expenses',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${totalExpenses.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Members',
                      provider.members.length.toString(),
                      Icons.people,
                      1,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Expenses',
                      provider.expenses.length.toString(),
                      Icons.receipt_long,
                      2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  if (provider.members.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please add members first.')),
                    );
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpenseScreen()));
                },
                icon: const Icon(Icons.add),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Quick Add Expense', style: TextStyle(fontSize: 16)),
                ),
              ).animate().fade(duration: 400.ms, delay: 200.ms).scale(duration: 400.ms),
              if (provider.expenses.isNotEmpty) ...[
                const SizedBox(height: 32),
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate().fade(duration: 400.ms, delay: 300.ms),
                const SizedBox(height: 16),
                ...provider.expenses.reversed.take(3).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final expense = entry.value;
                  final payer = provider.getMember(expense.payerId);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(Icons.receipt, color: Theme.of(context).colorScheme.onPrimaryContainer),
                      ),
                      title: Text(expense.description, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('Paid by ${payer?.name ?? "Unknown"}'),
                      trailing: Text(
                        '\$${expense.amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ).animate().fade(duration: 400.ms, delay: (400 + index * 100).ms).slideX(begin: 0.1, end: 0, duration: 400.ms);
                }),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    ).animate().fade(duration: 400.ms, delay: (index * 100).ms).slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
}
