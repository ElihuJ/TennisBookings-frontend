import 'shared/index.dart';

class WithdrawFromBookingPayload extends BasicBookingPayload {
  static final endpoint = 'withdrawFromBooking';

  final BasicBookingPayload payload;

  WithdrawFromBookingPayload({
    required this.payload,
  }) : super(
          bookingId: payload.bookingId,
          clubId: payload.clubId,
          courtId: payload.courtId,
        );
}

// * ===========  Response  ===========

class WithdrawFromBookingResponse extends BasicResponse {
  final BasicResponse response;

  WithdrawFromBookingResponse({
    required this.response,
  }) : super(data: response.data, responseStatus: response.responseStatus);

  factory WithdrawFromBookingResponse.fromJson(Map<String, dynamic> map) {
    try {
      final response = BasicResponse.fromJson(map);
      return WithdrawFromBookingResponse(response: response);
    } catch (e) {
      throw Exception('Error parsing WithdrawFromBookingResponse: $e \n\n $map');
    }
  }
}
