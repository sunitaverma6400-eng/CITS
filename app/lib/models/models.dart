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

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      term: json['term'],
      definition: json['definition'],
    );
  }
}

class KeyConcept {
  final String term;
  final String explanation;

  KeyConcept({required this.term, required this.explanation});

  factory KeyConcept.fromJson(Map<String, dynamic> json) {
    return KeyConcept(
      term: json['term'],
      explanation: json['explanation'],
    );
  }
}

class StudyGuide {
  final String summary;
  final List<KeyConcept> keyConcepts;

  StudyGuide({required this.summary, required this.keyConcepts});

  factory StudyGuide.fromJson(Map<String, dynamic> json) {
    return StudyGuide(
      summary: json['summary'],
      keyConcepts: (json['keyConcepts'] as List)
          .map((e) => KeyConcept.fromJson(e))
          .toList(),
    );
  }
}

class Chapter {
  final String id;
  final String title;
  final StudyGuide studyGuide;
  final List<Flashcard> flashcards;
  final List<String> images;

  Chapter({
    required this.id,
    required this.title,
    required this.studyGuide,
    required this.flashcards,
    this.images = const [],
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      title: json['title'],
      studyGuide: StudyGuide.fromJson(json['studyGuide']),
      flashcards: (json['flashcards'] as List)
          .map((e) => Flashcard.fromJson(e))
          .toList(),
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : const [],
    );
  }
}

class Subject {
  final String id;
  final String name;
  final List<Chapter> chapters;

  Subject({required this.id, required this.name, required this.chapters});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      chapters:
          (json['chapters'] as List).map((e) => Chapter.fromJson(e)).toList(),
    );
  }
}
