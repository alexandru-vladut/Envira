import 'package:flutter_app_base/data/models/news_model.dart';
import 'package:flutter_app_base/data/providers/base_provider.dart';
import 'package:flutter_app_base/data/repositories/news_repository.dart';

class NewsProvider extends BaseProvider<NewsModel> {
  NewsProvider(NewsRepository newsRepository)
      : super(newsRepository.getDocumentsStream);
}