import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/utils/dialog_widgets/dialog_widgets.dart';
import 'package:flutter_app_base/modules/recycle/widgets/image_source_selection_modal.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  static final _storage = FirebaseStorage.instance;
  static final _picker = ImagePicker();

  static Future<String?> uploadProductImage({
    required String productBarcode,
    required BuildContext context,
  }) async {
    try {
      // Show simple source selection
      final ImageSource? source = await ImageSourceSelectionModal.show(context);
      if (source == null) return null;

      // Pick image with selected source
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      loadingDialog(context: context);

      // Upload to Firebase Storage
      final String downloadUrl = await _uploadToFirebaseStorage(
        file: File(pickedFile.path),
        barcode: productBarcode,
      );

      return downloadUrl;
    } catch (e) {
      errorDialog(context: context, title: 'Image upload failed', text: e.toString());
      return null;
    }
  }

  static Future<String> _uploadToFirebaseStorage({
    required File file,
    required String barcode,
  }) async {
    // Create a unique filename
    final String fileName = 'product_${barcode}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    // Create reference to Firebase Storage
    final Reference ref = _storage.ref().child('product_images').child(fileName);
    
    // Upload file
    final UploadTask uploadTask = ref.putFile(
      file,
      SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'barcode': barcode,
          'uploaded_at': DateTime.now().toIso8601String(),
        },
      ),
    );

    // Wait for upload to complete
    final TaskSnapshot snapshot = await uploadTask;
    
    // Get download URL
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    
    return downloadUrl;
  }
}
