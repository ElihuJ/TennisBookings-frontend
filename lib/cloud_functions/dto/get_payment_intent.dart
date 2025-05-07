import '../../global_helpers/index.dart';
import 'index.dart';

class GetPaymentIntentPayload implements APIPayload {
  final String clubId;
  static final endpoint = 'getPaymentIntent';

  GetPaymentIntentPayload({
    required this.clubId,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'clubId': clubId,
    };
  }

  @override
  String toString() {
    return 'GetPaymentIntentPayload{clubId: $clubId}';
  }
}

// * ===========  Response  ===========

class GetPaymentIntentResponse {
  final ResponseStatus responseStatus;
  final GetPaymentIntentResponseData data;

  GetPaymentIntentResponse({
    required this.data,
    required this.responseStatus,
  });

  factory GetPaymentIntentResponse.fromJson(Map<String, dynamic> map) {
    try {
      final dataRaw = map[ResponseFields.data.name];
      final responseStatusRaw = map[ResponseFields.responseStatus.name];
      return GetPaymentIntentResponse(
        data: GetPaymentIntentResponseData.fromJson(dataRaw),
        responseStatus: ResponseStatus.fromJson(responseStatusRaw),
      );
    } catch (e) {
      throw Exception('Error parsing GetPaymentIntentResponse: $e \n\n $map');
    }
  }
}

// * ===========  Data  ===========
class GetPaymentIntentResponseData {
  final String clientSecret;

  GetPaymentIntentResponseData({
    required this.clientSecret,
  });

  factory GetPaymentIntentResponseData.fromJson(Map<dynamic, dynamic> map) {
    return GetPaymentIntentResponseData(
      clientSecret: map[GetPaymentIntentResponseDataFields.clientSecret.name],
    );
  }

  @override
  String toString() {
    return 'GetPaymentIntentResponseData{clientSecret: $clientSecret}';
  }
}

// * ===========  Fields  ===========
enum GetPaymentIntentResponseDataFields {
  clientSecret,
}
