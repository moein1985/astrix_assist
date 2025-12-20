import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    if (isMobile) {
      return Scaffold(
        body: widget.child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavigation,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard),
              label: l10n.navDashboard,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.phone),
              label: l10n.navExtensions,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.call),
              label: l10n.navCalls,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.queue),
              label: l10n.navQueues,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.description),
              label: l10n.navReports,
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
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.dashboard),
                  label: Text(l10n.navDashboard),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.phone),
                  label: Text(l10n.navExtensions),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.call),
                  label: Text(l10n.navCalls),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.queue),
                  label: Text(l10n.navQueues),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.description),
                  label: Text(l10n.navReports),
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
                    l10n.appTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                NavigationDrawerDestination(
                  icon: const Icon(Icons.dashboard),
                  label: Text(l10n.navDashboard),
                ),
                NavigationDrawerDestination(
                  icon: const Icon(Icons.phone),
                  label: Text(l10n.navExtensions),
                ),
                NavigationDrawerDestination(
                  icon: const Icon(Icons.call),
                  label: Text(l10n.navCalls),
                ),
                NavigationDrawerDestination(
                  icon: const Icon(Icons.queue),
                  label: Text(l10n.navQueues),
                ),
                NavigationDrawerDestination(
                  icon: const Icon(Icons.description),
                  label: Text(l10n.navReports),
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
