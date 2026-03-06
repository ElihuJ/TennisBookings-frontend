import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../global_helpers/class_helpers.dart';
import '../../../global_helpers/index.dart';
import '../../../state/index.dart';
import '../../../strings/index.dart';

Future<void> signInWithGoogle({
  required EventNotifier eventNotifier,
  required FirebaseAuthNotifier firebaseAuthNotifier,
  required UserNotifier userNotifier,
  required ResultHandler resultHandler,
  required BuildContext context,
}) async {
  eventNotifier.showLoading(message: context.localeString(LoginScreenStrings.loggingIn));
  final (user, _) = await firebaseAuthNotifier.signInWithGoogle(resultHandler: resultHandler);

  // * If user is null, create user
  if (user != null && resultHandler.errorInfo == null) {
    await userNotifier.createUser(uid: user.uid, email: user.email, name: user.displayName, resultHandler: resultHandler);
  }

  eventNotifier.hideLoading();

  // * Show message if there's an error
  if (resultHandler.errorInfo != null && context.mounted) {
    var (errorType, errorMsg) = resultHandler.errorInfo!;
    errorMsg = context.localeString(errorMsg);
    eventNotifier.showMessage(message: errorMsg, messageType: errorType);
  }
}

Future<void> signInWithApple({
  required EventNotifier eventNotifier,
  required FirebaseAuthNotifier firebaseAuthNotifier,
  required UserNotifier userNotifier,
  required ResultHandler resultHandler,
  required BuildContext context,
}) async {
  eventNotifier.showLoading(message: context.localeString(LoginScreenStrings.loggingIn));
  final (user, _) = await firebaseAuthNotifier.signInWithApple(resultHandler: resultHandler);

  // * If user is null, create user
  if (user != null && resultHandler.errorInfo == null) {
    await userNotifier.createUser(uid: user.uid, email: user.email, name: user.displayName, resultHandler: resultHandler);
  }

  eventNotifier.hideLoading();

  // * Show message if there's an error
  if (resultHandler.errorInfo != null && context.mounted) {
    var (errorType, errorMsg) = resultHandler.errorInfo!;
    errorMsg = context.localeString(errorMsg);
    eventNotifier.showMessage(message: errorMsg, messageType: errorType);
  }
}
