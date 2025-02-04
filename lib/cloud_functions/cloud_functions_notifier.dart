import 'package:cloud_functions/cloud_functions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../config/config.dart';
import '../../strings/firebase/index.dart';
import '../global_helpers/index.dart';
import '../global_types/index.dart';
import '../models/index.dart';
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
      final response = CreateBookingResponse.fromJson(result.data);
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

  Future<CFResult<List<Booking>>> getPrivateBookings(GetPrivateBookingsPayload payload) async {
    try {
      final HttpsCallableResult result = await cloudFunctions.httpsCallable(GetPrivateBookingsPayload.endpoint).call(payload.toJson());
      final response = GetPrivateBookingsResponse.fromJson(result.data);
      if (response.responseStatus.code != ResponseCodeEnum.success.value) {
        return CFResult.internalError(errorMessage: response.responseStatus.message);
      }
      return CFResult.ok<List<Booking>>(data: response.data.bookings);
    } on FirebaseFunctionsException catch (error) {
      error.tbLogger('FirebaseFunctionsException getPrivateBookings', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    } catch (error) {
      error.tbLogger('Error getPrivateBookings', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    }
  }
}
