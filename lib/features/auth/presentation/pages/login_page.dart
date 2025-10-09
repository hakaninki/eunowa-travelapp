import 'package:flutter/material.dart';
import 'package:travel_app/features/auth/presentation/widgets/login_form.dart';
import 'package:travel_app/features/auth/presentation/widgets/login_header.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF2E6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Logo ve Slogan
            const LoginHeader(),

            const SizedBox(height: 40),
            
            // E-mail
            LoginForm(),
          ],
        ),
      ),
    );
  }
}
