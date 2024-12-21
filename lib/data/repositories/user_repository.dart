import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/data/repositories/base_repository.dart';

class UserRepository extends BaseRepository<UserModel> {
  UserRepository()
      : super(
          collectionName: "users",
          fromDocumentSnapshot: (doc) => UserModel.fromDocumentSnapshot(doc),
          toMap: (user) => user.toMap(),
        );
}
