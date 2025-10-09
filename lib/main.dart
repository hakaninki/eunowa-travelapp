import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/theme/app_theme.dart';
import 'package:travel_app/features/auth/presentation/pages/login_page.dart';
import 'package:travel_app/features/auth/presentation/pages/sign_up.dart';
import 'package:travel_app/features/splash/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/main/main_page.dart';
import 'features/profile/pages/profile_page.dart';
//import 'features/auth/presentation/pages/auth_gate.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      //initialRoute: '/SplashPage', // veya SplashPage varsa orası
      home: const SplashPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/main': (context) => const MainPage(),
        '/profile': (context) => const ProfilePage(),

      },
      //home: const LoginPage(),
    );
  }
}
