import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'models/fsm_model.dart';
import 'services/fsm_service.dart';

class MapPage extends StatefulWidget {
  // Constructor without const to allow receiving arguments
  // ignore: prefer_const_constructors_in_immutables
  MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  FSM? _fsm;
  bool _isLoading = true;
  Offset? _currentPosition;
  bool _isMapReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    print('MapPage didChangeDependencies called with args: $args');
    print('Args type: ${args.runtimeType}');

    if (args is FSM) {
      // Valid FSM object passed directly
      print('Args is FSM object');
      setState(() {
        _fsm = args;
      });
      _initializeMap();
    } else if (args is String) {
      // FSM ID passed as string
      print('Args is String: $args');
      _loadFSMById(args);
    } else if (args is Map<String, dynamic>) {
      // FSM data passed as Map
      print('Args is Map: $args');
      try {
        setState(() {
          _fsm = FSM.fromJson(args);
        });
        print('Successfully created FSM from Map: ${_fsm?.locationName}');
        _initializeMap();
      } catch (e) {
        print('Error creating FSM from Map: $e');
        _handleError('Invalid FSM data format: $e');
      }
    } else {
      // No valid or no arguments provided; try graceful fallback
      print('Args is not valid: ${args?.runtimeType}');
      try {
        final fsmService = FSMService();
        fsmService.initializeWithMockData();
        final allFSMs = fsmService.getAllFSMs();
        if (allFSMs.isNotEmpty) {
          setState(() {
            _fsm = allFSMs.first;
          });
          print('Fallback to first available FSM: ${_fsm!.id}');
          _initializeMap();
        } else {
          _handleError('FSM data not provided');
        }
      } catch (e) {
        _handleError('FSM data not provided');
      }
    }
  }

  void _handleError(String message) {
    print('Map page error: $message');
    // Use SchedulerBinding to show snackbar after the current frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $message'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  Future<void> _loadFSMById(String id) async {
    print('Loading FSM by ID: $id');
    final fsmService = FSMService();

    // Explicitly initialize mock data
    fsmService.initializeWithMockData();

    final fsm = fsmService.getFSMById(id);
    print('FSM loaded from service: $fsm');

    if (fsm != null) {
      print('FSM found with ID $id: ${fsm.locationName}');
      setState(() {
        _fsm = fsm;
      });
      _initializeMap();
    } else {
      print('FSM with ID $id not found');

      // Try to get any FSM as a fallback
      final allFSMs = fsmService.getAllFSMs();
      if (allFSMs.isNotEmpty) {
        print('Using first available FSM as fallback');
        setState(() {
          _fsm = allFSMs.first;
        });
        _initializeMap();
      } else {
        _handleError('FSM with ID $id not found and no fallback available');
      }
    }
  }

  Future<void> _initializeMap() async {
    print('_initializeMap called, current FSM: ${_fsm?.id}');
    try {
      // Ensure FSM data is valid
      if (_fsm == null || _fsm!.id.isEmpty) {
        print('FSM is null or has empty ID, trying to get from service');
        // Try to get FSM from service if ID is available
        final fsmService = FSMService();
        fsmService.initializeWithMockData(); // Ensure mock data is initialized

        // If we still don't have a valid FSM, try to get the first one from the service
        if (_fsm == null) {
          print('FSM is still null, trying to get first available FSM');
          final allFSMs = fsmService.getAllFSMs();
          print('Found ${allFSMs.length} FSMs in service');
          if (allFSMs.isNotEmpty) {
            setState(() {
              _fsm = allFSMs.first;
            });
            print(
                'Using first available FSM: ${_fsm!.locationName}, ID: ${_fsm!.id}');
          } else {
            print('No FSMs available in service');
            throw Exception('No FSM data available');
          }
        }
      }

      // Validate FSM data
      if (_fsm == null) {
        throw Exception('FSM data not found or invalid');
      }

      print(
          'Initializing map with FSM: ${_fsm!.locationName}, ID: ${_fsm!.id}');

      // Simulate loading delay for demo purposes
      await Future.delayed(const Duration(milliseconds: 800));

      // Simulate getting current position (center of screen)
      _currentPosition = const Offset(200, 150);

      setState(() {
        _isLoading = false;
        _isMapReady = true;
      });
    } catch (e) {
      print('Error initializing map: $e');
      setState(() {
        _isLoading = false;
      });

      // Show error message
      _handleError(e.toString());
    }
  }

  Color _getSewageSizeColor(String size) {
    switch (size.toLowerCase()) {
      case 'big':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'small':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showDirections() {
    if (_fsm != null) {
      _showDirectionsDialog();
    }
  }

  void _showDirectionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.directions,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Get Directions'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('To navigate to ${_fsm!.locationName}:'),
              const SizedBox(height: 16),
              Text('📍 ${_fsm!.locationName}'),
              Text('🏛️ ${_fsm!.lgaName}'),
              Text('💧 Sewage Size: ${_fsm!.sewageSize}'),
              const SizedBox(height: 8),
              Text(
                'Coordinates: ${_fsm!.latitude.toStringAsFixed(6)}, ${_fsm!.longitude.toStringAsFixed(6)}',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This is a demo map. In production, this would open Google Maps with directions.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // If _fsm is null, show a loading screen instead of trying to access its properties
    if (_fsm == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Map'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Map - ${_fsm!.locationName}'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _isMapReady ? () => _animateToFSMLocation() : null,
            tooltip: 'Go to FSM Location',
          ),
          IconButton(
            icon: const Icon(Icons.directions),
            onPressed: _showDirections,
            tooltip: 'Get Directions',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showLocationInfo(),
            tooltip: 'Location Info',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading demo map...',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
            )
          : Column(
              children: [
                // Demo Map Container
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Demo Map Background
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                            child: CustomPaint(
                              painter: DemoMapPainter(),
                            ),
                          ),

                          // FSM Location Pin
                          Positioned(
                            left: MediaQuery.of(context).size.width * 0.5 - 20,
                            top: MediaQuery.of(context).size.height * 0.4 - 40,
                            child: Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color:
                                        _getSewageSizeColor(_fsm!.sewageSize),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _fsm!.locationName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Current Location Pin (if available)
                          if (_currentPosition != null)
                            Positioned(
                              left: _currentPosition!.dx - 15,
                              top: _currentPosition!.dy - 30,
                              child: Column(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.my_location,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.1),
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'You',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Coordinates Display
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Coordinates',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lat: ${_fsm!.latitude.toStringAsFixed(4)}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  Text(
                                    'Lng: ${_fsm!.longitude.toStringAsFixed(4)}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Demo Map Label
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'DEMO MAP',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Location Details Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: _getSewageSizeColor(_fsm!.sewageSize),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fsm!.locationName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  _fsm!.lgaName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getSewageSizeColor(_fsm!.sewageSize)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _fsm!.sewageSize,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _getSewageSizeColor(_fsm!.sewageSize),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Created: ${_fsm!.formattedDateTime}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.map,
                            size: 20,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Lagos, Nigeria',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (_currentPosition != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.my_location,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Your location available',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.outline),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This is a demo map for prototyping. Replace with real Google Maps integration when ready for production.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _animateToFSMLocation() {
    if (_fsm == null) return;
    // In a real map, this would animate the camera.
    // For this demo, we can show a snackbar.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Centering on ${_fsm!.locationName}...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showLocationInfo() {
    if (_fsm == null) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _fsm!.locationName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _fsm!.lgaName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(height: 32),
            Row(
              children: [
                const Icon(Icons.water_drop_outlined, size: 16),
                const SizedBox(width: 8),
                Text('Sewage Size: ${_fsm!.sewageSize}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.pin_drop_outlined, size: 16),
                const SizedBox(width: 8),
                Text(
                    'Lat: ${_fsm!.latitude.toStringAsFixed(6)}, Lng: ${_fsm!.longitude.toStringAsFixed(6)}'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for demo map
class DemoMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade200
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid lines
    for (int i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }
    for (int i = 0; i < size.height; i += 30) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }

    // Draw some mock roads
    final roadPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Horizontal road
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      roadPaint,
    );

    // Vertical road
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      roadPaint,
    );

    // Diagonal road
    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, size.height),
      roadPaint,
    );

    // Draw some mock buildings/landmarks
    final buildingPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;

    // Mock buildings
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.1, 40, 30),
      buildingPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.7, size.height * 0.6, 35, 25),
      buildingPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.7, 45, 35),
      buildingPaint,
    );

    // Draw some mock water bodies
    final waterPaint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      25,
      waterPaint,
    );

    // Draw some mock parks/green areas
    final parkPaint = Paint()
      ..color = Colors.green.shade300
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.5, 60, 40),
      parkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
