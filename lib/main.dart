import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // ← Add this import
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/privacy_screen.dart';
import 'services/firebase_service.dart'; // ← Keep this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const DripLixApp());
}

class DripLixApp extends StatelessWidget {
  const DripLixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider( // ← Wrap with MultiProvider
      providers: [
        Provider<FirebaseService>( // ← Provide FirebaseService
          create: (_) => FirebaseService(),
        ),
      ],
      child: MaterialApp(
        title: 'DripLix',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: NoAnimationPageTransitionsBuilder(),
              TargetPlatform.iOS: NoAnimationPageTransitionsBuilder(),
              TargetPlatform.macOS: NoAnimationPageTransitionsBuilder(),
              TargetPlatform.linux: NoAnimationPageTransitionsBuilder(),
              TargetPlatform.windows: NoAnimationPageTransitionsBuilder(),
              TargetPlatform.fuchsia: NoAnimationPageTransitionsBuilder(),
            },
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/explore': (context) => const ExploreScreen(),
          '/terms': (context) => const TermsScreen(),
          '/privacy': (context) => const PrivacyScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}