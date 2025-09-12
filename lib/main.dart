import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme_provider.dart';
import 'onboarding_page.dart';
import 'auth_page.dart';
import 'home_page.dart';
import 'create_fsm_page.dart';
import 'load_fsm_page.dart';
import 'map_page.dart';
import 'all_fsms_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic> _generateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case '/onboarding':
        page = const OnboardingPage();
        break;
      case '/auth':
        page = const AuthPage();
        break;
      case '/home':
        page = const HomePage();
        break;
      case '/create_fsm':
        page = const CreateFSMPage();
        break;
      case '/load_fsm':
        page = const LoadFSMPage();
        break;
      case '/map':
        // Don't use const here to allow passing arguments
        page = MapPage();
        break;
      case '/all_fsms':
        page = const AllFSMsPage();
        break;
      default:
        page = const OnboardingPage();
    }

    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Prototype FSM',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          themeMode: themeProvider.themeMode,
          initialRoute: '/onboarding',
          onGenerateRoute: _generateRoute,
        );
      },
    );
  }
}
