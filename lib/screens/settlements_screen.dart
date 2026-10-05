import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/trip_provider.dart';

class SettlementsScreen extends StatelessWidget {
  const SettlementsScreen({super.key});

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
            Text('SETTLEMENT', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
      body: Consumer<TripProvider>(
        builder: (context, provider, child) {
          final settlements = provider.getSettlements();
          final unsettledPool = settlements.fold(0.0, (sum, s) => sum + s.amount);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('NET UNSETTLED POOL', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        Text(
                          '\$${unsettledPool.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${settlements.length} Transfers Pending', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text('RESOLVED TRANSFERS', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                              ),
                              child: Text('List', style: Theme.of(context).textTheme.labelSmall),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Text('Graph', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              if (settlements.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text('All settled up!', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final settlement = settlements[index];
                      final payer = provider.getMember(settlement.payerId);
                      final payee = provider.getMember(settlement.payeeId);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                                ),
                                alignment: Alignment.center,
                                child: Text(payer?.name.substring(0, 1).toUpperCase() ?? '?', style: Theme.of(context).textTheme.titleMedium),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        children: [
                                          TextSpan(text: '${payer?.name ?? 'Unknown'} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: 'pays ', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                          TextSpan(text: payee?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Due in 3 days', style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${settlement.amount.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                      ).animate().fade().slideY(begin: 0.1);
                    },
                    childCount: settlements.length,
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.code, size: 16, color: Theme.of(context).colorScheme.secondary),
                            const SizedBox(width: 8),
                            Text('Dart Algorithm Architecture', style: Theme.of(context).textTheme.labelSmall),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Utilizing a greedy O(N) two-pointer approach, this engine minimized ${provider.expenses.length} raw transactions into ${settlements.length} optimal transfers.', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)), // Space for bottom buttons
            ],
          );
        },
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminders sent to all pending debtors!')));
                  },
                  child: const Text('Remind All'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Provider.of<TripProvider>(context, listen: false).clearAllExpenses();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All debts settled!')));
                  },
                  child: const Text('Mark All Settled'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
