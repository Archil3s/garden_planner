import 'package:flutter/material.dart';
import '../app/app_routes.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const AppShell({super.key, required this.child, required this.currentRoute});

  void _go(BuildContext context, String route) {
    if (route == currentRoute) return;

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Garden Planner")),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text("Dashboard"),
              onTap: () => _go(context, AppRoutes.dashboard),
            ),
            ListTile(
              title: const Text("Beds"),
              onTap: () => _go(context, AppRoutes.beds),
            ),
            ListTile(
              title: const Text("Inventory"),
              onTap: () => _go(context, AppRoutes.inventory),
            ),
            ListTile(
              title: const Text("Seedlings"),
              onTap: () => _go(context, AppRoutes.seedlings),
            ),
            ListTile(
              title: const Text("Reports"),
              onTap: () => _go(context, AppRoutes.reports),
            ),

            // IMPORTANT:
            // DO NOT ADD MAP HERE ANYMORE
          ],
        ),
      ),
      body: child,
    );
  }
}
