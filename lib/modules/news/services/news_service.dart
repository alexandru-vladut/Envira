import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/config.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets/dialog_widgets.dart';
import 'package:flutter_app_base/data/models/news_model.dart';
import 'package:flutter_app_base/data/repositories/news_repository.dart';
import 'package:http/http.dart' as http;

class NewsService {
  final NewsRepository _newsRepository;

  NewsService(this._newsRepository);

  static const String _apiBaseUrl = 'https://newsapi.org/v2/everything';
  static const String _apiKey = NewsConfig.apiKey;

  Future<void> loadNewsIfEmpty(BuildContext context) async {
    try {
      // Check if news collection is empty
      final existingNews = await _newsRepository.getAllDocuments();
      
      if (existingNews.isEmpty) {
        // Collection is empty, fetch from API
        await _fetchAndStoreNews(context);
      }
    } catch (error) {
      errorDialog(
        context: context,
        title: 'Error loading news',
        text: error.toString(),
      );
    }
  }

  Future<void> refreshNews(BuildContext context) async {
    try {
      // Get existing news from Firestore
      final existingNews = await _newsRepository.getAllDocuments();
      final existingTitles = existingNews.map((news) => news.title).toSet();
      
      // Fetch fresh news from API
      final newArticles = await _fetchNewsFromApi();
      
      // Filter out articles that already exist (by title)
      final articlesToAdd = newArticles.where((article) {
        final title = article['title']?.toString() ?? '';
        return !existingTitles.contains(title);
      }).toList();
      
      // Add only new articles to Firestore
      for (final article in articlesToAdd) {
        if (_isValidArticle(article)) {
          final newsModel = _createNewsModelFromArticle(article);
          await _newsRepository.addDocument(newsModel);
        }
      }
    } catch (error) {
      errorDialog(
        context: context,
        title: 'Error refreshing news',
        text: error.toString(),
      );
    }
  }

  Future<void> _fetchAndStoreNews(BuildContext context) async {
    try {
      // Get articles from API
      final articles = await _fetchNewsFromApi();
      
      // Store all articles (for initial load when collection is empty)
      for (final article in articles) {
        if (_isValidArticle(article)) {
          final newsModel = _createNewsModelFromArticle(article);
          await _newsRepository.addDocument(newsModel);
        }
      }
    } catch (error) {
      rethrow;
    }
  }

  // Extract API call logic to separate method for reuse
  Future<List<dynamic>> _fetchNewsFromApi() async {
    // Calculate date range (last 7 days)
    final fromDate = _formatDate(NewsConfig.fromDate);
    final toDate = _formatDate(NewsConfig.toDate);

    // Build API URL
    final url = Uri.parse(
      '$_apiBaseUrl?qInTitle="climate change" OR "sustainability" OR "eco-friendly" OR recycling'
      '&language=en&from=$fromDate&to=$toDate&sortBy=publishedAt'
      '&sources=${NewsConfig.sourceParam}&apiKey=$_apiKey',
    );

    print('Fetching news from: $url');

    // Make API request
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      
      if (jsonData['status'] == 'ok' && jsonData['articles'] != null) {
        return jsonData['articles'] as List;
      } else {
        throw Exception('Invalid API response: ${jsonData['message'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('API request failed with status: ${response.statusCode}');
    }
  }

  bool _isValidArticle(Map<String, dynamic> article) {
    return article['source']['name'] != null &&
           article['source']['name'].toString().isNotEmpty &&
           article['title'] != null &&
           article['title'].toString().isNotEmpty &&
           article['description'] != null &&
           article['description'].toString().isNotEmpty &&
           article['url'] != null &&
           article['url'].toString().isNotEmpty &&
           article['urlToImage'] != null &&
           article['urlToImage'].toString().isNotEmpty &&
           article['publishedAt'] != null &&
           article['publishedAt'].toString().isNotEmpty;
  }

  NewsModel _createNewsModelFromArticle(Map<String, dynamic> article) {
    return NewsModel(
      source: article['source']?['name'] ?? '',
      author: article['author'] ?? '',
      title: article['title'] ?? '',
      description: article['description'] ?? '',
      url: article['url'] ?? '',
      urlToImage: article['urlToImage'] ?? '',
      publishedAt: article['publishedAt'] ?? '',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
