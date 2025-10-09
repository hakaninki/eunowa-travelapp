import 'dart:async';
import 'package:flutter/material.dart';
import 'package:travel_app/features/auth/presentation/pages/auth_gate.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Kısa bir bekleme sonrası AuthGate'e yönlendir
    scheduleMicrotask(() async {
      await Future.delayed(const Duration(milliseconds: 2200));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Uygulamanın kullandığı splash görselini sadece arkaplan yapalım
          Image.asset(
            "images/splash5.png",
            fit: BoxFit.cover,
          ),
          // Ortada logo/başlık
          Align(
            alignment: Alignment(0, -0.35),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:  [
                Text(
                  "EUNOWA",
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w800,
                    color: Colors.orange[900],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Places live through stories",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Alt kısımda küçük telif vs. istersen
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Text(
              "CrewCo © 2025",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
