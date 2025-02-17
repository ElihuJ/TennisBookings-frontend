import '../../global_helpers/index.dart';
import '../../models/riverpod/index.dart';
import 'shared/basic_response.dart';

class CreateBookingPayload implements APIPayload {
  final Booking booking;
  final String clubId;
  final bool isOpenBooking;
  static final endpoint = 'createBooking';

  CreateBookingPayload({
    required this.booking,
    required this.clubId,
    required this.isOpenBooking,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'booking': booking.toJson(),
      'clubId': clubId,
      'isOpenBooking': isOpenBooking,
    };
  }
}

// * ===========  Response  ===========

class CreateBookingResponse extends BasicResponse {
  final BasicResponse response;

  CreateBookingResponse({
    required this.response,
  }) : super(data: response.data, responseStatus: response.responseStatus);

  factory CreateBookingResponse.fromJson(Map<String, dynamic> map) {
    try {
      final response = BasicResponse.fromJson(map);
      return CreateBookingResponse(response: response);
    } catch (e) {
      throw Exception('Error parsing CreateBookingResponse: $e');
    }
  }
}
