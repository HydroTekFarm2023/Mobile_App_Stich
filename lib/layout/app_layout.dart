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
        if (attribute.userAttributeKey == AuthUserAttributeKey.email && mounted) {
          setState(() => _userEmail = attribute.value);
          break;
        }
      }
    } on Exception catch (e) {
      safePrint('Error fetching user email: $e');
    }
  }

  void _showProfile() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: Text(_userEmail ?? 'Email unavailable'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await Amplify.Auth.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on Exception catch (e) {
      safePrint('Error signing out: $e');
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
        leading: SizedBox(
          width: 88,
          height: 48,
          child: Icon(Icons.eco, color: theme.colorScheme.primary, size: 28),
        ),
        actions: [
          Tooltip(
            message: 'Profile',
            child: IconButton(
              icon: const Icon(Icons.account_circle),
              color: theme.colorScheme.primary,
              onPressed: _showProfile,
            ),
          ),
          Tooltip(
            message: 'Log out',
            child: IconButton(
              icon: const Icon(Icons.logout),
              color: theme.colorScheme.primary,
              onPressed: _signOut,
            ),
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
              icon: Icon(Icons.qr_code_scanner_outlined),
              selectedIcon: Icon(Icons.qr_code_scanner),
              label: 'Scan',
            ),
          ],
        ),
      ),
    );
  }
}
