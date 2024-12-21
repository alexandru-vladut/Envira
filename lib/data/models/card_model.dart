class CardModel {

  final String cvv;
  final String name;
  final String number;
  final String expirationDate;
  final String type;
  final bool isDefault;
  final int style;
  final bool freezed;
  final dynamic timestamp;

  CardModel({
    required this.cvv,
    required this.name,
    required this.number,
    required this.expirationDate,
    required this.type,
    required this.isDefault,
    required this.style,
    required this.freezed,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      "cvv": cvv,
      "name": name,
      "number": number,
      "expirationDate": expirationDate,
      "type": type,
      "isDefault": isDefault,
      "style": style,
      "freezed": freezed,
      "timestamp": timestamp,
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> cardMap) {

    return CardModel(
      cvv: cardMap["cvv"],
      name: cardMap["name"],
      number: cardMap["number"],
      expirationDate: cardMap["expirationDate"],
      type: cardMap["type"],
      isDefault: cardMap["isDefault"],
      style: cardMap["style"],
      freezed: cardMap["freezed"],
      timestamp: cardMap["timestamp"],
    );
  }
}