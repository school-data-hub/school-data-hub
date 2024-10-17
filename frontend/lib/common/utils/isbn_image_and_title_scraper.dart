import 'dart:developer';

import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

//- TODO: This is experimental code and should be tested before using in production
class ISBNImageAndTitle {
  final String imageUrl;
  final String title;
  ISBNImageAndTitle({required this.imageUrl, required this.title});
}

Future<ISBNImageAndTitle> getISBNImageAndTitle(String isbn) async {
  final url = 'https://isbnsearch.org/isbn/$isbn';
  final response = await http.get(Uri.parse(url));
  debugger();
  final document = parse(response.body);

  // Find the div with id 'book'
  var bookDiv = document.querySelector('#book');
  var imgElement = bookDiv?.querySelector('image');
  final imageUrl = imgElement!.attributes['src'] ?? 'No image URL found';
  final title = imgElement.attributes['alt'] ?? 'No title found';

  return ISBNImageAndTitle(
    imageUrl: imageUrl,
    title: title,
  );
}
