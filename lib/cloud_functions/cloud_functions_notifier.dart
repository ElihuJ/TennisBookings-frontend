import 'package:cloud_functions/cloud_functions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../config/config.dart';
import '../../strings/firebase/index.dart';
import '../global_helpers/index.dart';
import '../global_types/index.dart';
import 'dto/index.dart';
import 'dto/responses/index.dart';
import 'index.dart';
import 'types.dart';

final FirebaseFunctions cloudFunctions = FirebaseFunctions.instanceFor(region: Config.functionsRegion);

class CloudFunctionsNotifier extends StateNotifier<CloudFunctions> {
  CloudFunctionsNotifier() : super(const CloudFunctions.empty());

  void loadUid({required String uid}) {
    state = state.copyWith(uid: uid);
  }

  Future<CFResult<Success>> createBooking(CreateBookingPayload payload) async {
    try {
      final HttpsCallableResult result = await cloudFunctions.httpsCallable(CreateBookingPayload.endpoint).call(payload.toJson());
      final response = CreateBookingResponse.fromMap(result.data);
      if (!response.data.success) {
        return CFResult.internalError(errorMessage: response.responseStatus.message);
      }
      return CFResult.ok<Success>(data: response.data.success);
    } on FirebaseFunctionsException catch (error) {
      error.tbLogger('FirebaseFunctionsException createBooking', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    } catch (error) {
      error.tbLogger('Error createBooking', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    }
  }
}
