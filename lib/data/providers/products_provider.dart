import 'package:flutter_app_base/data/models/product_model.dart';
import 'package:flutter_app_base/data/providers/base_provider.dart';
import 'package:flutter_app_base/data/repositories/product_repository.dart';

class ProductsProvider extends BaseProvider<ProductModel> {
  ProductsProvider(ProductRepository productRepository)
      : super(productRepository.getDocumentsStream);
}