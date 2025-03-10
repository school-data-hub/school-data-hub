class BookProxy {
  final int isbn;
  final String bookId;
  final String title;
  final String author;
  final String description;
  final String readingLevel;
  final String imageId;
  final bool available;
  final String location;
  final List<BookTag> bookTags;

  BookProxy(
      {required this.isbn,
      required this.bookId,
      required this.title,
      required this.author,
      required this.description,
      required this.readingLevel,
      required this.imageId,
      required this.available,
      required this.location,
      required this.bookTags});

  factory BookProxy.fromJson(Map<String, dynamic> json) {
    var bookJson = json['book'];
    return BookProxy(
      isbn: bookJson['isbn'],
      bookId: json['book_id'],
      title: bookJson['title'],
      author: bookJson['author'],
      description: bookJson['description'],
      readingLevel: bookJson['reading_level'],
      imageId: bookJson['image_id'],
      available: json['available'],
      location: json['location'],
      bookTags: (bookJson['book_tags'] as List)
          .map((tag) => BookTag.fromJson(tag))
          .toList(),
    );
  }
}

class BookTag {
  final String name;

  BookTag({required this.name});
  factory BookTag.fromJson(Map<String, dynamic> json) {
    return BookTag(name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}
