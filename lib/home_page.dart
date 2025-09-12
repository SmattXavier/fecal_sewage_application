import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme_provider.dart';
import 'services/fsm_service.dart';
import 'models/fsm_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final String _userRole = 'user';
  final String _userName = 'User';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<FSM> _recentFSMs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();

    _loadRecentFSMs();
  }

  Future<void> _loadRecentFSMs() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Load FSMs from the shared service
    final fsmService = FSMService();
    setState(() {
      _recentFSMs =
          fsmService.getAllFSMs().take(3).toList(); // Get only 3 most recent
      _isLoading = false;
    });
  }

  void _openMap(FSM fsm) {
    // Ensure FSM has valid data before navigating
    if (fsm.id.isEmpty) {
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
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define theme-aware colors for feature cards
    List<Color> cardColors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.primaryContainer,
      Theme.of(context).colorScheme.secondaryContainer,
      Theme.of(context).colorScheme.error,
      Theme.of(context).colorScheme.errorContainer,
    ];

    // Animation for staggered card appearance
    final staggerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prototype FSM'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Navigate back to onboarding
              Navigator.of(context).pushReplacementNamed('/onboarding');
            },
            tooltip: 'Show Onboarding',
          ),
        ],
      ),
      drawer: _AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _userRole == 'admin'
                      ? Icons.admin_panel_settings
                      : Icons.person,
                  color: _userRole == 'admin'
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $_userName!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Role: ${_userRole == 'admin' ? 'Administrator' : 'Regular User'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _userRole == 'admin'
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'This is a prototype of how the app will work and function.',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Recent FSMs Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent W Sites',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/all_fsms');
                      },
                      child: Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _recentFSMs.isEmpty
                          ? Center(
                              child: Text(
                                'No recent W sites found',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _recentFSMs.length,
                              itemBuilder: (context, index) {
                                final fsm = _recentFSMs[index];
                                // Staggered animation for each FSM card
                                final cardAnimation =
                                    Tween<double>(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: _fadeController,
                                    curve: Interval(
                                      0.4 + (index * 0.1),
                                      0.8 + (index * 0.1),
                                      curve: Curves.easeOutBack,
                                    ),
                                  ),
                                );
                                return AnimatedBuilder(
                                  animation: cardAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: cardAnimation.value,
                                      child: Transform.translate(
                                        offset: Offset(
                                            0, 20 * (1 - cardAnimation.value)),
                                        child: Card(
                                          margin:
                                              const EdgeInsets.only(right: 12),
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: InkWell(
                                            onTap: () => _openMap(fsm),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Container(
                                              width: 200,
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.location_on,
                                                        color:
                                                            _getSewageSizeColor(
                                                                fsm.sewageSize),
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          fsm.locationName,
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    fsm.lgaName,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const Spacer(),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: _getSewageSizeColor(
                                                                  fsm
                                                                      .sewageSize)
                                                              .withValues(
                                                                  alpha: 0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                        child: Text(
                                                          fsm.sewageSize,
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: _getSewageSizeColor(
                                                                fsm.sewageSize),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        'View Map',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Feature cards
            Expanded(
              child: AnimatedBuilder(
                animation: staggerAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: staggerAnimation.value,
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: _buildFeatureCards(cardColors),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatureCards(List<Color> cardColors) {
    int colorIndex = 0;
    List<Widget> cards = [
      _buildFeatureCard(
        context,
        'Create W Site',
        Icons.add_circle_outline,
        cardColors[colorIndex++],
        () {
          // Navigate to FSM creation page
          Navigator.of(context).pushNamed('/create_fsm');
        },
      ),
      _buildFeatureCard(
        context,
        'Load W Site',
        Icons.folder_open,
        cardColors[colorIndex++],
        () {
          // Navigate to FSM loading page
          Navigator.of(context).pushNamed('/load_fsm');
        },
      ),
      _buildFeatureCard(
        context,
        'View All W Sites',
        Icons.map_outlined,
        cardColors[colorIndex++],
        () {
          // Navigate to all FSMs overview page
          Navigator.of(context).pushNamed('/all_fsms');
        },
      ),
      _buildFeatureCard(
        context,
        'Simulate Site',
        Icons.play_arrow,
        cardColors[colorIndex++],
        () {
          // TODO: Navigate to simulation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Simulation coming soon!')),
          );
        },
      ),
      _buildFeatureCard(
        context,
        'Settings',
        Icons.settings,
        cardColors[colorIndex++],
        () {
          // TODO: Navigate to settings
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings coming soon!')),
          );
        },
      ),
    ];

    // Add admin-only features
    if (_userRole == 'admin') {
      cards.addAll([
        _buildFeatureCard(
          context,
          'User Management',
          Icons.people,
          cardColors[colorIndex++],
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User Management coming soon!')),
            );
          },
        ),
        _buildFeatureCard(
          context,
          'System Settings',
          Icons.admin_panel_settings,
          cardColors[colorIndex++],
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('System Settings coming soon!')),
            );
          },
        ),
      ]);
    }

    return cards;
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                onHover: (isHovered) {
                  // Hover effect could be added here
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          size: 32,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AppDrawer extends StatefulWidget {
  @override
  State<_AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<_AppDrawer> with TickerProviderStateMixin {
  late AnimationController _drawerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _drawerController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _drawerController, curve: Curves.easeOutCubic));

    _drawerController.forward();
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UserAccountsDrawerHeader(
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  accountName: const Text('John Doe'),
                  accountEmail: const Text('john.doe@example.com'),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings coming soon')),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    context.watch<ThemeProvider>().isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                  title: Text(
                      'Theme: ${context.watch<ThemeProvider>().getThemeModeName()}'),
                  subtitle: Text('Tap to cycle through themes'),
                  onTap: () {
                    context.read<ThemeProvider>().toggleTheme();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Theme changed to: ${context.read<ThemeProvider>().getThemeModeName()}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed('/auth');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Log out'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
