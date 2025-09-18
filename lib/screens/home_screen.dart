import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'focus_timer_screen.dart';
import 'insights_screen.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final List<Widget> _pages = const <Widget>[
    DashboardScreen(),
    TasksScreen(),
    FocusTimerScreen(),
    InsightsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Flow'),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(
          key: ValueKey<int>(_index),
          child: _pages[_index],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int newIndex) {
          setState(() {
            _index = newIndex;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_rtl),
            selectedIcon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.hourglass_empty),
            selectedIcon: Icon(Icons.hourglass_full),
            label: 'Focus',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.surface,
    );
  }
}
