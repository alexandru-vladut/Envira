import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {

  final String? docId;
  final int value;
  final String userUid;
  final dynamic timestamp;
  final String type;

  TransactionModel({
    this.docId,
    required this.value,
    required this.userUid,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'userUid': userUid,
      'timestamp': timestamp,
      'type': type,
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
        type: data['type'],
      );
    } catch (e) {
      throw Exception('Error converting document snapshot fields to TransacionModel fields: $e');
    }
  }
}