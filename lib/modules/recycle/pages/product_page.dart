import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';
import 'package:flutter_app_base/data/models/product_model.dart';
import 'package:flutter_app_base/modules/recycle/pages/product_not_found_page.dart';
import 'package:flutter_app_base/modules/recycle/providers/product_data_provider.dart';

class ProductPage extends StatefulWidget {
  final String barcode;

  const ProductPage({super.key, required this.barcode});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return ProductDataProvider(
      barcode: widget.barcode,
      builder: (productData) => _buildContent(productData),
    );
  }

  Widget _buildContent(ProductData productData) {
    final product = productData.product;

    // Show loading or error state if product is not found
    if (product == null) {
      return ProductNotFoundPage(barcode: widget.barcode);
    }

    // Determine colors based on recyclability
    Color lightColor;
    Color darkColor;

    if (product.isRecyclable) {
      lightColor = const Color.fromARGB(255, 99, 210, 102);
      darkColor = const Color.fromARGB(255, 83, 161, 86);
    } else {
      lightColor = const Color.fromARGB(255, 251, 87, 75);
      darkColor = const Color.fromARGB(255, 181, 43, 33);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: product.imageUrl.isNotEmpty
                ? Image.network(product.imageUrl, height: 200)
                : Container(
                    height: 200,
                    width: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  ),
          ),
          _buildProductInfo(product, lightColor),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(product, lightColor, darkColor),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => AppNavigator.pop(context: context),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(ProductModel product, Color lightColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            product.title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                const TextSpan(
                  text: 'Description: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: product.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'Category: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: lightColor,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: product.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'Material: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: lightColor,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: product.material,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'Brand: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: lightColor,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: product.brand,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ProductModel product, Color lightColor, Color darkColor) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(40),
        topRight: Radius.circular(40),
      ),
      child: Container(
        color: lightColor,
        height: 200,
        padding: const EdgeInsets.only(
          left: 40,
          right: 40,
          top: 20,
          bottom: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              product.isRecyclable 
                  ? "This product is recyclable!" 
                  : "This product is not recyclable",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  (product.points != 1)
                      ? "${product.points} Points"
                      : "1 Point",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 28,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (product.isRecyclable)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: GestureDetector(
                      onTap: () => recycleService.recycleProduct(context, product),
                      child: Container(
                        color: darkColor,
                        width: 120,
                        height: 60,
                        alignment: Alignment.center,
                        child: const Text(
                          'Recycle Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
