import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// Animated scanning line
class ScanningLineAnimation extends StatefulWidget {
  final double scanArea;
  final Color color;
  
  const ScanningLineAnimation({
    super.key,
    required this.scanArea,
    required this.color,
  });

  @override
  State<ScanningLineAnimation> createState() => _ScanningLineAnimationState();
}

class _ScanningLineAnimationState extends State<ScanningLineAnimation> 
  with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0, end: widget.scanArea).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: _animation.value,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.5),
                  blurRadius: 8.0,
                  spreadRadius: 2.0,
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  widget.color.withOpacity(0.2),
                  widget.color,
                  widget.color.withOpacity(0.2),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

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
      // appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // Scanner
          MobileScanner(
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
          
          // Overlay
          _buildScannerOverlay(context),
          
          // Bottom guidance panel
          _buildBottomPanel(),
        ],
      ),
    );
  }
  
  Widget _buildScannerOverlay(BuildContext context) {
    // Get the screen size
    final size = MediaQuery.of(context).size;
    
    // Calculate scanner area (centered square)
    final scanArea = size.width * 0.7;
    final scanAreaTop = (size.height - scanArea) / 2.5; // Position slightly higher than center
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.5),
      child: Stack(
        children: [
          // Cut-out for scanner area
          Positioned(
            left: (size.width - scanArea) / 2,
            top: scanAreaTop,
            child: Container(
              width: scanArea,
              height: scanArea,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: CustomTheme.primaryGreen,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Scanning animation line
                  _buildScanningAnimation(scanArea),
                ],
              ),
            ),
          ),
          
          // Instruction text above the scanner
          Positioned(
            left: 0,
            right: 0,
            top: scanAreaTop - 60,
            child: const Text(
              "Position barcode inside the frame",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildScanningAnimation(double scanArea) {
    return ScanningLineAnimation(
      scanArea: scanArea,
      color: CustomTheme.primaryGreen,
    );
  }
  
  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: CustomTheme.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title and flashlight control
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Scan Product Barcode",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CustomTheme.black87,
                  ),
                ),
                _buildFlashlightButton(),
              ],
            ),
            const SizedBox(height: 8),
            // Instructions
            Text(
              "Align the barcode within the frame to scan",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: CustomTheme.grey600,
              ),
            ),
            const SizedBox(height: 16),
            // Tip container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: CustomTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    color: CustomTheme.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Ensure good lighting for best results or use the flashlight for low light conditions.",
                      style: TextStyle(
                        fontSize: 13,
                        color: CustomTheme.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFlashlightButton() {
    return GestureDetector(
      onTap: () async {
        await cameraController.toggleTorch();
        setState(() {
          isFlashOn = !isFlashOn;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isFlashOn 
              ? CustomTheme.primaryGreen.withOpacity(0.2) 
              : CustomTheme.grey200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: isFlashOn ? CustomTheme.primaryGreen : CustomTheme.grey600,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              isFlashOn ? "On" : "Off",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isFlashOn ? CustomTheme.primaryGreen : CustomTheme.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
