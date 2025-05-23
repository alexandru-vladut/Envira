import 'package:flutter_app_base/data/models/voucher_model.dart';
import 'package:flutter_app_base/data/providers/base_provider.dart';
import 'package:flutter_app_base/data/repositories/voucher_repository.dart';

class VouchersProvider extends BaseProvider<VoucherModel> {
  VouchersProvider(VoucherRepository voucherRepository)
      : super(voucherRepository.getDocumentsStream);
}