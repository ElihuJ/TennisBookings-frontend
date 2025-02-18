import '../../global_helpers/index.dart';
import '../../models/riverpod/index.dart';
import 'index.dart';

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

class CreateBookingResponse {
  final ResponseStatus responseStatus;
  final CreateBookingResponseData data;

  CreateBookingResponse({
    required this.data,
    required this.responseStatus,
  });

  factory CreateBookingResponse.fromJson(Map<String, dynamic> map) {
    try {
      final dataRaw = map[ResponseFields.data.name];
      final responseStatusRaw = map[ResponseFields.responseStatus.name];
      return CreateBookingResponse(
        data: CreateBookingResponseData.fromJson(dataRaw),
        responseStatus: ResponseStatus.fromJson(responseStatusRaw),
      );
    } catch (e) {
      throw Exception('Error parsing CreateBookingResponse: $e \n\n $map');
    }
  }
}

// * ===========  Data  ===========
class CreateBookingResponseData {
  final String newBookingId;

  CreateBookingResponseData({
    required this.newBookingId,
  }) : super();

  factory CreateBookingResponseData.fromJson(Map<dynamic, dynamic> map) {
    return CreateBookingResponseData(newBookingId: map[CreateBookingResponseDataFields.newBookingId.name]);
  }

  @override
  String toString() {
    return 'CreateBookingResponseData{createdBookingId: $newBookingId';
  }
}

// * ===========  Fields  ===========
enum CreateBookingResponseDataFields {
  newBookingId,
}
