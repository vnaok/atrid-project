import 'package:flutter/material.dart';

class VisitorHomePage extends StatelessWidget {
  const VisitorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exploradores del Museo'),
      ),
      body: const Center(
        child: Text(
          'Home del visitante',
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}