import 'package:flutter/material.dart';
import 'screen1.dart';
import 'screen2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Screen1(),
      routes: {
        '/screen2': (context) => const Screen2(),
      },
    );
  }
}