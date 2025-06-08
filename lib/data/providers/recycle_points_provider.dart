import 'package:flutter_app_base/data/models/recycle_point_model.dart';
import 'package:flutter_app_base/data/providers/base_provider.dart';
import 'package:flutter_app_base/data/repositories/recycle_point_repository.dart';

class RecyclePointsProvider extends BaseProvider<RecyclePointModel> {
  RecyclePointsProvider(RecyclePointRepository recyclePointRepository)
      : super(recyclePointRepository.getDocumentsStream);
}