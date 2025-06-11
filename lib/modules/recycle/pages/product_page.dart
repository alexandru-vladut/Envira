import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/data/models/product_model.dart';
import 'package:flutter_app_base/modules/custom_app_bar.dart';
import 'package:flutter_app_base/modules/recycle/pages/product_not_found_page.dart';
import 'package:flutter_app_base/modules/recycle/providers/product_data_provider.dart';

class ProductPage extends StatefulWidget {
  final String barcode;

  const ProductPage({super.key, required this.barcode});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  bool showReasoning = false;

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
    final recyclableColor = CustomTheme.primaryGreen;
    final nonRecyclableColor = const Color(0xFFE94F37); // Vibrant red for non-recyclable
    final accentColor = product.isRecyclable ? recyclableColor : nonRecyclableColor;
    
    return Scaffold(
      backgroundColor: CustomTheme.white,
      appBar: CustomAppBar(title: 'Product Details'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image section with status indicator
            Stack(
              children: [
                // Image container
                _buildProductImageSection(product, accentColor),
                
                // Recyclability badge
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: product.isRecyclable 
                          ? recyclableColor.withOpacity(0.9)
                          : nonRecyclableColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          product.isRecyclable ? Icons.check_circle : Icons.do_not_disturb,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          product.isRecyclable ? 'Recyclable' : 'Not Recyclable',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Product info cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and basic info
                  _buildTitleSection(product, accentColor),
                  const SizedBox(height: 24),
                  
                  // Points and action card
                  _buildPointsCard(product, accentColor),
                  const SizedBox(height: 24),
                  
                  // Product details card
                  _buildDetailsCard(product, accentColor),
                  const SizedBox(height: 24),
                  
                  // Reasoning section
                  _buildReasoningSection(product, accentColor),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProductImageSection(ProductModel product, Color accentColor) {
    if (product.imageUrl.isNotEmpty) {
      return Container(
        width: double.infinity,
        height: 280,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Image.network(
          product.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                color: accentColor,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Image failed to load',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else {
      // No image available
      return Container(
        width: double.infinity,
        height: 280,
        color: Colors.grey[100],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No product image available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Help by adding a photo of this product',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await productService.uploadProductImage(
                  context: context,
                  product: product,
                );
              },
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Upload Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTitleSection(ProductModel product, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product title
        Text(
          product.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CustomTheme.black87,
          ),
        ),
        const SizedBox(height: 10),
        
        // Brand
        Row(
          children: [
            Icon(Icons.business, size: 16, color: accentColor),
            const SizedBox(width: 8),
            Text(
              product.brand,
              style: TextStyle(
                fontSize: 16,
                color: CustomTheme.grey800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildPointsCard(ProductModel product, Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Points information
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.eco,
                    color: accentColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    product.points == 1 ? '1 Point' : '${product.points} Points',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
              if (product.isRecyclable)
                ElevatedButton.icon(
                  onPressed: () => recycleService.recycleProduct(context, product),
                  icon: const Icon(Icons.recycling),
                  label: const Text('Recycle Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: accentColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: CustomTheme.black87,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailsCard(ProductModel product, Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomTheme.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          const Text(
            'Product Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CustomTheme.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Description
          _buildDetailRow('Description', product.description, accentColor),
          const Divider(height: 24),
          
          // Category
          _buildDetailRow('Category', product.category, accentColor),
          const Divider(height: 24),
          
          // Material
          _buildDetailRow('Material', product.material, accentColor),
        ],
      ),
    );
  }
  
  Widget _buildReasoningSection(ProductModel product, Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CustomTheme.grey100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          GestureDetector(
            onTap: () {
              setState(() {
                showReasoning = !showReasoning;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Why is this ${product.isRecyclable ? '' : 'not '}recyclable?',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CustomTheme.black87,
                  ),
                ),
                Icon(
                  showReasoning ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: CustomTheme.grey600,
                ),
              ],
            ),
          ),
          
          // Reasoning content
          if (showReasoning) ...[
            const SizedBox(height: 16),
            Text(
              product.reasoning,
              style: const TextStyle(
                fontSize: 14,
                color: CustomTheme.grey800,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
