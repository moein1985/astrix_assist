import 'package:go_router/go_router.dart';
import '../presentation/pages/login_page.dart';
import '../presentation/pages/extensions_page.dart';
import '../presentation/pages/active_calls_page.dart';
import '../presentation/pages/queues_page.dart';
import '../presentation/pages/extension_detail_page.dart';
import '../presentation/pages/dashboard_page.dart';
import '../presentation/pages/settings_page.dart';
import '../presentation/pages/cdr_page.dart';
import '../presentation/pages/agent_detail_page.dart';
import '../presentation/pages/trunks_page.dart';
import '../presentation/pages/parking_page.dart';
import '../presentation/pages/ami_listen_example.dart';
import '../presentation/pages/spy_phone_page.dart';
import '../domain/entities/extension.dart';
import '../presentation/pages/originate_page.dart';
import '../presentation/widgets/main_shell.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginPage()),
    ShellRoute(
      builder: (context, state, child) {
        // Determine current index based on location
        int currentIndex = 0;
        final location = state.uri.path;
        if (location.startsWith('/dashboard')) {
          currentIndex = 0;
        } else if (location.startsWith('/extensions') ||
            location.startsWith('/extension')) {
          currentIndex = 1;
        } else if (location.startsWith('/calls') ||
            location.startsWith('/originate')) {
          currentIndex = 2;
        } else if (location.startsWith('/queues') ||
            location.startsWith('/agent') ||
            location.startsWith('/trunks') ||
            location.startsWith('/parking')) {
          currentIndex = 3;
        } else if (location.startsWith('/settings') ||
            location.startsWith('/cdr')) {
          currentIndex = 4;
        }
        return MainShell(currentIndex: currentIndex, child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/extensions',
          builder: (context, state) => const ExtensionsPage(),
        ),
        GoRoute(
          path: '/extension',
          builder: (context, state) =>
              ExtensionDetailPage(extensionInfo: state.extra as Extension),
        ),
        GoRoute(
          path: '/calls',
          builder: (context, state) => const ActiveCallsPage(),
        ),
        GoRoute(
          path: '/originate',
          builder: (context, state) => const OriginatePage(),
        ),
        GoRoute(
          path: '/queues',
          builder: (context, state) => const QueuesPage(),
        ),
        GoRoute(
          path: '/agent/:interface',
          builder: (context, state) {
            final interface = state.pathParameters['interface']!;
            final name = state.uri.queryParameters['name'] ?? interface;
            return AgentDetailPage(agentInterface: interface, agentName: name);
          },
        ),
        GoRoute(
          path: '/trunks',
          builder: (context, state) => const TrunksPage(),
        ),
        GoRoute(
          path: '/parking',
          builder: (context, state) => const ParkingPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(path: '/cdr', builder: (context, state) => const CdrPage()),
        GoRoute(
          path: '/ami-listen',
          builder: (context, state) => const AmiListenExample(),
        ),
        GoRoute(
          path: '/spy-phone',
          builder: (context, state) => const SpyPhonePage(),
        ),
      ],
    ),
  ],
);
