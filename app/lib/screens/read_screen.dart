import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

class ReadScreen extends StatefulWidget {
  final Chapter chapter;
  const ReadScreen({super.key, required this.chapter});

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  double fontSize = 17;

  @override
  Widget build(BuildContext context) {
    final text = widget.chapter.fullText;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter.title, style: GoogleFonts.notoSansDevanagari()),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () => setState(() => fontSize = (fontSize - 1).clamp(12, 28)),
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () => setState(() => fontSize = (fontSize + 1).clamp(12, 28)),
          ),
        ],
      ),
      body: text.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Is chapter ka poora text abhi available nahi hai.\n\n'
                  'Termux mein "python3 scripts/add_full_text.py" chalao '
                  'aur naya data push karo.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansDevanagari(),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                text,
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: fontSize,
                  height: 1.7,
                ),
              ),
            ),
    );
  }
}
