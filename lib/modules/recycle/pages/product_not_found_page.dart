import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';

class ProductNotFoundPage extends StatelessWidget {
  final String barcode;

  const ProductNotFoundPage({
    super.key,
    required this.barcode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 100,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              const Text(
                'Product Not Found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'The scanned product is not in our database.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Barcode: $barcode',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement web search functionality
                  print('Search web for barcode: $barcode');
                },
                icon: const Icon(Icons.search),
                label: const Text('Search the Web'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3881E0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => AppNavigator.pop(context: context),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    color: Color(0xFF3881E0),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
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
}
