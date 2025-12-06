import 'package:tennisbookings/global_types/enums.dart';

import '../../global_helpers/index.dart';
import 'index.dart';

class GetCasualPaymentIntentPayload implements APIPayload {
  final String clubId;
  final String courtId;
  final BookingFormat format;
  final bool private;
  final String title;
  final int startTime;
  final int endTime;
  static final String endpoint = 'getCasualBookingPaymentIntent';

  GetCasualPaymentIntentPayload({
    required this.clubId,
    required this.courtId,
    required this.format,
    required this.private,
    required this.title,
    required this.startTime,
    required this.endTime,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'clubId': clubId,
      'courtId': courtId,
      'format': format.name,
      'private': private,
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  @override
  String toString() {
    return 'GetCasualPaymentIntentPayload{clubId: $clubId, courtId: $courtId, format: $format, private: $private, title: $title, startTime: $startTime, endTime: $endTime}';
  }
}

// * ===========  Response  ===========

class GetCasualPaymentIntentResponse {
  final ResponseStatus responseStatus;
  final GetCasualPaymentIntentResponseData data;

  GetCasualPaymentIntentResponse({
    required this.data,
    required this.responseStatus,
  });

  factory GetCasualPaymentIntentResponse.fromJson(Map<String, dynamic> map) {
    try {
      final dataRaw = map[ResponseFields.data.name];
      final responseStatusRaw = map[ResponseFields.responseStatus.name];
      return GetCasualPaymentIntentResponse(
        data: GetCasualPaymentIntentResponseData.fromJson(dataRaw),
        responseStatus: ResponseStatus.fromJson(responseStatusRaw),
      );
    } catch (e) {
      throw Exception('Error parsing GetCasualPaymentIntentResponse: $e \n\n $map');
    }
  }
}

// * ===========  Data  ===========
class GetCasualPaymentIntentResponseData {
  final String clientSecret;
  final String clubStripeAccountId;

  GetCasualPaymentIntentResponseData({
    required this.clientSecret,
    required this.clubStripeAccountId,
  });

  factory GetCasualPaymentIntentResponseData.fromJson(Map<dynamic, dynamic> map) {
    return GetCasualPaymentIntentResponseData(
      clientSecret: map[GetCasualPaymentIntentResponseDataFields.clientSecret.name],
      clubStripeAccountId: map[GetCasualPaymentIntentResponseDataFields.clubStripeAccountId.name],
    );
  }

  @override
  String toString() {
    return 'GetCasualPaymentIntentResponseData{clientSecret: $clientSecret}';
  }
}

// * ===========  Fields  ===========
enum GetCasualPaymentIntentResponseDataFields {
  clientSecret,
  clubStripeAccountId,
}
