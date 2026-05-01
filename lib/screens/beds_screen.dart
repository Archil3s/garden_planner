import 'package:flutter/material.dart';

import '../services/mock_data_service.dart';

class BedsScreen extends StatelessWidget {
  const BedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final beds = MockDataService().getBeds();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Beds',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Garden beds and crop counts.'),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: beds.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final bed = beds[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.grass_outlined),
                  title: Text(bed.name),
                  subtitle: Text('Crops: ${bed.cropCount}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
