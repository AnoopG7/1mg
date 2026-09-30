import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/reminder_provider.dart';
import '../cart/cart_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/orders_screen.dart';
import '../reminders/reminders_screen.dart';

/// Root navigation shell. Uses an [IndexedStack] so each tab keeps its
/// scroll position and state while switching.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  /// Lets any screen jump to a specific tab (e.g. "Order again" → cart).
  static void goToTab(BuildContext context, int index) {
    context.findAncestorStateOfType<_AppShellState>()?.select(index);
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void select(int i) {
    if (i == _index) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const OrdersScreen(),
      const RemindersScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: _BottomBar(
        index: _index,
        onSelect: select,
        cartCount: context.select<CartProvider, int>((c) => c.itemCount),
        // Badge the number of active reminders, not the number of daily dose
        // times: one reminder with two doses a day used to show a "2" badge.
        reminderCount: context.select<ReminderProvider, int>(
          (r) => r.totalActive,
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.index,
    required this.onSelect,
    required this.cartCount,
    required this.reminderCount,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final int cartCount;
  final int reminderCount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onSelect,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: reminderCount > 0,
              backgroundColor: AppColors.primary,
              label: Text('$reminderCount'),
              child: const Icon(Icons.alarm_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: reminderCount > 0,
              backgroundColor: AppColors.primary,
              label: Text('$reminderCount'),
              child: const Icon(Icons.alarm_rounded),
            ),
            label: 'Reminders',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              backgroundColor: AppColors.primary,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: cartCount > 0,
              backgroundColor: AppColors.primary,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart_rounded),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
