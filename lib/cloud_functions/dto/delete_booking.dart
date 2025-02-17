import 'shared/index.dart';

class DeleteBookingPayload extends BasicBookingPayload {
  static final endpoint = 'deleteBooking';

  final BasicBookingPayload payload;

  DeleteBookingPayload({
    required this.payload,
  }) : super(
          bookingId: payload.bookingId,
          clubId: payload.clubId,
          courtId: payload.courtId,
        );
}

// * ===========  Response  ===========

class DeleteBookingResponse extends BasicResponse {
  final BasicResponse response;

  DeleteBookingResponse({
    required this.response,
  }) : super(data: response.data, responseStatus: response.responseStatus);

  factory DeleteBookingResponse.fromJson(Map<String, dynamic> map) {
    try {
      final response = BasicResponse.fromJson(map);
      return DeleteBookingResponse(response: response);
    } catch (e) {
      throw Exception('Error parsing CreateBookingResponse: $e');
    }
  }
}
