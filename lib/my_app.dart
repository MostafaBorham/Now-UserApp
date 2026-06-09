import 'package:flutter/material.dart';

class NowUserApp extends StatelessWidget {
  const NowUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Now User App',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: null,
    );
  }
}