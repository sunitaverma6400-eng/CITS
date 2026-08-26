class Flashcard {
  final String id;
  final String term;
  final String definition;
  int status; // 0 = new, 1 = still learning, 2 = got it

  Flashcard({
    required this.id,
    required this.term,
    required this.definition,
    this.status = 0,
  });

  // Returns null instead of throwing if this entry is malformed —
  // one bad flashcard should never crash the whole app.
  static Flashcard? tryFromJson(Map<String, dynamic> json) {
    final term = json['term'];
    final definition = json['definition'];
    if (term == null || definition == null) return null;
    return Flashcard(
      id: (json['id'] ?? '').toString(),
      term: term.toString(),
      definition: definition.toString(),
    );
  }
}

class KeyConcept {
  final String term;
  final String explanation;

  KeyConcept({required this.term, required this.explanation});

  static KeyConcept? tryFromJson(Map<String, dynamic> json) {
    final term = json['term'];
    final explanation = json['explanation'];
    if (term == null || explanation == null) return null;
    return KeyConcept(term: term.toString(), explanation: explanation.toString());
  }
}

class StudyGuide {
  final String summary;
  final List<KeyConcept> keyConcepts;

  StudyGuide({required this.summary, required this.keyConcepts});

  factory StudyGuide.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return StudyGuide(summary: '', keyConcepts: []);
    }
    final rawList = json['keyConcepts'];
    final concepts = <KeyConcept>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          final kc = KeyConcept.tryFromJson(e);
          if (kc != null) concepts.add(kc);
        }
      }
    }
    return StudyGuide(
      summary: (json['summary'] ?? '').toString(),
      keyConcepts: concepts,
    );
  }
}

class Chapter {
  final String id;
  final String title;
  final StudyGuide studyGuide;
  final List<Flashcard> flashcards;
  final List<String> images;
  final String fullText;

  Chapter({
    required this.id,
    required this.title,
    required this.studyGuide,
    required this.flashcards,
    this.images = const [],
    this.fullText = '',
  });

  // Returns null if this chapter has no usable flashcards at all —
  // otherwise keeps whatever valid flashcards it does have.
  static Chapter? tryFromJson(Map<String, dynamic> json) {
    final rawCards = json['flashcards'];
    final cards = <Flashcard>[];
    if (rawCards is List) {
      for (final e in rawCards) {
        if (e is Map<String, dynamic>) {
          final fc = Flashcard.tryFromJson(e);
          if (fc != null) cards.add(fc);
        }
      }
    }
    if (cards.isEmpty) return null;

    List<String> images = const [];
    final rawImages = json['images'];
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString()).toList();
    }

    return Chapter(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'Untitled').toString(),
      studyGuide: StudyGuide.fromJson(json['studyGuide']),
      flashcards: cards,
      images: images,
      fullText: (json['fullText'] ?? '').toString(),
    );
  }
}

class Subject {
  final String id;
  final String name;
  final List<Chapter> chapters;

  Subject({required this.id, required this.name, required this.chapters});

  static Subject? tryFromJson(Map<String, dynamic> json) {
    final rawChapters = json['chapters'];
    final chapters = <Chapter>[];
    if (rawChapters is List) {
      for (final e in rawChapters) {
        if (e is Map<String, dynamic>) {
          final ch = Chapter.tryFromJson(e);
          if (ch != null) chapters.add(ch);
        }
      }
    }
    if (chapters.isEmpty) return null;
    return Subject(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Untitled').toString(),
      chapters: chapters,
    );
  }
}
