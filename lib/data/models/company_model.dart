import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyModel {

  final String? docId;
  final int pointsGoal;

  CompanyModel({
    this.docId,
    required this.pointsGoal,
  });

  Map<String, dynamic> toMap() {
    return {
      'pointsGoal': pointsGoal,
    };
  }

  factory CompanyModel.fromMap(DocumentSnapshot doc) {
    final rawData = doc.data();

    if (rawData == null) {
      throw Exception('doc.data() is null for docId ${doc.id}, cannot convert to CompanyModel.');
    }

    try {
      Map data = rawData as Map<String, dynamic>;

      return CompanyModel(
        docId: doc.id,
        pointsGoal: data['pointsGoal'],
      );
    } catch (e) {
      throw Exception('Error converting document snapshot fields to CompanyModel fields: $e');
    }
  }
}