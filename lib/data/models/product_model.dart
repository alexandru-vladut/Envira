import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String? docId;
  final String barcode;
  final String title;
  final String description;
  final String category; //
  final String brand;
  final String material; // might be determined with AI
  final String imageUrl; //

  final bool isRecyclable;
  final int points;

  ProductModel({
    this.docId,
    required this.barcode,
    required this.title,
    required this.description,
    required this.category,
    required this.brand,
    required this.material,
    required this.imageUrl,
    required this.isRecyclable,
    required this.points,
  });

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'title': title,
      'description': description,
      'category': category,
      'brand': brand,
      'material': material,
      'imageUrl': imageUrl,
      'isRecyclable': isRecyclable,
      'points': points,
    };
  }

  factory ProductModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final rawData = doc.data();

    if (rawData == null) {
      throw Exception(
        'doc.data() is null for docId ${doc.id}, cannot convert to ProductModel.',
      );
    }

    try {
      Map data = rawData as Map<String, dynamic>;

      return ProductModel(
        docId: doc.id,
        barcode: data['barcode'],
        title: data['title'],
        description: data['description'],
        category: data['category'],
        brand: data['brand'],
        material: data['material'],
        imageUrl: data['imageUrl'],
        isRecyclable: data['isRecyclable'],
        points: data['points'],
      );
    } catch (e) {
      throw Exception(
        'Error converting document snapshot fields to TransacionModel fields: $e',
      );
    }
  }
}
