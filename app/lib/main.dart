import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DraughtsmanApp());
}

class DraughtsmanApp extends StatelessWidget {
  const DraughtsmanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Draughtsman Mechanical Study App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        textTheme: GoogleFonts.notoSansDevanagariTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}
