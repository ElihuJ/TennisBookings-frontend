import 'package:cloud_functions/cloud_functions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../config/config.dart';
import '../../strings/firebase/index.dart';
import '../global_helpers/index.dart';
import '../global_types/index.dart';
import '../models/index.dart';
import 'dto/delete_booking.dart';
import 'dto/get_confirmed_players.dart';
import 'dto/index.dart';
import 'dto/send_invite.dart';
import 'dto/update_profile.dart';
import 'dto/withdraw_from_booking.dart';
import 'index.dart';
import 'types.dart';

final FirebaseFunctions cloudFunctions = FirebaseFunctions.instanceFor(region: Config.functionsRegion);

class CloudFunctionsNotifier extends StateNotifier<CloudFunctions> {
  CloudFunctionsNotifier() : super(const CloudFunctions.empty());

  List<GetConfirmedPlayersDataCache> getConfirmedPlayerDataCache = [];

  void loadUid({required String uid}) {
    state = state.copyWith(uid: uid);
  }

  Future<CFResult<String>> createBooking(CreateBookingPayload payload) async {
    try {
      final HttpsCallableResult result = await cloudFunctions.httpsCallable(CreateBookingPayload.endpoint).call(payload.toJson());
      final response = CreateBookingResponse.fromJson(result.data);
      if (response.responseStatus.code != ResponseCodeEnum.success.value) {
        return CFResult.internalError(errorMessage: response.responseStatus.message);
      }
      return CFResult.ok<String>(data: response.data.newBookingId);
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

  Future<CFResult<List<ConfirmedPlayerData>>> getConfirmedPlayersData(GetConfirmedPlayersDataPayload payload) async {
    try {
      final epochInHours = (DateTime.now().millisecondsSinceEpoch / 1000 / 60 / 60).floor(); // 1 hour
      final cacheKey = '${payload.bookingId}+$epochInHours';
      final cacheHit = getConfirmedPlayerDataCache.where((element) => element.cacheKey == cacheKey);
      if (cacheHit.isNotEmpty) {
        return CFResult.ok<List<ConfirmedPlayerData>>(data: cacheHit.first.response!.data.playersData);
      }

      final HttpsCallableResult result =
          await cloudFunctions.httpsCallable(GetConfirmedPlayersDataPayload.getConfirmedPlayersDataEndpoint).call(payload.toJson());
      final response = GetConfirmedPlayersDataResponse.fromJson(result.data);
      if (response.responseStatus.code != ResponseCodeEnum.success.value) {
        return CFResult.internalError(errorMessage: response.responseStatus.message);
      }
      getConfirmedPlayerDataCache.add(GetConfirmedPlayersDataCache(payload: payload, cacheKey: cacheKey, response: response));
      return CFResult.ok<List<ConfirmedPlayerData>>(data: response.data.playersData);
    } on FirebaseFunctionsException catch (error) {
      error.tbLogger('FirebaseFunctionsException getConfirmedPlayersData', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    } catch (error) {
      error.tbLogger('Error getConfirmedPlayersData', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    }
  }

  Future<CFResult<Success>> deleteBooking(DeleteBookingPayload payload) async {
    try {
      final HttpsCallableResult result = await cloudFunctions.httpsCallable(DeleteBookingPayload.endpoint).call(payload.toJson());
      final response = DeleteBookingResponse.fromJson(result.data);
      if (response.responseStatus.code != ResponseCodeEnum.success.value) {
        return CFResult.internalError(errorMessage: response.responseStatus.message);
      }
      return CFResult.ok<Success>(data: response.data.success);
    } on FirebaseFunctionsException catch (error) {
      error.tbLogger('FirebaseFunctionsException deleteBooking', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    } catch (error) {
      error.tbLogger('Error deleteBooking', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    }
  }

  Future<CFResult<Success>> actionInvite(ActionInvitePayload payload) async {
    try {
      'Inviting player'.tbLogger('actionInvite', DebugLevel.info);
      final HttpsCallableResult result = await cloudFunctions.httpsCallable(ActionInvitePayload.endpoint).call(payload.toJson());
      final response = ActionInviteResponse.fromJson(result.data);
      response.tbLogger('actionInvite', DebugLevel.info);
      if (response.responseStatus.code != ResponseCodeEnum.success.value) {
        return CFResult.internalError(errorMessage: response.responseStatus.message);
      }
      return CFResult.ok<Success>(data: response.data.success);
    } on FirebaseFunctionsException catch (error) {
      error.tbLogger('FirebaseFunctionsException actionInvite', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    } catch (error) {
      error.tbLogger('Error actionInvite', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    }
  }

  Future<CFResult<Success>> sendInvite(SendInvitePayload payload) async {
    try {
      'Inviting player'.tbLogger('sendInvite', DebugLevel.info);
      final HttpsCallableResult result = await cloudFunctions.httpsCallable(SendInvitePayload.endpoint).call(payload.toJson());
      final response = SendInviteResponse.fromJson(result.data);
      response.tbLogger('sendInvite', DebugLevel.info);
      if (response.responseStatus.code != ResponseCodeEnum.success.value) {
        return CFResult.internalError(errorMessage: response.responseStatus.message);
      }
      return CFResult.ok<Success>(data: response.data.success);
    } on FirebaseFunctionsException catch (error) {
      error.tbLogger('FirebaseFunctionsException sendInvite', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    } catch (error) {
      error.tbLogger('Error sendInvite', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    }
  }

  Future<CFResult<Success>> withdrawFromBooking(WithdrawFromBookingPayload payload) async {
    try {
      final HttpsCallableResult result = await cloudFunctions.httpsCallable(WithdrawFromBookingPayload.endpoint).call(payload.toJson());
      final response = WithdrawFromBookingResponse.fromJson(result.data);
      response.tbLogger('sendInvite', DebugLevel.info);
      if (response.responseStatus.code != ResponseCodeEnum.success.value) {
        return CFResult.internalError(errorMessage: response.responseStatus.message);
      }
      return CFResult.ok<Success>(data: response.data.success);
    } on FirebaseFunctionsException catch (error) {
      error.tbLogger('FirebaseFunctionsException sendInvite', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    } catch (error) {
      error.tbLogger('Error sendInvite', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    }
  }

  Future<CFResult<Success>> updateProfile(UpdateProfilePayload payload) async {
    try {
      final HttpsCallableResult result = await cloudFunctions.httpsCallable(UpdateProfilePayload.endpoint).call(payload.toJson());
      final response = UpdateProfileResponse.fromJson(result.data);
      response.tbLogger('updateProfile', DebugLevel.info);
      if (response.responseStatus.code != ResponseCodeEnum.success.value) {
        return CFResult.internalError(errorMessage: response.responseStatus.message);
      }
      return CFResult.ok<Success>(data: response.data.success);
    } on FirebaseFunctionsException catch (error) {
      error.tbLogger('FirebaseFunctionsException updateProfile', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    } catch (error) {
      error.tbLogger('Error updateProfile', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    }
  }

  Future<CFResult<List<BookingWithPopulatedRequest>>> getActiveOpenBookings() async {
    try {
      final HttpsCallableResult result = await cloudFunctions.httpsCallable(GetActiveOpenBookingsPayload.endpoint).call();
      final response = GetActiveOpenBookingsResponse.fromJson(result.data);
      if (response.responseStatus.code != ResponseCodeEnum.success.value) {
        return CFResult.internalError(errorMessage: response.responseStatus.message);
      }
      return CFResult.ok<List<BookingWithPopulatedRequest>>(data: response.data.bookings);
    } on FirebaseFunctionsException catch (error) {
      error.tbLogger('FirebaseFunctionsException getActiveOpenBookings', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    } catch (error) {
      error.tbLogger('Error getActiveOpenBookings', DebugLevel.error);
      return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
    }
  }
}
