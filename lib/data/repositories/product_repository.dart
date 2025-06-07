import 'package:flutter_app_base/data/models/product_model.dart';
import 'package:flutter_app_base/data/repositories/base_repository.dart';

class ProductRepository extends BaseRepository<ProductModel> {
  ProductRepository()
      : super(
          collectionName: "products",
          fromDocumentSnapshot: (doc) => ProductModel.fromDocumentSnapshot(doc),
          toMap: (user) => user.toMap(),
        );
}
