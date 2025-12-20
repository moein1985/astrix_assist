import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'responsive_helper.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainShell({super.key, required this.child, required this.currentIndex});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _currentIndex = widget.currentIndex;
    }
  }

  void _onNavigation(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/extensions');
        break;
      case 2:
        context.go('/calls');
        break;
      case 3:
        context.go('/queues');
        break;
      case 4:
        context.go('/cdr');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    if (isMobile) {
      return Scaffold(
        body: widget.child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavigation,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'داشبورد',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'داخلی‌ها'),
            BottomNavigationBarItem(icon: Icon(Icons.call), label: 'تماس‌ها'),
            BottomNavigationBarItem(icon: Icon(Icons.queue), label: 'صف‌ها'),
            BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: 'گزارشات',
            ),
          ],
        ),
      );
    } else if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onNavigation,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('داشبورد'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.phone),
                  label: Text('داخلی‌ها'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.call),
                  label: Text('تماس‌ها'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.queue),
                  label: Text('صف‌ها'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.description),
                  label: Text('گزارشات'),
                ),
              ],
            ),
            Expanded(child: widget.child),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Row(
          children: [
            NavigationDrawer(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onNavigation,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Astrix Assist',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('داشبورد'),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.phone),
                  label: Text('داخلی‌ها'),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.call),
                  label: Text('تماس‌ها'),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.queue),
                  label: Text('صف‌ها'),
                ),
                const NavigationDrawerDestination(
                  icon: Icon(Icons.description),
                  label: Text('گزارشات'),
                ),
              ],
            ),
            Expanded(child: widget.child),
          ],
        ),
      );
    }
  }
}
