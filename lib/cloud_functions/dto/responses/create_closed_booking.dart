import 'index.dart';

class CreateClosedBookingResponse {
  final CreateClosedBookingResponseData data;
  final ResponseStatus responseStatus;

  CreateClosedBookingResponse({
    required this.data,
    required this.responseStatus,
  }) : super();

  factory CreateClosedBookingResponse.fromMap(Map<String, dynamic> map) {
    try {
      final dataRaw = map[ResponseFields.data.name];
      final responseStatusRaw = map[ResponseFields.responseStatus.name];

      ResponseStatus responseStatus = ResponseStatus.fromMap(responseStatusRaw);
      CreateClosedBookingResponseData data = CreateClosedBookingResponseData.fromMap(dataRaw);

      return CreateClosedBookingResponse(
        data: data,
        responseStatus: responseStatus,
      );
    } catch (e) {
      if (map.containsKey(ResponseFields.responseStatus.name)) {
        final responseStatusRaw = map[ResponseFields.responseStatus.name];
        ResponseStatus responseStatus = ResponseStatus.fromMap(responseStatusRaw);
        return CreateClosedBookingResponse(
          data: CreateClosedBookingResponseData(success: false),
          responseStatus: responseStatus,
        );
      }
      throw Exception('Error parsing CreateClosedBookingResponse: $e');
    }
  }
}

// * ===========  Data  ===========
class CreateClosedBookingResponseData {
  final bool success;

  CreateClosedBookingResponseData({
    required this.success,
  }) : super();

  factory CreateClosedBookingResponseData.fromMap(Map<dynamic, dynamic> map) {
    return CreateClosedBookingResponseData(
      success: map[CreateClosedBookingResponseDataFields.success.name],
    );
  }
}

// * ===========  Fields  ===========
enum CreateClosedBookingResponseDataFields {
  success,
}
