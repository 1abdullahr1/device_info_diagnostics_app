import 'package:flutter/material.dart';
import 'data/device_data_service.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/glossary_screen.dart';
import 'screens/diagnostics_screen.dart';
import 'screens/about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DeviceDataService.instance.loadDeviceSpecs();
  runApp(const DeviceInfoApp());
}

class DeviceInfoApp extends StatefulWidget {
  const DeviceInfoApp({super.key});

  @override
  State<DeviceInfoApp> createState() => _DeviceInfoAppState();
}

class _DeviceInfoAppState extends State<DeviceInfoApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Specs & Diagnostics',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      home: MainNavigationScaffold(
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class MainNavigationScaffold extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const MainNavigationScaffold({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    GlossaryScreen(),
    DiagnosticsScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.phone_android_outlined),
            selectedIcon: Icon(Icons.phone_android_rounded),
            label: 'Specs',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Guide',
          ),
          NavigationDestination(
            icon: Icon(Icons.terminal_outlined),
            selectedIcon: Icon(Icons.terminal_rounded),
            label: 'Diagnostics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'About',
          ),
        ],
      ),
    );
  }
}
