export 'create_closed_booking.dart';
export 'update_user.dart';

class ResponseStatus {
  final ResponseCode code;
  final ResponseMessage message;

  ResponseStatus({
    required this.code,
    required this.message,
  }) : super();

  factory ResponseStatus.fromMap(Map<dynamic, dynamic> map) {
    return ResponseStatus(
      code: map[ResponseStatusFields.code.name],
      message: map[ResponseStatusFields.message.name],
    );
  }
}

// * ===========  Types  ===========

typedef ResponseCode = int;
typedef ResponseMessage = String;

// * ===========  Enums  ===========

enum ResponseFields {
  responseStatus,
  data,
}

enum ResponseStatusFields {
  code,
  message,
}
