import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/auth/providers/auth_provider.dart';
import 'package:travel_app/features/auth/presentation/pages/login_page.dart';
import 'package:travel_app/features/main/main_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider); // Stream<User?>

    return authState.when(
      data: (user) {
        if (user != null) {
          // Oturum açık → direkt ana uygulama
          return const MainPage();
        } else {
          // Oturum yok → login
          return const LoginPage();
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Auth error: $e')),
      ),
    );
  }
}
