import 'package:flutter/material.dart';
import 'package:flutter_app_base/app/app_navigator.dart';
import 'package:flutter_app_base/presentation/screens/placeholder_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

Future<void> scanBarcode(BuildContext context) async {
  final result = await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => _BarcodeScannerPage(
        onBarcodeDetected: (String barcode) {
          Navigator.of(context).pop(barcode);
        },
      ),
    ),
  );

  if (result != null) {
    String barcodeScanRes = result;
    
    if (barcodeScanRes == '59489184' || barcodeScanRes == '59492573') {
      AppNavigator.navigateTo(page: PlaceholderPage());
      // AppNavigator.navigateTo(page: ScanProductResultPage(barcode: barcodeScanRes));
    } else {
      scanBarcode(context);
    }
  }
}

// Add this helper widget class
class _BarcodeScannerPage extends StatefulWidget {
  final Function(String) onBarcodeDetected;

  const _BarcodeScannerPage({required this.onBarcodeDetected});

  @override
  State<_BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<_BarcodeScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanned = false;
  bool isFlashOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            color: Colors.white,
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: isFlashOn ? Colors.yellow : Colors.grey,
            ),
            iconSize: 32.0,
            onPressed: () async {
              await cameraController.toggleTorch();
              setState(() {
                isFlashOn = !isFlashOn;
              });
            },
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          if (!isScanned) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
              isScanned = true;
              widget.onBarcodeDetected(barcodes.first.rawValue!);
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
