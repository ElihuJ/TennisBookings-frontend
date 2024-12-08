import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../global_types/enums.dart';
import '../../global_types/types.dart';
import '../../strings/firebase/index.dart';
import 'types.dart';

ErrorInfo getErrorMessage({required ErrorCode errorCode}) {
  switch (errorCode) {
    case FirebaseAuthErrorCode.invalidEmail:
      return (MessageType.info, FirebaseErrorStrings.invalidEmail);
    case FirebaseAuthErrorCode.notVerified:
      return (MessageType.info, FirebaseErrorStrings.notVerified);
    case FirebaseAuthErrorCode.userDisabled:
      return (MessageType.info, FirebaseErrorStrings.userDisabled);
    case FirebaseAuthErrorCode.emailAlreadyInUse:
      return (MessageType.info, FirebaseErrorStrings.emailAlreadyInUse);
    case FirebaseAuthErrorCode.weakPassword:
      return (MessageType.info, FirebaseErrorStrings.weakPassword);
    default:
      return (MessageType.error, FirebaseErrorStrings.loginFailed);
  }
}

/// Returns the sha256 hash of [input] in hex notation.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
