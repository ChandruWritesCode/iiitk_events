// ignore_for_file: deprecated_member_use

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iiitk_events/firebase_options.dart';
import 'package:iiitk_events/pages/home_page.dart';
import 'package:iiitk_events/pages/login_page.dart';
import 'package:iiitk_events/providers/authentication.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Authentication>(
          create: (context) => Authentication(),
        ),
      ],
      child: Consumer<Authentication>(
        builder: (context, auth, child) => MaterialApp(
          theme: ThemeData(
            brightness: .dark,
            useMaterial3: true,
            colorScheme:
                ColorScheme.fromSeed(
                  seedColor: const Color(0xFF00FF66),
                  brightness: .dark,
                ).copyWith(
                  background: Colors.black,
                  surface: Colors.black,
                  surfaceContainer: const Color(0xFF121212),
                  onBackground: const Color(0xFFFFFFFF),
                  onSurface: const Color(0xFFFFFFFF),
                  onSurfaceVariant: const Color(0xFFB3B3B3),
                ),

            cardTheme: CardThemeData(
              color: const Color(0xFF0A0A0A),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF222222), width: 1),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),

            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              scrolledUnderElevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: .bold,
              ),
            ),

            chipTheme: ChipThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              selectedColor: Theme.of(context).primaryColor,
              side: BorderSide(width: 1, color: Theme.of(context).cardColor),
              labelStyle: TextStyle(fontWeight: .bold),
            ),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF121212),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF333333)),
                ),
              ),
            ),
          ),

          debugShowCheckedModeBanner: false,
          home: auth.loggedIn ? HomePage() : const LoginPage(),
        ),
      ),
    );
  }
}
