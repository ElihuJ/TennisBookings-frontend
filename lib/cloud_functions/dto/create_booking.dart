import '../../global_helpers/index.dart';
import '../../models/riverpod/index.dart';
import 'index.dart';

class CreateMemberBookingPayload implements APIPayload {
  final Booking booking;
  final bool isOpenBooking;
  static final endpoint = 'createMemberBooking';

  CreateMemberBookingPayload({
    required this.booking,
    required this.isOpenBooking,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'booking': booking.toJson(),
      'isOpenBooking': isOpenBooking,
    };
  }

  @override
  String toString() {
    return 'CreateBookingPayload{booking: $booking, isOpenBooking: $isOpenBooking}';
  }
}

// * ===========  Response  ===========

class CreateMemberBookingResponse {
  final ResponseStatus responseStatus;
  final CreateMemberBookingResponseData data;

  CreateMemberBookingResponse({
    required this.data,
    required this.responseStatus,
  });

  factory CreateMemberBookingResponse.fromJson(Map<String, dynamic> map) {
    try {
      final dataRaw = map[ResponseFields.data.name];
      final responseStatusRaw = map[ResponseFields.responseStatus.name];
      return CreateMemberBookingResponse(
        data: CreateMemberBookingResponseData.fromJson(dataRaw),
        responseStatus: ResponseStatus.fromJson(responseStatusRaw),
      );
    } catch (e) {
      throw Exception('Error parsing CreateBookingResponse: $e \n\n $map');
    }
  }
}

// * ===========  Data  ===========
class CreateMemberBookingResponseData {
  final String newBookingId;

  CreateMemberBookingResponseData({
    required this.newBookingId,
  }) : super();

  factory CreateMemberBookingResponseData.fromJson(Map<dynamic, dynamic> map) {
    return CreateMemberBookingResponseData(newBookingId: map[CreateMemberBookingResponseDataFields.newBookingId.name]);
  }

  @override
  String toString() {
    return 'CreateBookingResponseData{createdBookingId: $newBookingId';
  }
}

// * ===========  Fields  ===========
enum CreateMemberBookingResponseDataFields {
  newBookingId,
}
