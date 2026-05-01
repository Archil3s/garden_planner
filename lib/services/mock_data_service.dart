import '../models/bed.dart';
import '../models/garden_project.dart';

class MockDataService {
  List<GardenProject> getProjects() {
    return [
      GardenProject(
        id: '1',
        name: 'My Garden',
        beds: [
          Bed(
            id: '101',
            name: 'Tomatoes',
            x: 40,
            y: 40,
            width: 140,
            height: 80,
            cropCount: 3,
          ),
          Bed(
            id: '102',
            name: 'Lettuce',
            x: 220,
            y: 40,
            width: 140,
            height: 80,
            cropCount: 5,
          ),
        ],
      ),
    ];
  }
}
