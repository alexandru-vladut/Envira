import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/data/providers/base_provider.dart';
import 'package:flutter_app_base/data/repositories/user_repository.dart';

class UserProvider extends BaseProvider<UserModel> {
  UserProvider(UserRepository userRepository)
      : super(userRepository.getDocumentsStream);
}