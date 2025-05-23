import 'package:flutter_app_base/data/models/company_model.dart';
import 'package:flutter_app_base/data/providers/base_provider.dart';
import 'package:flutter_app_base/data/repositories/company_repository.dart';

class CompaniesProvider extends BaseProvider<CompanyModel> {
  CompaniesProvider(CompanyRepository companyRepository)
      : super(companyRepository.getDocumentsStream);
}