import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_base/utils/globals.dart';

abstract class BaseRepository<T> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String collectionName;
  final T Function(DocumentSnapshot doc) fromDocumentSnapshot;
  final Map<String, dynamic> Function(T entity) toMap;

  BaseRepository({
    required this.collectionName,
    required this.fromDocumentSnapshot,
    required this.toMap,
  });

  Future<List<T>> getAllDocuments() async {
    try {
      QuerySnapshot querySnapshot = await firestore.collection(collectionName).get();

      return querySnapshot.docs.map((doc) => fromDocumentSnapshot(doc)).toList();
    } catch (error) {
      logger.e("[ERROR - getAllDocuments()] Error getting all documents from collection $collectionName: $error");
      return [];
    }
  }

  Future<List<T>> getDocumentsByField(String fieldName, dynamic value) async {

    if (value is! String) {
      logger.w("[WARNING - getDocumentsByField()] Parameter value is of type ${value.runtimeType}, not String, so results may not be as expected.");
    }

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection(collectionName)
          .where(fieldName, isEqualTo: value)
          .get();

      if (querySnapshot.docs.isEmpty) {
        logger.w("[WARNING - getDocumentsByField()] No documents with $fieldName equal to $value found in collection $collectionName.");
        return [];
      }

      return querySnapshot.docs.map((doc) => fromDocumentSnapshot(doc)).toList();
    } catch (error) {
      logger.e("[ERROR - getDocumentsByField()] Error getting documents with $fieldName equal to $value from collection $collectionName: $error");
      return [];
    }
  }

  Future<void> addDocument(T entity) async {
    try {
      await firestore.collection(collectionName).add(toMap(entity));
    } catch (error) {
      logger.e("[ERROR - addDocument()] Error adding document in collection $collectionName: $error");
    }
  }

  Future<void> updateDocumentField(String docId, String fieldName, dynamic newValue) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance.collection(collectionName).doc(docId);
      await docRef.update({fieldName: newValue});
    } catch (error) {
      logger.e("[ERROR - updateDocumentField()] Error updating field $fieldName with new value $newValue in collection $collectionName: $error");
    }
  }

}
