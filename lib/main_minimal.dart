import 'package:flutter/material.dart';

void main() {
  runApp(const MinimalLegalAdvisorApp());
}

class MinimalLegalAdvisorApp extends StatelessWidget {
  const MinimalLegalAdvisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Legal Advisor App - Minimal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MinimalHomePage(),
    );
  }
}

class MinimalHomePage extends StatelessWidget {
  const MinimalHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Legal Advisor App'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Legal Advisor App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Minimal build test successful!',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
          ],
        ),
      ),
    );
  }
}