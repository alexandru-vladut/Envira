import 'package:flutter_app_base/data/models/recycle_point_model.dart';
import 'package:flutter_app_base/data/repositories/base_repository.dart';

class RecyclePointRepository extends BaseRepository<RecyclePointModel> {
  RecyclePointRepository()
      : super(
          collectionName: "recycle_points",
          fromDocumentSnapshot: (doc) => RecyclePointModel.fromDocumentSnapshot(doc),
          toMap: (recyclePoint) => recyclePoint.toMap(),
        );
}
