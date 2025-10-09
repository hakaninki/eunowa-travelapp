import 'package:flutter/material.dart';

class MapPostMarker extends StatelessWidget {
  final VoidCallback? onTap;

  const MapPostMarker({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: const Icon(Icons.location_on, size: 40, color: Colors.red),
    );
  }
}
