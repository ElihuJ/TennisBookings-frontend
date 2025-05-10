import '../../global_helpers/index.dart';
import 'index.dart';

class GetPaymentIntentPayload implements APIPayload {
  final String clubId;
  final IntentType intentType;
  static final endpoint = 'getPaymentIntent';

  GetPaymentIntentPayload({required this.clubId, required this.intentType});

  @override
  Map<String, dynamic> toJson() {
    return {
      'clubId': clubId,
      'intentType': intentType.value,
    };
  }

  @override
  String toString() {
    return 'GetPaymentIntentPayload{clubId: $clubId, intentType: $intentType}';
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
  final IntentType intentType;

  GetPaymentIntentResponseData({
    required this.clientSecret,
    required this.intentType,
  });

  factory GetPaymentIntentResponseData.fromJson(Map<dynamic, dynamic> map) {
    return GetPaymentIntentResponseData(
      clientSecret: map[GetPaymentIntentResponseDataFields.clientSecret.name],
      intentType: IntentType.values.firstWhere(
        (e) => e.value == map[GetPaymentIntentResponseDataFields.clientSecret.name],
        orElse: () => IntentType.casualFee,
      ),
    );
  }

  @override
  String toString() {
    return 'GetPaymentIntentResponseData{clientSecret: $clientSecret, intentType: $intentType}';
  }
}

// * ===========  Fields  ===========
enum GetPaymentIntentResponseDataFields {
  clientSecret,
}

enum IntentType {
  annualMembership,
  casualFee;

  String get value {
    switch (this) {
      case IntentType.annualMembership:
        return 'annualMembership';
      case IntentType.casualFee:
        return 'casualFee';
    }
  }
}
