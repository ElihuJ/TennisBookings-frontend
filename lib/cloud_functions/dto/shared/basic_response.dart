// * ===========  Response  ===========

import '../index.dart';

class BasicResponse {
  final CreateBookingResponseData data;
  final ResponseStatus responseStatus;

  BasicResponse({
    required this.data,
    required this.responseStatus,
  }) : super();

  factory BasicResponse.fromJson(Map<String, dynamic> map) {
    try {
      final dataRaw = map[ResponseFields.data.name];
      final responseStatusRaw = map[ResponseFields.responseStatus.name];

      ResponseStatus responseStatus = ResponseStatus.fromJson(responseStatusRaw);
      CreateBookingResponseData data = CreateBookingResponseData.fromJson(dataRaw);

      return BasicResponse(
        data: data,
        responseStatus: responseStatus,
      );
    } catch (e) {
      if (map.containsKey(ResponseFields.responseStatus.name)) {
        final responseStatusRaw = map[ResponseFields.responseStatus.name];
        ResponseStatus responseStatus = ResponseStatus.fromJson(responseStatusRaw);
        return BasicResponse(
          data: CreateBookingResponseData(success: false),
          responseStatus: responseStatus,
        );
      }
      throw Exception('Error parsing CreateBookingResponse: $e');
    }
  }

  @override
  String toString() {
    return 'BasicResponse(data: $data, responseStatus: $responseStatus)';
  }
}

// * ===========  Data  ===========
class CreateBookingResponseData {
  final bool success;

  CreateBookingResponseData({
    required this.success,
  }) : super();

  factory CreateBookingResponseData.fromJson(Map<dynamic, dynamic> map) {
    return CreateBookingResponseData(
      success: map[CreateBookingResponseDataFields.success.name],
    );
  }

  @override
  String toString() {
    return 'CreateBookingResponseData(success: $success)';
  }
}

// * ===========  Fields  ===========
enum CreateBookingResponseDataFields {
  success,
}
