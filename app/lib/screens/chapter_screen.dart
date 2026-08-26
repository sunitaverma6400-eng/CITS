import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import 'flashcard_screen.dart';
import 'learn_screen.dart';
import 'study_guide_screen.dart';
import 'quiz_screen.dart';
import 'read_screen.dart';

class ChapterScreen extends StatelessWidget {
  final Chapter chapter;
  const ChapterScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chapter.title, style: GoogleFonts.notoSansDevanagari()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                icon: const Icon(Icons.menu_book_outlined),
                label: Text('Poora Chapter Padhein (Read)',
                    style: GoogleFonts.notoSansDevanagari(
                        fontWeight: FontWeight.w600)),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ReadScreen(chapter: chapter)));
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _modeCard(context, 'Flashcards', Icons.style, Colors.indigo, () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => FlashcardScreen(chapter: chapter)));
                  }),
                  _modeCard(context, 'Learn Mode', Icons.school, Colors.teal, () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => LearnScreen(chapter: chapter)));
                  }),
                  _modeCard(context, 'Study Guide', Icons.menu_book, Colors.orange,
                      () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => StudyGuideScreen(chapter: chapter)));
                  }),
                  _modeCard(context, 'Quiz', Icons.quiz, Colors.pink, () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => QuizScreen(chapter: chapter)));
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeCard(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(label,
                style: GoogleFonts.notoSansDevanagari(
                    fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
