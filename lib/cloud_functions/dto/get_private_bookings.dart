import '../../global_helpers/index.dart';
import '../../models/index.dart';
import 'shared/response_status.dart';

class GetPrivateBookingsPayload implements APIPayload {
  static final endpoint = 'getPrivateBookings';

  final bool getAll;
  final String? clubId;
  final String? courtId;

  GetPrivateBookingsPayload({required this.getAll, this.clubId, this.courtId});

  @override
  Map<String, dynamic> toJson() {
    return {'getAll': getAll, 'clubId': clubId, 'courtId': courtId};
  }

  @override
  String toString() {
    return 'GetPrivateBookingsPayload(getAll: $getAll, clubId: $clubId, courtId: $courtId)';
  }
}

// * ===========  Response  ===========

class GetPrivateBookingsResponse {
  final GetPrivateBookingsResponseData data;
  final ResponseStatus responseStatus;

  GetPrivateBookingsResponse({
    required this.data,
    required this.responseStatus,
  }) : super();

  factory GetPrivateBookingsResponse.fromJson(Map<String, dynamic> map) {
    try {
      final dataRaw = map[ResponseFields.data.name];
      final responseStatusRaw = map[ResponseFields.responseStatus.name];

      ResponseStatus responseStatus = ResponseStatus.fromJson(responseStatusRaw);
      GetPrivateBookingsResponseData data = GetPrivateBookingsResponseData.fromJson(dataRaw);

      return GetPrivateBookingsResponse(
        data: data,
        responseStatus: responseStatus,
      );
    } catch (e) {
      if (map.containsKey(ResponseFields.responseStatus.name)) {
        final responseStatusRaw = map[ResponseFields.responseStatus.name];
        ResponseStatus responseStatus = ResponseStatus.fromJson(responseStatusRaw);
        return GetPrivateBookingsResponse(
          data: GetPrivateBookingsResponseData(bookings: []),
          responseStatus: responseStatus,
        );
      }
      throw Exception('Error parsing GetPrivateBookingsResponse: $e \n\n $map');
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

  factory GetPrivateBookingsResponseData.fromJson(Map<dynamic, dynamic> map) {
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
