import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/data/models/news_model.dart';
import 'package:flutter_app_base/data/providers/news_provider.dart';
import 'package:provider/provider.dart';

class NewsDataProvider extends StatefulWidget {
  final Widget Function(NewsData data) builder;

  const NewsDataProvider({
    super.key,
    required this.builder,
  });

  @override
  State<NewsDataProvider> createState() => _NewsDataProviderState();
}

class _NewsDataProviderState extends State<NewsDataProvider> {
  bool _isInitialLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNewsIfEmpty();
  }

  Future<void> _loadNewsIfEmpty() async {
    setState(() {
      _isInitialLoading = true;
    });

    await newsService.loadNewsIfEmpty(context);

    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsList = context.watch<NewsProvider>().items;

    // Sort news by publishedAt from most recent to oldest
    final sortedNewsList = List<NewsModel>.from(newsList);
    sortedNewsList.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.publishedAt);
        final dateB = DateTime.parse(b.publishedAt);
        return dateB.compareTo(dateA); // Most recent first (descending order)
      } catch (e) {
        // If parsing fails, put invalid dates at the end
        return 0;
      }
    });

    final newsData = NewsData(
      news: sortedNewsList,
      isInitialLoading: _isInitialLoading,
    );

    return widget.builder(newsData);
  }
}

class NewsData {
  final List<NewsModel> news;
  final bool isInitialLoading;

  const NewsData({
    required this.news,
    required this.isInitialLoading,
  });
}
