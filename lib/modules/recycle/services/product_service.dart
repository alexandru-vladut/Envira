import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/config.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets/dialog_widgets.dart';
import 'package:flutter_app_base/data/models/product_model.dart';
import 'package:flutter_app_base/data/repositories/product_repository.dart';
import 'package:flutter_app_base/modules/custom_nav_bar.dart';
import 'package:flutter_app_base/modules/recycle/services/gemini_service.dart';
import 'package:flutter_app_base/modules/recycle/services/image_upload_service.dart';
import 'package:flutter_app_base/modules/recycle/widgets/manual_product_entry_modal.dart';
import 'package:http/http.dart' as http;

class ProductService {
  // Inject repositories
  final ProductRepository _productRepository;

  // Regular constructor
  ProductService(this._productRepository);

  static const String _apiBaseUrl = 'https://api.barcodelookup.com/v3/products';
  static const String _apiKey = AppConfig.barcodeLookupApiKey;

  Future<void> searchAndCreateProduct(
    BuildContext context,
    String barcode,
  ) async {
    loadingDialog(context: context);

    try {
      // Make API request
      final productData = await _fetchProductFromApi(barcode);

      if (productData != null) {
        // Create product in Firestore
        await _createProductInFirestore(productData, barcode);

        // Close loading dialog
        AppNavigator.pop();
      } else {
        // Product not found in API
        AppNavigator.pop(); // Close loading dialog
        await _showManualEntryModal(context, barcode);
      }
    } catch (error) {
      AppNavigator.pop(); // Close loading dialog
      errorDialog(
        context: context,
        title: 'Error searching for product: $error',
        onConfirm: () {
          AppNavigator.pop(); // Close error dialog
          AppNavigator.navigateTo(page: CustomNavBar()); // Go to home
        },
      );
    }
  }

  Future<Map<String, dynamic>?> _fetchProductFromApi(String barcode) async {
    final url = Uri.parse(
      '$_apiBaseUrl?barcode=$barcode&formatted=y&key=$_apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // Check if products array exists and is not empty
      if (jsonData['products'] != null && jsonData['products'].isNotEmpty) {
        Map<String, dynamic> apiProduct = jsonData['products'][0];

        // Check if the product has a valid title
        if (apiProduct['title'] == null || apiProduct['title'].isEmpty ||
            apiProduct['brand'] == null || apiProduct['brand'].isEmpty) {
          return null; // Invalid product data
        }

        return apiProduct; // Return first product
      }
      return null; // No products found
    } else if (response.statusCode == 404) {
      return null; // Product not found
    } else {
      throw Exception('API request failed with status: ${response.statusCode}');
    }
  }

  Future<void> _createProductInFirestore(
    Map<String, dynamic> apiProduct,
    String barcode,
  ) async {
    // Extract and clean data from API response
    final title = _cleanString(apiProduct['title']);
    final description = _cleanString(apiProduct['description'] ?? '');
    final category = _cleanString(apiProduct['category'] ?? '');
    final brand = _cleanString(apiProduct['brand']);
    final material = _cleanString(apiProduct['material'] ?? '');

    // Get first image URL if available
    String imageUrl = '';
    if (apiProduct['images'] != null && apiProduct['images'].isNotEmpty) {
      imageUrl = apiProduct['images'][0].toString();
    }

    // Use AI to analyze product and fill missing information
    final aiResult = await GeminiService.analyzeProductRecyclability(
      title: title,
      brand: brand,
      category: category,
      material: material,
      description: description,
    );

    // Create ProductModel using AI-enhanced data
    final product = ProductModel(
      barcode: barcode,
      title: title,
      description: aiResult.description, // Use AI-researched description if original was empty
      category: aiResult.category,       // Use AI-researched category if original was empty
      brand: brand,
      material: aiResult.material,       // Use AI-researched material if original was empty
      imageUrl: imageUrl,
      isRecyclable: aiResult.isRecyclable,
      points: aiResult.points,
      reasoning: aiResult.reasoning,
    );

    // Save to Firestore
    await _productRepository.addDocument(product);
  }

  String _cleanString(String? input) {
    if (input == null || input.isEmpty) return '';
    return input.trim();
  }

  Future<void> uploadProductImage({
    required BuildContext context,
    required ProductModel product,
  }) async {
    try {
      // Upload image and get URL
      final String? imageUrl = await ImageUploadService.uploadProductImage(
        productBarcode: product.barcode,
        context: context,
      );

      if (imageUrl != null && product.docId != null) {
        // Update product's imageUrl in Firestore
        await _productRepository.updateDocumentField(product.docId!, 'imageUrl', imageUrl);
        
        AppNavigator.pop(); // Close loading dialog (opened in uploadProductImage)
        successDialog(
          context: context,
          title: 'Product image uploaded successfully.'
        );
      }
    } catch (error) {
      // Close loading dialog and show error
      AppNavigator.pop();
      errorDialog(
        context: context,
        title: 'Image upload failed. Please try again.',
      );
    }
  }

  Future<void> _showManualEntryModal(BuildContext context, String barcode) async {
    await ManualProductEntryModal.show(
      context: context,
      barcode: barcode,
      onSubmit: (title, brand) => _handleManualProductSubmit(context, barcode, title, brand),
      onCancel: () => _handleManualProductCancel(),
    );
  }

  Future<void> _handleManualProductSubmit(
    BuildContext context,
    String barcode,
    String title,
    String brand,
  ) async {
    loadingDialog(context: context);
    
    try {
      final Map<String, dynamic> manualProductData = {
        'title': title,
        'brand': brand,
        'description': '',
        'category': '',
        'material': '',
        'images': [],
      };
      
      await _createProductInFirestore(manualProductData, barcode);
      
      AppNavigator.pop();
      successDialog(
        context: context,
        title: 'Product added successfully!',
        onConfirm: () => AppNavigator.pop(),
      );
    } catch (error) {
      AppNavigator.pop();
      errorDialog(
        context: context,
        title: 'Failed to add product: $error',
        onConfirm: () {
          AppNavigator.pop();
          AppNavigator.navigateTo(page: CustomNavBar());
        },
      );
    }
  }

  void _handleManualProductCancel() {
    AppNavigator.pop(); // Close the manual entry modal
    AppNavigator.pop(); // Pop to Reycle Page
  }
}
