import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_base/data/models/card_model.dart';

class UserModel {
  
  final String? docId; // may be null, documentId from Firestore Collection (null when creating instance)
  final String uid;
  final String name;
  final String email;
  final String? pin; // may be null, initialized with null on register

  final List<String> friends;
  final List<Map<String, String>> tickets;
  final Map<String, List<String>> preferences;
  final Map<String, int> feelings;

  final List<CardModel> creditCards;
  final CardModel? ecoCard; // may be null, initialized with null on register
  
  UserModel({
    this.docId,
    required this.uid,
    required this.name,
    required this.email,
    required this.pin,
    required this.friends,
    required this.tickets,
    required this.preferences,
    required this.feelings,
    required this.creditCards,
    this.ecoCard
  });

  // Convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "email": email,
      "pin": pin,
      "friends": friends,
      "tickets": tickets,
      "preferences": preferences,
      "feelings": feelings,
      "creditCards": creditCards.map((e) => e.toMap()).toList(),
      "ecoCard": (ecoCard != null) ? ecoCard!.toMap() : null
    };
  }

  // Factory method to create a UserModel from Firestore document snapshot
  factory UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    
    Map data = doc.data()! as Map<String, dynamic>;

    List<String> friends = (data["friends"] as List<dynamic>).map((e) => e.toString()).toList();
    List<Map<String, String>> tickets = (data["tickets"] as List<dynamic>).map((e) => (e as Map<dynamic, dynamic>).map((key, value) => MapEntry(key.toString(), value.toString())).cast<String, String>()).toList();
    Map<String, List<String>> preferences = (data["preferences"] as Map<dynamic, dynamic>).map((key, value) => MapEntry(key.toString(), (value as List<dynamic>).map((e) => e.toString()).toList()));
    Map<String, int> feelings = (data["feelings"] as Map<dynamic, dynamic>).map((key, value) => MapEntry(key.toString(), value as int));

    List<Map<String, dynamic>> creditCardsAsMaps = (data["creditCards"] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();

    return UserModel(
      docId: doc.id,
      uid: data["uid"],
      name: data["name"],
      email: data["email"],
      pin: data["pin"],

      friends: friends,
      tickets: tickets,
      preferences: preferences,
      feelings: feelings,
      
      creditCards: creditCardsAsMaps.map((e) => CardModel.fromMap(e)).toList(),
      ecoCard: CardModel.fromMap(data["ecoCard"])
    );
  }
}
