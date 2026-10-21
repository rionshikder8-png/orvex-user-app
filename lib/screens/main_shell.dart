import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../widgets/app_icons.dart';
import 'home/home_screen.dart';
import 'inbox/inbox_screen.dart';
import 'orders/orders_screen.dart';
import 'products/products_screen.dart';
import 'account/settings_screen.dart';

/// Bottom navigation with the five primary destinations. Each tab keeps its own
/// state via an IndexedStack.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onOpenTab: (i) => setState(() => _index = i)),
          const InboxScreen(),
          const OrdersScreen(),
          const ProductsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(AppIcons.home),
            selectedIcon: const Icon(AppIcons.homeFilled),
            label: context.t('nav_home'),
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.inbox),
            selectedIcon: const Icon(AppIcons.inboxFilled),
            label: context.t('nav_inbox'),
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.orders),
            selectedIcon: const Icon(AppIcons.ordersFilled),
            label: context.t('nav_orders'),
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.products),
            selectedIcon: const Icon(AppIcons.productsFilled),
            label: context.t('nav_products'),
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.settings),
            selectedIcon: const Icon(AppIcons.settingsFilled),
            label: context.t('nav_settings'),
          ),
        ],
      ),
    );
  }
}
