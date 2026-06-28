import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/task/presentation/bloc/task_list/task_list_bloc.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/calendar/presentation/pages/timeline_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/task/presentation/pages/task_detail_page.dart';
import '../../features/task/presentation/pages/task_form_page.dart';
import '../../features/task/presentation/pages/task_list_page.dart';
import 'route_guards.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
@lazySingleton
class AppRouter extends RootStackRouter {
  final AuthGuard _authGuard;

  AppRouter(this._authGuard);

  @override
  List<AutoRoute> get routes => [
        // Splash & Auth
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: LoginRoute.page),

        // Main App (protected by auth guard)
        AutoRoute(
          page: HomeRoute.page,
          guards: [_authGuard],
          children: [
            AutoRoute(page: CalendarRoute.page, initial: true),
            AutoRoute(page: TimelineRoute.page),
            AutoRoute(page: TaskListRoute.page),
            AutoRoute(page: SettingsRoute.page),
          ],
        ),

        // Task routes (protected)
        AutoRoute(page: TaskDetailRoute.page, guards: [_authGuard]),
        AutoRoute(page: TaskFormRoute.page, guards: [_authGuard]),
      ];
}

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _tasksLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load tasks from Firestore when user navigates to home (only once)
    if (!_tasksLoaded) {
      _tasksLoaded = true;
      context.read<TaskListBloc>().add(const TaskListEvent.started());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        CalendarRoute(),
        TimelineRoute(),
        TaskListRoute(),
        SettingsRoute(),
      ],
      bottomNavigationBuilder: (context, tabsRouter) {
        return NavigationBar(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.view_timeline_outlined),
              selectedIcon: Icon(Icons.view_timeline),
              label: 'Timeline',
            ),
            NavigationDestination(
              icon: Icon(Icons.task_alt_outlined),
              selectedIcon: Icon(Icons.task_alt),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        );
      },
    );
  }
}
