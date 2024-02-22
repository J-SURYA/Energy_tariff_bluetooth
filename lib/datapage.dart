// ignore_for_file: camel_case_types
import 'package:flutter/material.dart';

class inSightsPage extends StatefulWidget {
  const inSightsPage({super.key});

  @override
  State<inSightsPage> createState() => _inSightsPageState();
}

class _inSightsPageState extends State<inSightsPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'No insights',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}