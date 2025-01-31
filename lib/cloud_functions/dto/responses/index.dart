export 'create_booking.dart';
export 'get_private_bookings.dart';

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

  @override
  String toString() {
    return 'ResponseStatus(code: $code, message: $message)';
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

enum ResponseCodeEnum {
  success,
  error;

  int get value {
    switch (this) {
      case ResponseCodeEnum.success:
        return 200;
      case ResponseCodeEnum.error:
        return 500;
      default:
        return 500;
    }
  }
}
