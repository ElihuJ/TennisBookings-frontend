// * ===========  Response  ===========

import '../index.dart';

class BasicResponse {
  final BasicResponseData data;
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
      BasicResponseData data = BasicResponseData.fromJson(dataRaw);

      return BasicResponse(
        data: data,
        responseStatus: responseStatus,
      );
    } catch (e) {
      if (map.containsKey(ResponseFields.responseStatus.name)) {
        final responseStatusRaw = map[ResponseFields.responseStatus.name];
        ResponseStatus responseStatus = ResponseStatus.fromJson(responseStatusRaw);
        return BasicResponse(
          data: BasicResponseData(success: false),
          responseStatus: responseStatus,
        );
      }
      throw Exception('Error parsing CreateBookingResponse: $e \n\n $map');
    }
  }

  @override
  String toString() {
    return 'BasicResponse(data: $data, responseStatus: $responseStatus)';
  }
}

// * ===========  Data  ===========
class BasicResponseData {
  final bool success;

  BasicResponseData({
    required this.success,
  }) : super();

  factory BasicResponseData.fromJson(Map<dynamic, dynamic> map) {
    return BasicResponseData(
      success: map[BasicResponseDataFields.success.name],
    );
  }

  @override
  String toString() {
    return 'CreateBookingResponseData(success: $success)';
  }
}

// * ===========  Fields  ===========
enum BasicResponseDataFields {
  success,
}
