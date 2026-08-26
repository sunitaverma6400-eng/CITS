import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

class LearnScreen extends StatefulWidget {
  final Chapter chapter;
  const LearnScreen({super.key, required this.chapter});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  late List<Flashcard> queue;
  bool showAnswer = false;
  int gotItCount = 0;

  @override
  void initState() {
    super.initState();
    queue = List.from(widget.chapter.flashcards);
  }

  void _mark(bool gotIt) {
    setState(() {
      showAnswer = false;
      final card = queue.removeAt(0);
      if (gotIt) {
        gotItCount++;
      } else {
        queue.add(card); // still learning -> push to back of queue
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.chapter.flashcards.length;
    if (queue.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Learn Mode')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration, size: 60, color: Colors.amber),
              const SizedBox(height: 16),
              Text('Sab cards complete! 🎉',
                  style: GoogleFonts.notoSansDevanagari(fontSize: 18)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Wapas jao'),
              ),
            ],
          ),
        ),
      );
    }

    final card = queue.first;
    return Scaffold(
      appBar: AppBar(title: Text('Learn Mode  ($gotItCount/$total got it)')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LinearProgressIndicator(value: gotItCount / total),
            const SizedBox(height: 20),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => showAnswer = !showAnswer),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: showAnswer ? Colors.green.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.indigo.shade200),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8)
                    ],
                  ),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Text(
                      showAnswer ? card.definition : card.term,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSansDevanagari(
                          fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (showAnswer)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: Colors.red),
                      onPressed: () => _mark(false),
                      child: const Text('Still Learning'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.green),
                      onPressed: () => _mark(true),
                      child: const Text('Got It!'),
                    ),
                  ),
                ],
              )
            else
              Text('Answer dekhne ke liye card par tap karo',
                  style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
