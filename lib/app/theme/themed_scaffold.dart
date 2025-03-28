import 'package:flutter/material.dart';

class ThemedScaffold extends StatelessWidget {
  final Widget child;

  const ThemedScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFDE7), Color(0xFFFFF9C4), Color(0xFFFFECB3)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}
