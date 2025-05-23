import 'package:flutter_app_base/data/models/voucher_model.dart';
import 'package:flutter_app_base/data/repositories/base_repository.dart';

class VoucherRepository extends BaseRepository<VoucherModel> {
  VoucherRepository()
      : super(
          collectionName: "vouchers",
          fromDocumentSnapshot: (doc) => VoucherModel.fromDocumentSnapshot(doc),
          toMap: (voucher) => voucher.toMap(),
        );
}
