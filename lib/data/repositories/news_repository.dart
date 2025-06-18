import 'package:flutter_app_base/data/models/news_model.dart';
import 'package:flutter_app_base/data/repositories/base_repository.dart';

class NewsRepository extends BaseRepository<NewsModel> {
  NewsRepository()
      : super(
          collectionName: "news",
          fromDocumentSnapshot: (doc) => NewsModel.fromDocumentSnapshot(doc),
          toMap: (news) => news.toMap(),
        );
}