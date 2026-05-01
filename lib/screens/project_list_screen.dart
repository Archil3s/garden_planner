import 'package:flutter/material.dart';
import '../models/garden_project.dart';
import 'map_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  List<GardenProject> projects = [];

  void _create() {
    setState(() {
      projects.add(
        GardenProject(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: "Garden ${projects.length + 1}",
          beds: [],
        ),
      );
    });
  }

  void _open(GardenProject project) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GardenMapScreen(project: project)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Gardens")),
      body: ListView(
        children: [
          for (final p in projects)
            ListTile(title: Text(p.name), onTap: () => _open(p)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _create,
        child: const Icon(Icons.add),
      ),
    );
  }
}
