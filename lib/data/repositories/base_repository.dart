import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_base/core/global_instances.dart';

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
      logger.e("[ERROR - getAllDocuments()] Error getting all documents from collection $collectionName: ${error.toString()}");
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
      logger.e("[ERROR - getDocumentsByField()] Error getting documents with $fieldName equal to $value from collection $collectionName: ${error.toString()}");
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

  Future<void> deleteDocument(String docId) async {
    try {
      DocumentReference docRef = firestore.collection(collectionName).doc(docId);
      await docRef.delete();
    } catch (error) {
      logger.e("[ERROR - deleteDocument()] Error deleting document with ID $docId from collection $collectionName: $error");
    }
  }

  Future<void> deleteAllDocuments() async {
    try {
      QuerySnapshot querySnapshot = await firestore.collection(collectionName).get();
      
      if (querySnapshot.docs.isEmpty) {
        logger.w("[WARNING - deleteAllDocuments()] No documents found to delete in collection $collectionName.");
        return;
      }

      WriteBatch batch = firestore.batch();
      
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      
      logger.i("[INFO - deleteAllDocuments()] Successfully deleted ${querySnapshot.docs.length} documents from collection $collectionName.");
    } catch (error) {
      logger.e("[ERROR - deleteAllDocuments()] Error deleting all documents from collection $collectionName: $error");
    }
  }

  Stream<List<T>> getDocumentsStream({String? fieldName, String? value}) {
    try {
      Stream<QuerySnapshot<Map<String, dynamic>>> snapshotsRef;

      if (fieldName == null) {
        snapshotsRef = firestore.collection(collectionName).snapshots();
      } else {
        snapshotsRef = firestore.collection(collectionName).where(fieldName, isEqualTo: value).snapshots();
      }

      // Listen to the snapshots and transform them
      return snapshotsRef.map((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs.map((doc) => fromDocumentSnapshot(doc)).toList();
        }

        // Return an empty list if no documents are found
        logger.w('[WARNING - getDocumentsStream()] No documents found in collection $collectionName.');
        return <T>[];
      }).handleError((error) {
        // Log Firestore stream errors
        logger.e('[ERROR - getDocumentsStream()] Error fetching documents in collection $collectionName: ${error.toString()}');
        return <T>[]; // Return an empty list on error
      });
    } catch (error) {
      // If an error occurs outside the stream, return an error stream
      logger.e('[ERROR - getDocumentsStream()] Error getting documents stream from collection $collectionName: ${error.toString()}');
      return Stream.error('[ERROR - getDocumentsStream()] Error getting documents stream from collection $collectionName: ${error.toString()}');
    }
  }
}
