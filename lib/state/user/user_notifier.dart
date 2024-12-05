import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../helpers/index.dart';
import '../../types/index.dart';
import 'index.dart';

class UserNotifier extends StateNotifier<User> {
  UserNotifier() : super(User.empty());
  // final usersCollection = FirebaseFirestore.instance.collection(FirestoreCollection.users);
  final storageRef = FirebaseStorage.instance.ref();

  String get userId => state.uid;

  void loadUser({required String uid}) async {
    // final doc = await usersCollection.doc(uid).get();
    // if (doc.exists) {
    //   final data = doc.data() as FirestoreResponse;
    //   state = User.fromJson(data);
    // }
  }

  FirestoreActionResult<Success> createUser({String? name, required String uid, required String? email, ResultHandler? resultHandler}) async {
    final errorHandler = resultHandler ?? ResultHandler(success: true);
    try {
      final dateNowAsInt = getNowInEpoch();
    } catch (error) {
      errorHandler.handleError(
        errorMessage: 'Failed creating user', // ? TO TRANSLATE
        error: error,
      );
    }
    return errorHandler.result;
  }
}
