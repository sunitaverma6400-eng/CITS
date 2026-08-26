import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

class StudyGuideScreen extends StatelessWidget {
  final Chapter chapter;
  const StudyGuideScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final guide = chapter.studyGuide;
    return Scaffold(
      appBar: AppBar(title: const Text('Study Guide')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(chapter.title,
              style: GoogleFonts.notoSansDevanagari(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(guide.summary,
                style: GoogleFonts.notoSansDevanagari(
                    fontSize: 15, height: 1.6)),
          ),
          if (chapter.images.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Diagrams / Reference Pages',
                style: GoogleFonts.notoSansDevanagari(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: chapter.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        child: InteractiveViewer(
                          child: Image.asset(chapter.images[i]),
                        ),
                      ),
                    ),
                    child: Image.asset(
                      chapter.images[i],
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text('Key Concepts',
              style: GoogleFonts.notoSansDevanagari(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...guide.keyConcepts.map((k) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(k.term,
                          style: GoogleFonts.notoSansDevanagari(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo)),
                      const SizedBox(height: 6),
                      Text(k.explanation,
                          style: GoogleFonts.notoSansDevanagari(height: 1.5)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
