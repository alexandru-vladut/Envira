import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {

  final String? docId;
  final int cost;
  final String description;
  final String name;
  final String partner;

  VoucherModel({
    this.docId,
    required this.cost,
    required this.description,
    required this.name,
    required this.partner,
  });

  Map<String, dynamic> toMap() {
    return {
      'cost': cost,
      'description': description,
      'name': name,
      'partner': partner,
    };
  }

  factory VoucherModel.fromMap(DocumentSnapshot doc) {
    final rawData = doc.data();

    if (rawData == null) {
      throw Exception('doc.data() is null for docId ${doc.id}, cannot convert to VoucherModel.');
    }

    try {
      Map data = rawData as Map<String, dynamic>;

      return VoucherModel(
        docId: doc.id,
        cost: data['cost'],
        description: data['description'],
        name: data['name'],
        partner: data['partner'],
      );
    } catch (e) {
      throw Exception('Error converting document snapshot fields to VoucherModel fields: $e');
    }
  }
}