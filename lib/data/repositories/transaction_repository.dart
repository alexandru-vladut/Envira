import 'package:flutter_app_base/data/models/transaction_model.dart';
import 'package:flutter_app_base/data/repositories/base_repository.dart';

class TransactionRepository extends BaseRepository<TransactionModel> {
  TransactionRepository()
      : super(
          collectionName: "transactions",
          fromDocumentSnapshot: (doc) => TransactionModel.fromDocumentSnapshot(doc),
          toMap: (transaction) => transaction.toMap(),
        );
}
