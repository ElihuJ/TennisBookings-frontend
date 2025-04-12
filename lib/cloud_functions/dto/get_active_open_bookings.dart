import '../../global_helpers/index.dart';
import '../../models/index.dart';
import 'shared/response_status.dart';

class GetActiveOpenBookingsPayload implements APIPayload {
  static final endpoint = 'getActiveOpenBookings';

  GetActiveOpenBookingsPayload();

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  String toString() {
    return 'GetActiveOpenBookingsPayload()';
  }
}

// * ===========  Response  ===========

class GetActiveOpenBookingsResponse {
  final GetActiveOpenBookingsResponseData data;
  final ResponseStatus responseStatus;

  GetActiveOpenBookingsResponse({
    required this.data,
    required this.responseStatus,
  }) : super();

  factory GetActiveOpenBookingsResponse.fromJson(Map<String, dynamic> map) {
    try {
      final dataRaw = map[ResponseFields.data.name];
      final responseStatusRaw = map[ResponseFields.responseStatus.name];

      ResponseStatus responseStatus = ResponseStatus.fromJson(responseStatusRaw);

      GetActiveOpenBookingsResponseData data = GetActiveOpenBookingsResponseData.fromJson(dataRaw);

      return GetActiveOpenBookingsResponse(
        data: data,
        responseStatus: responseStatus,
      );
    } catch (e) {
      'Error parsing GetActiveOpenBookingsResponse: $e'.tbLogger('GetActiveOpenBookingsResponse', DebugLevel.error);
      if (map.containsKey(ResponseFields.responseStatus.name)) {
        final responseStatusRaw = map[ResponseFields.responseStatus.name];
        ResponseStatus responseStatus = ResponseStatus.fromJson(responseStatusRaw);
        return GetActiveOpenBookingsResponse(
          data: GetActiveOpenBookingsResponseData(bookings: []),
          responseStatus: responseStatus,
        );
      }
      throw Exception('Error parsing GetActiveOpenBookingsResponse: $e \n\n $map');
    }
  }

  @override
  String toString() {
    return 'GetActiveOpenBookingsResponse(data: $data, responseStatus: $responseStatus)';
  }
}

// * ===========  Data  ===========
class GetActiveOpenBookingsResponseData {
  final List<BookingWithPopulatedRequest> bookings;

  GetActiveOpenBookingsResponseData({
    required this.bookings,
  }) : super();

  factory GetActiveOpenBookingsResponseData.fromJson(Map<dynamic, dynamic> map) {
    try {
      final bookingsData = map[GetActiveOpenBookingsResponseDataFields.bookingsWithActiveRequests.name];
      List<BookingWithPopulatedRequest> bookingsList = [];
      if (bookingsData != null) {
        for (var booking in bookingsData) {
          final bookingWithPopulatedRequest = BookingWithPopulatedRequest.fromJson(booking);
          bookingsList.add(bookingWithPopulatedRequest);
        }
      }

      return GetActiveOpenBookingsResponseData(
        bookings: bookingsList,
      );
    } catch (e) {
      'Error parsing GetActiveOpenBookingsResponseData: $e'.tbLogger('GetActiveOpenBookingsResponseData', DebugLevel.error);
      return GetActiveOpenBookingsResponseData(
        bookings: [],
      );
    }
  }

  @override
  String toString() => 'GetActiveOpenBookingsResponseData(bookings: $bookings)';
}

// * ===========  Fields  ===========
enum GetActiveOpenBookingsResponseDataFields {
  bookingsWithActiveRequests,
}
