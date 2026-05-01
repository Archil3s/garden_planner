import 'package:flutter/material.dart';
import 'app_routes.dart';

class GardenPlannerApp extends StatelessWidget {
  const GardenPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.projects,
      routes: AppRoutes.routes,
    );
  }
}
