import '../../../models/index.dart';
import 'index.dart';

class GetPrivateBookingsResponse {
  final GetPrivateBookingsResponseData data;
  final ResponseStatus responseStatus;

  GetPrivateBookingsResponse({
    required this.data,
    required this.responseStatus,
  }) : super();

  factory GetPrivateBookingsResponse.fromMap(Map<String, dynamic> map) {
    try {
      final dataRaw = map[ResponseFields.data.name];
      final responseStatusRaw = map[ResponseFields.responseStatus.name];

      ResponseStatus responseStatus = ResponseStatus.fromMap(responseStatusRaw);
      GetPrivateBookingsResponseData data = GetPrivateBookingsResponseData.fromMap(dataRaw);

      return GetPrivateBookingsResponse(
        data: data,
        responseStatus: responseStatus,
      );
    } catch (e) {
      if (map.containsKey(ResponseFields.responseStatus.name)) {
        final responseStatusRaw = map[ResponseFields.responseStatus.name];
        ResponseStatus responseStatus = ResponseStatus.fromMap(responseStatusRaw);
        return GetPrivateBookingsResponse(
          data: GetPrivateBookingsResponseData(bookings: []),
          responseStatus: responseStatus,
        );
      }
      throw Exception('Error parsing GetPrivateBookingsResponse: $e');
    }
  }

  @override
  String toString() {
    return 'GetPrivateBookingsResponse(data: $data, responseStatus: $responseStatus)';
  }
}

// * ===========  Data  ===========
class GetPrivateBookingsResponseData {
  final List<Booking> bookings;

  GetPrivateBookingsResponseData({
    required this.bookings,
  }) : super();

  factory GetPrivateBookingsResponseData.fromMap(Map<dynamic, dynamic> map) {
    final bookingsData = map[GetPrivateBookingsResponseDataFields.bookings.name];
    List<Booking> bookingsList = [];
    if (bookingsData != null) {
      for (var booking in bookingsData) {
        bookingsList.add(Booking.fromJson(booking));
      }
    }

    return GetPrivateBookingsResponseData(
      bookings: bookingsList,
    );
  }

  @override
  String toString() => 'GetPrivateBookingsResponseData(bookings: $bookings)';
}

// * ===========  Fields  ===========
enum GetPrivateBookingsResponseDataFields {
  bookings,
}
