import 'package:flutter_app_base/data/models/company_model.dart';
import 'package:flutter_app_base/data/repositories/base_repository.dart';

class CompanyRepository extends BaseRepository<CompanyModel> {
  CompanyRepository()
      : super(
          collectionName: "companies",
          fromDocumentSnapshot: (doc) => CompanyModel.fromDocumentSnapshot(doc),
          toMap: (company) => company.toMap(),
        );
}
