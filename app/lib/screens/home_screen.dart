import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import 'chapter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Subject> subjects = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final raw = await rootBundle.loadString('assets/data/flashcards_data.json');
    final data = json.decode(raw);
    setState(() {
      subjects = (data['subjects'] as List)
          .map((e) => Subject.fromJson(e))
          .toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Draughtsman Mechanical',
            style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subjects.length,
              itemBuilder: (context, i) {
                final subject = subjects[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text(subject.name,
                        style: GoogleFonts.notoSansDevanagari(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    children: subject.chapters
                        .map((ch) => ListTile(
                              title: Text(ch.title,
                                  style: GoogleFonts.notoSansDevanagari()),
                              subtitle: Text('${ch.flashcards.length} cards'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChapterScreen(chapter: ch),
                                  ),
                                );
                              },
                            ))
                        .toList(),
                  ),
                );
              },
            ),
    );
  }
}
