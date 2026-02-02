import 'package:flutter/material.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/documents/screens/documents_screen.dart';
import '../features/members/screens/members_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import '../core/providers/document_provider.dart';
import '../core/providers/task_provider.dart';
import '../core/responsive/breakpoints.dart';
import '../core/services/token_storage.dart';
import 'package:flutter/foundation.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToDocumentsWithFilter(String memberId) {
    // Set the member filter
    context.read<DocumentProvider>().setMemberFilter(memberId);

    // Navigate to documents tab
    setState(() {
      _currentIndex = 1; // Documents tab index
    });
    _pageController.jumpToPage(1);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final pages = const [
      DashboardScreen(),
      DocumentsScreen(),
      // Members needs callback
      null,
      ProfileScreen(),
    ];

    // Build page widgets array with the callback-injected member screen
    final children = [
      pages[0]!,
      pages[1]!,
      MembersScreen(onMemberTap: _navigateToDocumentsWithFilter),
      pages[3]!,
    ];

    if (isDesktop) {
      // Desktop/tablet: Use NavigationRail and side-by-side content
      return SafeArea(
        child: Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  _onTabTapped(index);
                },
                labelType: NavigationRailLabelType.selected,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.folder_outlined),
                    selectedIcon: Icon(Icons.folder),
                    label: Text('Documents'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.people_outline),
                    selectedIcon: Icon(Icons.people),
                    label: Text('Members'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: Text('Profile'),
                  ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  children: children,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mobile: keep BottomNavigationBar with badges
    return SafeArea(
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: children,
        ),
        bottomNavigationBar: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            final dueTasksCount = taskProvider.dueTasks.length;

            return BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              items: [
                BottomNavigationBarItem(
                  icon: dueTasksCount > 0
                      ? Badge(
                          label: Text('$dueTasksCount'),
                          child: const Icon(Icons.dashboard_outlined),
                        )
                      : const Icon(Icons.dashboard_outlined),
                  activeIcon: dueTasksCount > 0
                      ? Badge(
                          label: Text('$dueTasksCount'),
                          child: const Icon(Icons.dashboard),
                        )
                      : const Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.folder_outlined),
                  activeIcon: Icon(Icons.folder),
                  label: 'Documents',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Members',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            );
          },
        ),
        // Debug: show current stored userId/token when in debug mode
        floatingActionButton: kDebugMode
            ? FloatingActionButton.small(
                onPressed: () async {
                  final userId = await TokenStorage.getUserId();
                  final token = await TokenStorage.getToken();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'userId: ${userId ?? 'null'}\n' +
                            'token: ${token != null ? token.substring(0, 20) + "..." : 'null'}',
                      ),
                      duration: const Duration(seconds: 6),
                    ),
                  );
                },
                tooltip: 'Show auth debug info',
                child: const Icon(Icons.bug_report_outlined),
              )
            : null,
      ),
    );
  }
}
