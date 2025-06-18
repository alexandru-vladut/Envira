import 'package:cloud_firestore/cloud_firestore.dart';

class NewsModel {
  final String? docId;
  final String source;
  final String author;
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;

  NewsModel({
    this.docId,
    required this.source,
    required this.author,
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'source': source,
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
    };
  }

  factory NewsModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final rawData = doc.data();

    if (rawData == null) {
      throw Exception(
        'doc.data() is null for docId ${doc.id}, cannot convert to NewsModel.',
      );
    }

    try {
      Map data = rawData as Map<String, dynamic>;

      return NewsModel(
        docId: doc.id,
        source: data['source'],
        author: data['author'],
        title: data['title'],
        description: data['description'],
        url: data['url'],
        urlToImage: data['urlToImage'],
        publishedAt: data['publishedAt'],
      );
    } catch (e) {
      throw Exception(
        'Error converting document snapshot fields to NewsModel fields: $e',
      );
    }
  }
}
