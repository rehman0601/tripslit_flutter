import 'package:flutter/material.dart';
import 'expenses_screen.dart';
import 'members_screen.dart';
import 'settlements_screen.dart';
import 'home_screen.dart';
import 'add_expense_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExpensesScreen(),
    const MembersScreen(),
    const SettlementsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          // Desktop/Tablet Layout
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) => setState(() => _currentIndex = index),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Home')),
                    NavigationRailDestination(icon: Icon(Icons.receipt_long), label: Text('Expenses')),
                    NavigationRailDestination(icon: Icon(Icons.people), label: Text('Members')),
                    NavigationRailDestination(icon: Icon(Icons.account_balance_wallet), label: Text('Settlement')),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: _screens[_currentIndex],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: const [
              ExpensesScreen(),
              MembersScreen(),
              SettlementsScreen(),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _buildNavItem(0, Icons.receipt_long, 'EXPENSES')),
                  Expanded(child: _buildNavItem(1, Icons.group, 'MEMBERS')),
                  Expanded(
                    child: Center(
                      child: Transform.translate(
                        offset: const Offset(0, -16),
                        child: FloatingActionButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
                          },
                          elevation: 4,
                          shape: const CircleBorder(),
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.add, size: 32, color: Color(0xFF0B1326)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: _buildNavItem(2, Icons.handshake, 'SETTLEMENT')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant;
    
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
