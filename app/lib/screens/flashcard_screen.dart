import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

class FlashcardScreen extends StatefulWidget {
  final Chapter chapter;
  const FlashcardScreen({super.key, required this.chapter});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int index = 0;
  bool showAnswer = false;

  void _next() {
    setState(() {
      showAnswer = false;
      index = (index + 1) % widget.chapter.flashcards.length;
    });
  }

  void _prev() {
    setState(() {
      showAnswer = false;
      index = (index - 1 + widget.chapter.flashcards.length) %
          widget.chapter.flashcards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.chapter.flashcards[index];
    return Scaffold(
      appBar: AppBar(
        title: Text('${index + 1} / ${widget.chapter.flashcards.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => showAnswer = !showAnswer),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    key: ValueKey(showAnswer),
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: showAnswer
                          ? Colors.green.shade50
                          : Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: showAnswer ? Colors.green : Colors.indigo,
                          width: 1.5),
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
            ),
            const SizedBox(height: 12),
            Text('Tap card to flip',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filled(
                    onPressed: _prev, icon: const Icon(Icons.arrow_back)),
                IconButton.filled(
                    onPressed: _next, icon: const Icon(Icons.arrow_forward)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
