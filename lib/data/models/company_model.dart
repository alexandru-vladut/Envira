import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyModel {
  final String? docId;
  final int goalPoints;
  final dynamic goalCreatedTimestamp;
  final dynamic goalDeadlineTimestamp;

  CompanyModel({
    this.docId,
    required this.goalPoints,
    required this.goalCreatedTimestamp,
    required this.goalDeadlineTimestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'goalPoints': goalPoints,
      'goalCreatedTimestamp': goalCreatedTimestamp,
      'goalDeadlineTimestamp': goalDeadlineTimestamp,
    };
  }

  factory CompanyModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final rawData = doc.data();

    if (rawData == null) {
      throw Exception(
        'doc.data() is null for docId ${doc.id}, cannot convert to CompanyModel.',
      );
    }

    try {
      Map data = rawData as Map<String, dynamic>;

      return CompanyModel(
        docId: doc.id,
        goalPoints: data['goalPoints'],
        goalCreatedTimestamp: data['goalCreatedTimestamp'],
        goalDeadlineTimestamp: data['goalDeadlineTimestamp'],
      );
    } catch (e) {
      throw Exception(
        'Error converting document snapshot fields to CompanyModel fields: $e',
      );
    }
  }
}
