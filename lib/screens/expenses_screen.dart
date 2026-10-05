import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/trip_provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Food', 'Transport', 'Lodging', 'Activities', 'Tickets'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Kyoto Adventure', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('USD \$', style: Theme.of(context).textTheme.labelSmall),
                ),
              ],
            ),
            Text('EXPENSES', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                final provider = Provider.of<TripProvider>(context, listen: false);
                if (provider.members.isEmpty) return;
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Select "You"'),
                        ),
                        ...provider.members.map((m) => ListTile(
                          title: Text(m.name),
                          trailing: provider.currentUserId == m.id || (provider.currentUserId == null && provider.members.first.id == m.id)
                              ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                          onTap: () {
                            provider.setCurrentUser(m.id);
                            Navigator.pop(ctx);
                          },
                        )),
                      ],
                    ),
                  ),
                );
              },
              child: const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=alex'),
              ),
            ),
          )
        ],
      ),
      body: Consumer<TripProvider>(
        builder: (context, provider, child) {
          final totalSpent = provider.expenses.fold(0.0, (sum, e) => sum + e.amount);
          
          double yourShare = 0.0;
          double yourNet = 0.0;
          final me = provider.currentUserId != null 
              ? provider.getMember(provider.currentUserId!) 
              : (provider.members.isNotEmpty ? provider.members.first : null);
          
          if (me != null) {
            for (var e in provider.expenses) {
              if (e.splitMemberIds.contains(me.id)) {
                if (e.exactSplitAmounts.isNotEmpty) {
                  yourShare += e.exactSplitAmounts[me.id] ?? 0.0;
                } else {
                  yourShare += e.amount / e.splitMemberIds.length;
                }
              }
              if (e.payerId == me.id) {
                yourNet += e.amount;
              }
            }
            yourNet -= yourShare;
          }

          var filteredExpenses = provider.expenses.where((e) {
            if (_searchQuery.isNotEmpty && !e.description.toLowerCase().contains(_searchQuery.toLowerCase())) {
              return false;
            }
            if (_selectedCategory != 'All' && e.category != _selectedCategory) {
              return false;
            }
            return true; 
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context, 
                          'Total', 
                          '\$${totalSpent.toStringAsFixed(2)}', 
                          '${provider.expenses.length} expenses',
                          Icons.pie_chart
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricCard(
                          context, 
                          'Your Share', 
                          '\$${yourShare.toStringAsFixed(2)}', 
                          '',
                          Icons.person
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).colorScheme.outline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.trending_up, size: 16, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 4),
                                  Text('NET', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('${yourNet >= 0 ? '+' : '-'}\$${yourNet.abs().toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search expenses...',
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (val) => setState(() => _selectedCategory = cat),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (filteredExpenses.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text('No expenses found', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final expense = filteredExpenses[index];
                      final payer = provider.getMember(expense.payerId);
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                                    ),
                                    child: Icon(_getCategoryIcon(expense.category), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(expense.description, style: Theme.of(context).textTheme.titleMedium),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(payer?.name ?? 'Unknown', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
                                            const SizedBox(width: 8),
                                            const Text('•'),
                                            const SizedBox(width: 8),
                                            Text('${expense.date.month}/${expense.date.day}', style: Theme.of(context).textTheme.bodySmall),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text('\$${expense.amount.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Split with ${expense.splitMemberIds.length} members', style: Theme.of(context).textTheme.labelSmall),
                                    Text('\$${(expense.amount / expense.splitMemberIds.length).toStringAsFixed(2)}/ea', style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fade(duration: 400.ms, delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
                    },
                    childCount: filteredExpenses.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food': return Icons.restaurant;
      case 'Transport': return Icons.directions_bus;
      case 'Transit': return Icons.directions_bus;
      case 'Lodging': return Icons.hotel;
      case 'Activities': return Icons.local_activity;
      case 'Tickets': return Icons.airplane_ticket;
      default: return Icons.receipt;
    }
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
          ]
        ],
      ),
    );
  }
}
