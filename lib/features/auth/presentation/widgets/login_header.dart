import 'package:flutter/material.dart';
import 'package:travel_app/features/home/widgets/home_header.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.cover,
                child: const HomeHeader(),
              ),
            );
  }
}