import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScanFlowNavigationBar extends StatelessWidget {
  const ScanFlowNavigationBar({
    required this.currentIndex,
    this.onDestinationSelected,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int>? onDestinationSelected;

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: currentIndex,
    onDestinationSelected:
        onDestinationSelected ??
        (index) => context.go(switch (index) {
          1 => '/scan',
          2 => '/history',
          _ => '/',
        }),
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.document_scanner_outlined),
        selectedIcon: Icon(Icons.document_scanner_rounded),
        label: 'Scan',
      ),
      NavigationDestination(
        icon: Icon(Icons.history_rounded),
        label: 'History',
      ),
    ],
  );
}
