import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memory/firebase_options.dart';
import 'package:memory/image_provider.dart';
import 'package:memory/screens/auth.dart';
import 'package:memory/screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:memory/screens/splash.dart';

var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 105, 63, 42),
);

var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 9, 0, 65),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ImagePathProvider.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kDarkColorScheme,
      ),
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData) {
            return const MainScreen();
          }

          return const AuthScreen();
        },
      ),
    ),
  );
}
