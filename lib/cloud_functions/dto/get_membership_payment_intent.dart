import '../../global_helpers/index.dart';
import 'index.dart';

class GetMembershipPaymentIntentPayload implements APIPayload {
  final String clubId;
  static final endpoint = 'getMembershipPaymentIntent';

  GetMembershipPaymentIntentPayload({required this.clubId});

  @override
  Map<String, dynamic> toJson() {
    return {
      'clubId': clubId,
    };
  }

  @override
  String toString() {
    return 'GetPaymentIntentPayload{clubId: $clubId';
  }
}

// * ===========  Response  ===========

class GetMembershipPaymentIntentResponse {
  final ResponseStatus responseStatus;
  final GetMembershipPaymentIntentResponseData data;

  GetMembershipPaymentIntentResponse({
    required this.data,
    required this.responseStatus,
  });

  factory GetMembershipPaymentIntentResponse.fromJson(Map<String, dynamic> map) {
    try {
      final dataRaw = map[ResponseFields.data.name];
      final responseStatusRaw = map[ResponseFields.responseStatus.name];
      return GetMembershipPaymentIntentResponse(
        data: GetMembershipPaymentIntentResponseData.fromJson(dataRaw),
        responseStatus: ResponseStatus.fromJson(responseStatusRaw),
      );
    } catch (e) {
      throw Exception('Error parsing GetMembershipPaymentIntentResponse: $e \n\n $map');
    }
  }
}

// * ===========  Data  ===========
class GetMembershipPaymentIntentResponseData {
  final String clientSecret;
  final String clubStripeAccountId;

  GetMembershipPaymentIntentResponseData({
    required this.clientSecret,
    required this.clubStripeAccountId,
  });

  factory GetMembershipPaymentIntentResponseData.fromJson(Map<dynamic, dynamic> map) {
    return GetMembershipPaymentIntentResponseData(
      clientSecret: map[GetMembershipPaymentIntentResponseDataFields.clientSecret.name],
      clubStripeAccountId: map[GetMembershipPaymentIntentResponseDataFields.clubStripeAccountId.name],
    );
  }

  @override
  String toString() {
    return 'GetMembershipPaymentIntentResponseData{clientSecret: $clientSecret, clubStripeAccountId: $clubStripeAccountId}';
  }
}

// * ===========  Fields  ===========
enum GetMembershipPaymentIntentResponseDataFields {
  clientSecret,
  clubStripeAccountId,
}
