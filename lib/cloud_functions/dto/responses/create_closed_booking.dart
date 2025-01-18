import 'index.dart';

class CreateBookingResponse {
  final CreateBookingResponseData data;
  final ResponseStatus responseStatus;

  CreateBookingResponse({
    required this.data,
    required this.responseStatus,
  }) : super();

  factory CreateBookingResponse.fromMap(Map<String, dynamic> map) {
    try {
      final dataRaw = map[ResponseFields.data.name];
      final responseStatusRaw = map[ResponseFields.responseStatus.name];

      ResponseStatus responseStatus = ResponseStatus.fromMap(responseStatusRaw);
      CreateBookingResponseData data = CreateBookingResponseData.fromMap(dataRaw);

      return CreateBookingResponse(
        data: data,
        responseStatus: responseStatus,
      );
    } catch (e) {
      if (map.containsKey(ResponseFields.responseStatus.name)) {
        final responseStatusRaw = map[ResponseFields.responseStatus.name];
        ResponseStatus responseStatus = ResponseStatus.fromMap(responseStatusRaw);
        return CreateBookingResponse(
          data: CreateBookingResponseData(success: false),
          responseStatus: responseStatus,
        );
      }
      throw Exception('Error parsing CreateBookingResponse: $e');
    }
  }
}

// * ===========  Data  ===========
class CreateBookingResponseData {
  final bool success;

  CreateBookingResponseData({
    required this.success,
  }) : super();

  factory CreateBookingResponseData.fromMap(Map<dynamic, dynamic> map) {
    return CreateBookingResponseData(
      success: map[CreateBookingResponseDataFields.success.name],
    );
  }
}

// * ===========  Fields  ===========
enum CreateBookingResponseDataFields {
  success,
}
