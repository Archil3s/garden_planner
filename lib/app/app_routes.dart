import 'package:flutter/material.dart';

import '../screens/dashboard_screen.dart';
import '../screens/beds_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/seedlings_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/project_list_screen.dart';
import '../widgets/app_shell.dart';

class AppRoutes {
  static const dashboard = '/';
  static const beds = '/beds';
  static const inventory = '/inventory';
  static const seedlings = '/seedlings';
  static const reports = '/reports';
  static const projects = '/projects';

  static Map<String, WidgetBuilder> routes = {
    dashboard: (_) =>
        const AppShell(currentRoute: dashboard, child: DashboardScreen()),

    beds: (_) => const AppShell(currentRoute: beds, child: BedsScreen()),

    inventory: (_) =>
        const AppShell(currentRoute: inventory, child: InventoryScreen()),

    seedlings: (_) =>
        const AppShell(currentRoute: seedlings, child: SeedlingsScreen()),

    reports: (_) =>
        const AppShell(currentRoute: reports, child: ReportsScreen()),

    projects: (_) => const ProjectListScreen(),
  };
}
