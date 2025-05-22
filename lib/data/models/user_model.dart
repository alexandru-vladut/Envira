import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  
  final String? docId; // may be null, documentId from Firestore Collection (null when creating instance)
  final String uid;
  final String name;
  final String email;
  final String? pin; // may be null, initialized with null on register
  final int totalPoints;
  final String companyId;
  final String role;
  
  UserModel({
    this.docId,
    required this.uid,
    required this.name,
    required this.email,
    required this.pin,
    required this.totalPoints,
    required this.companyId,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "pin": pin,
      "totalPoints": totalPoints,
      "companyId": companyId,
      "role": role,
    };
  }

  factory UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final rawData = doc.data();

    if (rawData == null) {
      throw Exception('doc.data() is null for docId ${doc.id}, cannot convert to UserModel.');
    }

    try {
      Map data = rawData as Map<String, dynamic>;

      return UserModel(
        docId: doc.id,
        uid: data["uid"],
        name: data["name"],
        email: data["email"],
        pin: data["pin"],
        totalPoints: data["totalPoints"],
        companyId: data["companyId"],
        role: data["role"],
      );
    } catch (e) {
      throw Exception('Error converting document snapshot fields to UserModel fields: $e');
    }
  }
}
