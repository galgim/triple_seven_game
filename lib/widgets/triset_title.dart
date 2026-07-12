import 'package:flutter/material.dart';

class TrisetTitle extends StatelessWidget {
  const TrisetTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'TRISET',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 52,
        fontWeight: FontWeight.w900,
        letterSpacing: 4,
        height: 1.1,
      ),
    );
  }
}
