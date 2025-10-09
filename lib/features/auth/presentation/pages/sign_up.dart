import 'package:flutter/material.dart';
import 'package:travel_app/features/auth/presentation/widgets/login_header.dart';
import 'package:travel_app/features/auth/presentation/widgets/sign_up_form.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFFFF2E6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Logo ve Slogan
            const LoginHeader(),
            const SizedBox(height: 40),

            // Form Alanı
           SignUpForm(),
          ],
        ),
      ),
    );
  }
}
