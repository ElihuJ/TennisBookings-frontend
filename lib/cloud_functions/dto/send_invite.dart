import 'shared/index.dart';

class SendInvitePayload extends BasicBookingPayload {
  static final endpoint = 'sendInvite';

  final BasicBookingPayload payload;

  SendInvitePayload({
    required this.payload,
  }) : super(
          bookingId: payload.bookingId,
          clubId: payload.clubId,
          courtId: payload.courtId,
        );
}

// * ===========  Response  ===========

class SendInviteResponse extends BasicResponse {
  final BasicResponse response;

  SendInviteResponse({
    required this.response,
  }) : super(data: response.data, responseStatus: response.responseStatus);

  factory SendInviteResponse.fromJson(Map<String, dynamic> map) {
    try {
      final response = BasicResponse.fromJson(map);
      return SendInviteResponse(response: response);
    } catch (e) {
      throw Exception('Error parsing SendInviteResponse: $e \n\n $map');
    }
  }
}
