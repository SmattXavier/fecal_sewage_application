import 'dart:math';
import '../models/fsm_model.dart';

class FSMService {
  static final FSMService _instance = FSMService._internal();
  factory FSMService() => _instance;
  FSMService._internal();

  List<FSM> _fsms = [];
  int _nextId = 1;

  // Initialize with mock data
  void initializeWithMockData() {
    if (_fsms.isEmpty) {
      _fsms = [
        FSM(
          id: '1',
          locationName: 'Central Market',
          lgaName: 'Victoria Island',
          sewageSize: 'Big',
          createdAt: DateTime.now()
              .subtract(const Duration(days: 2, hours: 3, minutes: 15)),
          latitude: 6.4281,
          longitude: 3.4219,
        ),
        FSM(
          id: '2',
          locationName: 'Lekki Phase 1',
          lgaName: 'Eti-Osa',
          sewageSize: 'Medium',
          createdAt: DateTime.now()
              .subtract(const Duration(days: 5, hours: 7, minutes: 42)),
          latitude: 6.4654,
          longitude: 3.5650,
        ),
        FSM(
          id: '3',
          locationName: 'Ikeja Shopping Mall',
          lgaName: 'Ikeja',
          sewageSize: 'Small',
          createdAt: DateTime.now()
              .subtract(const Duration(days: 1, hours: 2, minutes: 30)),
          latitude: 6.6018,
          longitude: 3.3515,
        ),
        FSM(
          id: '4',
          locationName: 'Surulere Market',
          lgaName: 'Surulere',
          sewageSize: 'Big',
          createdAt: DateTime.now()
              .subtract(const Duration(days: 3, hours: 11, minutes: 8)),
          latitude: 6.5000,
          longitude: 3.3500,
        ),
        FSM(
          id: '5',
          locationName: 'Yaba Tech Hub',
          lgaName: 'Yaba',
          sewageSize: 'Medium',
          createdAt: DateTime.now()
              .subtract(const Duration(days: 7, hours: 5, minutes: 55)),
          latitude: 6.5090,
          longitude: 3.3780,
        ),
        FSM(
          id: '6',
          locationName: 'Apapa Port',
          lgaName: 'Apapa',
          sewageSize: 'Big',
          createdAt: DateTime.now()
              .subtract(const Duration(days: 4, hours: 9, minutes: 20)),
          latitude: 6.4500,
          longitude: 3.3800,
        ),
        FSM(
          id: '7',
          locationName: 'Mushin Market',
          lgaName: 'Mushin',
          sewageSize: 'Small',
          createdAt: DateTime.now()
              .subtract(const Duration(days: 6, hours: 14, minutes: 35)),
          latitude: 6.5200,
          longitude: 3.3400,
        ),
        FSM(
          id: '8',
          locationName: 'Alaba International',
          lgaName: 'Ojo',
          sewageSize: 'Medium',
          createdAt: DateTime.now()
              .subtract(const Duration(days: 8, hours: 12, minutes: 10)),
          latitude: 6.4800,
          longitude: 3.3000,
        ),
      ];
      _nextId = 9; // Set next ID to continue from mock data
    }
  }

  // Get all FSMs
  List<FSM> getAllFSMs() {
    initializeWithMockData();
    return List.from(_fsms);
  }

  // Add a new FSM
  FSM addFSM({
    required String locationName,
    required String lgaName,
    required String sewageSize,
  }) {
    initializeWithMockData();

    // Generate random coordinates within Lagos area
    final random = Random();
    final latitude = 6.4 + (random.nextDouble() * 0.3); // Lagos latitude range
    final longitude =
        3.3 + (random.nextDouble() * 0.3); // Lagos longitude range

    final newFSM = FSM(
      id: _nextId.toString(),
      locationName: locationName,
      lgaName: lgaName,
      sewageSize: sewageSize,
      createdAt: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
    );

    _fsms.add(newFSM);
    _nextId++;

    return newFSM;
  }

  // Get FSM by ID
  FSM? getFSMById(String id) {
    initializeWithMockData();
    try {
      return _fsms.firstWhere((fsm) => fsm.id == id);
    } catch (e) {
      print('Error finding FSM with ID $id: $e');
      return null;
    }
  }
  
  // Get FSM by location name
  FSM? getFSMByLocationName(String locationName) {
    initializeWithMockData();
    try {
      return _fsms.firstWhere((fsm) => fsm.locationName == locationName);
    } catch (e) {
      print('Error finding FSM with location name $locationName: $e');
      return null;
    }
  }

  // Search FSMs
  List<FSM> searchFSMs(String query) {
    initializeWithMockData();
    if (query.isEmpty) {
      return List.from(_fsms);
    }

    final lowercaseQuery = query.toLowerCase();
    return _fsms.where((fsm) {
      return fsm.locationName.toLowerCase().contains(lowercaseQuery) ||
          fsm.lgaName.toLowerCase().contains(lowercaseQuery) ||
          fsm.sewageSize.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Get FSMs by sewage size
  List<FSM> getFSMsBySize(String size) {
    initializeWithMockData();
    return _fsms
        .where((fsm) => fsm.sewageSize.toLowerCase() == size.toLowerCase())
        .toList();
  }

  // Get statistics
  Map<String, int> getStatistics() {
    initializeWithMockData();
    return {
      'total': _fsms.length,
      'big': _fsms.where((f) => f.sewageSize == 'Big').length,
      'medium': _fsms.where((f) => f.sewageSize == 'Medium').length,
      'small': _fsms.where((f) => f.sewageSize == 'Small').length,
    };
  }

  // Clear all FSMs (for testing purposes)
  void clearAllFSMs() {
    _fsms.clear();
    _nextId = 1;
  }
}

