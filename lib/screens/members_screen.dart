import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/member.dart';
import '../providers/trip_provider.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _nameController = TextEditingController();
  String _filter = 'all';

  void _addMember() {
    if (_nameController.text.trim().isEmpty) return;
    
    final newMember = Member(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
    );
    
    Provider.of<TripProvider>(context, listen: false).addMember(newMember);
    _nameController.clear();
    Navigator.of(context).pop();
  }

  void _showAddMemberDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          title: const Text('Add Traveler'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            FilledButton(onPressed: _addMember, child: const Text('Add')),
          ],
        );
      }
    );
  }

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
            Text('MEMBERS', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddMemberDialog,
          ),
        ],
      ),
      body: Consumer<TripProvider>(
        builder: (context, provider, child) {
          
          Map<String, double> balances = {};
          for (var m in provider.members) balances[m.id] = 0.0;
          for (var ex in provider.expenses) {
            if (balances.containsKey(ex.payerId)) balances[ex.payerId] = balances[ex.payerId]! + ex.amount;
            double splitAmount = ex.amount / ex.splitMemberIds.length;
            for (var id in ex.splitMemberIds) {
              if (balances.containsKey(id)) balances[id] = balances[id]! - splitAmount;
            }
          }

          var filteredMembers = provider.members.where((m) {
            double bal = balances[m.id] ?? 0;
            bool settled = bal.abs() < 0.01;
            if (_filter == 'with-balance') return !settled;
            if (_filter == 'settled') return settled;
            return true;
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Trip Code:', style: Theme.of(context).textTheme.labelSmall),
                            const SizedBox(height: 4),
                            Text('TRIP-KYO-98', style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 2)),
                          ],
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: 'TRIP-KYO-98'));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip code copied to clipboard!')));
                          },
                          icon: const Icon(Icons.qr_code),
                          label: const Text('Invite'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all', provider.members.length),
                      const SizedBox(width: 8),
                      _buildFilterChip('With Balances', 'with-balance', provider.members.where((m) => (balances[m.id] ?? 0).abs() >= 0.01).length),
                      const SizedBox(width: 8),
                      _buildFilterChip('Settled', 'settled', provider.members.where((m) => (balances[m.id] ?? 0).abs() < 0.01).length),
                    ],
                  ),
                ),
              ),
              if (filteredMembers.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_off, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text('No travelers found', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final member = filteredMembers[index];
                      final bal = balances[member.id] ?? 0.0;
                      final isSettled = bal.abs() < 0.01;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                                ),
                                alignment: Alignment.center,
                                child: Text(member.name[0].toUpperCase(), style: Theme.of(context).textTheme.titleLarge),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(member.name, style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                                      ),
                                      child: Text('Member', style: Theme.of(context).textTheme.labelSmall),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    isSettled ? 'SETTLED UP' : (bal > 0 ? 'GETS BACK' : 'OWES GROUP'),
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: isSettled ? Theme.of(context).colorScheme.onSurfaceVariant : (bal > 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline)
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isSettled ? '\$0.00' : '${bal > 0 ? '+' : ''}\$${bal.abs().toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: isSettled ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.primary
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ).animate().fade().slideX(begin: 0.1);
                    },
                    childCount: filteredMembers.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter, int count) {
    final isSelected = _filter == filter;
    return InkWell(
      onTap: () => setState(() => _filter = filter),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
