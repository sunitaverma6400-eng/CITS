import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import 'chapter_screen.dart';

List<Subject> _parseSubjects(String raw) {
  final data = json.decode(raw);
  final subjects = <Subject>[];
  final rawSubjects = data['subjects'];
  if (rawSubjects is List) {
    for (final e in rawSubjects) {
      if (e is Map<String, dynamic>) {
        final s = Subject.tryFromJson(e);
        if (s != null) subjects.add(s);
      }
    }
  }
  return subjects;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Subject> subjects = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final raw = await rootBundle.loadString('assets/data/flashcards_data.json');
      final parsed = await compute(_parseSubjects, raw);
      if (!mounted) return;
      setState(() {
        subjects = parsed;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Draughtsman Mechanical', style: GoogleFonts.notoSansDevanagari(fontWeight: FontWeight.bold))),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text('Data load nahi ho paya:\n$error', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() { loading = true; error = null; });
                            _loadData();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : subjects.isEmpty
                  ? const Center(child: Text('Koi content nahi mila.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: subjects.length,
                      itemBuilder: (context, i) {
                        final subject = subjects[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            title: Text(subject.name, style: GoogleFonts.notoSansDevanagari(fontSize: 18, fontWeight: FontWeight.w600)),
                            children: subject.chapters
                                .map((ch) => ListTile(
                                      title: Text(ch.title, style: GoogleFonts.notoSansDevanagari()),
                                      subtitle: Text('${ch.flashcards.length} cards'),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => ChapterScreen(chapter: ch)));
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
