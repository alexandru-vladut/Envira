import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {

  final String? docId;
  final int value;
  final String userUid;
  final dynamic timestamp;

  TransactionModel({
    this.docId,
    required this.value,
    required this.userUid,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'userUid': userUid,
      'timestamp': timestamp,
    };
  }

  factory TransactionModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final rawData = doc.data();

    if (rawData == null) {
      throw Exception('doc.data() is null for docId ${doc.id}, cannot convert to TransactionModel.');
    }

    try {
      Map data = rawData as Map<String, dynamic>;

      return TransactionModel(
        docId: doc.id,
        value: data['value'],
        userUid: data['userUid'],
        timestamp: data['timestamp'],
      );
    } catch (e) {
      throw Exception('Error converting document snapshot fields to TransacionModel fields: $e');
    }
  }
}