import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/login_page.dart';
import 'widgets/auth_gate.dart';
import 'widgets/firebase_setup_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (error) {
    runApp(
      KayraCraftApp(
        home: FirebaseSetupPage(
          errorMessage: '${error.code}: ${error.message}',
        ),
      ),
    );
    return;
  }

  runApp(KayraCraftApp(home: AuthGate(auth: FirebaseAuth.instance)));
}

class KayraCraftApp extends StatelessWidget {
  const KayraCraftApp({super.key, this.home = const LoginPage()});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kayra Craft',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F5F0),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9B7653)),
        fontFamily: 'sans',
      ),
      home: home,
    );
  }
}
