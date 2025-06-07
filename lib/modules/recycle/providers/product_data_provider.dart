import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/data/models/product_model.dart';
import 'package:flutter_app_base/data/providers/products_provider.dart';
import 'package:provider/provider.dart';

class ProductDataProvider extends StatelessWidget {
  final String barcode;
  final Widget Function(ProductData data) builder;

  const ProductDataProvider({
    super.key,
    required this.barcode,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // Get product with matching barcode
    final product = context.select<ProductsProvider, ProductModel?>(
      (provider) => provider.items.firstWhereOrNull((p) => p.barcode == barcode),
    );

    final productData = ProductData(product: product);

    return builder(productData);
  }
}

class ProductData {
  final ProductModel? product;

  const ProductData({
    required this.product,
  });
}
