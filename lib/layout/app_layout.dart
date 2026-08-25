import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import '../screens/dashboard_screen.dart';
import '../screens/control_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/camera_screen.dart';

class AppLayout extends StatefulWidget {
  final int initialIndex;

  const AppLayout({super.key, this.initialIndex = 0});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  late int _currentIndex;
  String? _userEmail;
  String _selectedPlant = 'Strawberry';

  void _handlePlantChanged(String plant) {
    setState(() {
      _selectedPlant = plant;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _fetchUserEmail();
  }

  Future<void> _fetchUserEmail() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      for (final attribute in attributes) {
        if (attribute.userAttributeKey == AuthUserAttributeKey.email) {
          setState(() {
            _userEmail = attribute.value;
          });
          break;
        }
      }
    } catch (e) {
      safePrint('Error fetching user email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Text(
              'Hydrotek Farm',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'SYSTEM ONLINE',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          Tooltip(
            message: _userEmail ?? 'Loading...',
            child: IconButton(
              icon: const Icon(Icons.account_circle),
              color: theme.colorScheme.primary,
              onPressed: () {},
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            color: theme.colorScheme.primary,
            onPressed: () async {
              try {
                await Amplify.Auth.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              } catch (e) {
                safePrint('Error signing out: $e');
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            DashboardScreen(
              selectedPlant: _selectedPlant,
              onPlantChanged: _handlePlantChanged,
            ),
            ControlScreen(
              selectedPlant: _selectedPlant,
              onPlantChanged: _handlePlantChanged,
            ),
            const AnalyticsScreen(),
            const CameraScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Theme(
        data: theme.copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: theme.colorScheme.surface,
          elevation: 10,
          indicatorColor: theme.colorScheme.primaryContainer,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.sensors_outlined),
              selectedIcon: Icon(Icons.sensors),
              label: 'Monitoring',
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_outlined),
              selectedIcon: Icon(Icons.tune),
              label: 'Control',
            ),
            NavigationDestination(
              icon: Icon(Icons.leaderboard_outlined),
              selectedIcon: Icon(Icons.leaderboard),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.videocam_outlined),
              selectedIcon: Icon(Icons.videocam),
              label: 'Camera',
            ),
          ],
        ),
      ),
    );
  }
}
