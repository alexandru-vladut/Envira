import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';
import 'package:flutter_app_base/modules/custom_app_bar.dart';

class ProductNotFoundPage extends StatelessWidget {
  final String barcode;

  const ProductNotFoundPage({
    super.key,
    required this.barcode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.white,
      appBar: CustomAppBar(title: ''),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 0, left: 24, right: 24, bottom: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration
              SizedBox(
                height: 250,
                child: Image.asset(
                  'assets/images/not_found.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              
              // Content card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Product Not Found',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: CustomTheme.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'The scanned product is not in our database.',
                      style: TextStyle(
                        fontSize: 16,
                        color: CustomTheme.grey600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    
                    // Barcode info
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: CustomTheme.grey100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CustomTheme.grey200,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 24,
                            color: CustomTheme.grey600,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            barcode,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: CustomTheme.grey800,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // Actions
                    ElevatedButton.icon(
                      onPressed: () => productService.searchAndCreateProduct(context, barcode),
                      icon: const Icon(Icons.search),
                      label: const Text('Search the Web'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomTheme.primaryGreen,
                        foregroundColor: CustomTheme.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => AppNavigator.pop(context: context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                      style: TextButton.styleFrom(
                        foregroundColor: CustomTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
