enum CFResponseMessage {
  ok,
  unauthenticated,
  forbidden,
  notFound,
  internalError,
  badRequest;
}

enum CFResponseCode {
  ok,
  unauthenticated,
  forbidden,
  notFound,
  internalError,
  badRequest;
}

class CFResponseStatus {
  CFResponseCode code;
  CFResponseMessage message;

  CFResponseStatus(this.code, this.message);

  static CFResponseStatus ok = CFResponseStatus(CFResponseCode.ok, CFResponseMessage.ok);

  static CFResponseStatus badRequest = CFResponseStatus(
    CFResponseCode.badRequest,
    CFResponseMessage.badRequest,
  );

  static CFResponseStatus unauthenticated = CFResponseStatus(
    CFResponseCode.unauthenticated,
    CFResponseMessage.unauthenticated,
  );

  static CFResponseStatus forbidden = CFResponseStatus(
    CFResponseCode.forbidden,
    CFResponseMessage.forbidden,
  );

  static CFResponseStatus notFound = CFResponseStatus(
    CFResponseCode.notFound,
    CFResponseMessage.notFound,
  );

  static CFResponseStatus internalError = CFResponseStatus(
    CFResponseCode.internalError,
    CFResponseMessage.internalError,
  );

  @override
  String toString() {
    return 'CFResponseStatus(code: $code, message: $message)';
  }
}

class CFResult<T> {
  CFResponseStatus responseStatus;
  T? data;
  String? errorMessage;

  CFResult({required this.responseStatus, this.data, this.errorMessage});

  static CFResult<T> ok<T>({required T data}) {
    return CFResult<T>(responseStatus: CFResponseStatus.ok, data: data);
  }

  static CFResult<T> badRequest<T>({required String errorMessage}) {
    return CFResult(responseStatus: CFResponseStatus.badRequest, errorMessage: errorMessage);
  }

  static CFResult<T> unauthenticated<T>({required String errorMessage}) {
    return CFResult(responseStatus: CFResponseStatus.unauthenticated);
  }

  static CFResult<T> forbidden<T>({required String errorMessage}) {
    return CFResult(responseStatus: CFResponseStatus.forbidden, errorMessage: errorMessage);
  }

  static CFResult<T> notFound<T>({required String errorMessage}) {
    return CFResult(responseStatus: CFResponseStatus.notFound, errorMessage: errorMessage);
  }

  static CFResult<T> internalError<T>({required String errorMessage}) {
    return CFResult(responseStatus: CFResponseStatus.internalError, errorMessage: errorMessage);
  }

  @override
  String toString() {
    return 'CFResult(responseStatus: $responseStatus, data: $data, errorMessage: $errorMessage)';
  }
}
