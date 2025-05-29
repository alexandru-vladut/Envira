import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// Add this helper widget class
class BarcodeScannerPage extends StatefulWidget {
  final Function(String) onBarcodeDetected;

  const BarcodeScannerPage({super.key, required this.onBarcodeDetected});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
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
