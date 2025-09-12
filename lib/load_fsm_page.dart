import 'package:flutter/material.dart';
import 'models/fsm_model.dart';
import 'services/fsm_service.dart';

class LoadFSMPage extends StatefulWidget {
  const LoadFSMPage({super.key});

  @override
  State<LoadFSMPage> createState() => _LoadFSMPageState();
}

class _LoadFSMPageState extends State<LoadFSMPage> {
  final TextEditingController _searchController = TextEditingController();
  List<FSM> _allFSMs = [];
  List<FSM> _filteredFSMs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFSMs();
    _searchController.addListener(_filterFSMs);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to this page (e.g., after creating a new FSM)
    _loadFSMs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFSMs() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Load FSMs from the shared service
    final fsmService = FSMService();
    setState(() {
      _allFSMs = fsmService.getAllFSMs();
      _filteredFSMs = List.from(_allFSMs);
      _isLoading = false;
    });
  }

  void _filterFSMs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFSMs = List.from(_allFSMs);
      } else {
        _filteredFSMs = _allFSMs.where((fsm) {
          return fsm.locationName.toLowerCase().contains(query) ||
              fsm.lgaName.toLowerCase().contains(query) ||
              fsm.sewageSize.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _openMap(FSM fsm) {
    // Ensure FSM has valid data before navigating
    if (fsm.id.isEmpty) {
      print('Error: FSM ID is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Invalid FSM data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    print('Opening map with FSM ID: ${fsm.id}');
    
    // Pass only the FSM ID instead of the whole object
    Navigator.of(context).pushNamed('/map', arguments: fsm.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load FSM'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search FSMs by location, LGA, or size...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // FSM List
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading FSMs...',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                      ],
                    ),
                  )
                : _filteredFSMs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No FSMs found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search terms',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredFSMs.length,
                        itemBuilder: (context, index) {
                          final fsm = _filteredFSMs[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () => _openMap(fsm),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Location Icon
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color:
                                            _getSewageSizeColor(fsm.sewageSize)
                                                .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.location_on,
                                        color:
                                            _getSewageSizeColor(fsm.sewageSize),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // FSM Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fsm.locationName,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            fsm.lgaName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getSewageSizeColor(
                                                          fsm.sewageSize)
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  fsm.sewageSize,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: _getSewageSizeColor(
                                                        fsm.sewageSize),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Created: ${fsm.formattedDateTime}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Map Icon
                                    Icon(
                                      Icons.map,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
