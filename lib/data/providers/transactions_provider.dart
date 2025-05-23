import 'package:flutter_app_base/data/models/transaction_model.dart';
import 'package:flutter_app_base/data/providers/base_provider.dart';
import 'package:flutter_app_base/data/repositories/transaction_repository.dart';

class TransactionsProvider extends BaseProvider<TransactionModel> {
  TransactionsProvider(TransactionRepository transactionRepository)
      : super(transactionRepository.getDocumentsStream);
}