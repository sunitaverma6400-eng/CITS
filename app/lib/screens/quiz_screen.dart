import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

class QuizScreen extends StatefulWidget {
  final Chapter chapter;
  const QuizScreen({super.key, required this.chapter});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Flashcard> cards;
  int index = 0;
  int score = 0;
  String? selected;
  List<String> options = [];

  @override
  void initState() {
    super.initState();
    cards = List.from(widget.chapter.flashcards)..shuffle();
    _generateOptions();
  }

  void _generateOptions() {
    final correct = cards[index].definition;
    final others = widget.chapter.flashcards
        .where((c) => c.id != cards[index].id)
        .map((c) => c.definition)
        .toList()
      ..shuffle();
    final distractors = others.take(3).toList();
    options = [correct, ...distractors]..shuffle(Random());
    selected = null;
  }

  void _answer(String choice) {
    setState(() {
      selected = choice;
      if (choice == cards[index].definition) score++;
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        if (index < cards.length - 1) {
          index++;
          _generateOptions();
        } else {
          index++; // triggers result screen
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (index >= cards.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Result')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$score / ${cards.length}',
                  style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Sahi jawab', style: GoogleFonts.notoSansDevanagari()),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Wapas jao'),
              ),
            ],
          ),
        ),
      );
    }

    final card = cards[index];
    return Scaffold(
      appBar: AppBar(title: Text('Quiz  ${index + 1}/${cards.length}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Term:',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 6),
            Text(card.term,
                style: GoogleFonts.notoSansDevanagari(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ...options.map((opt) {
              Color? color;
              if (selected != null) {
                if (opt == card.definition) {
                  color = Colors.green.shade100;
                } else if (opt == selected) {
                  color = Colors.red.shade100;
                }
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: selected == null ? () => _answer(opt) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color ?? Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(opt,
                        style: GoogleFonts.notoSansDevanagari(height: 1.4)),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
