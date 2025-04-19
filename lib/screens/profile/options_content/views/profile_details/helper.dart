import 'package:flutter/foundation.dart';
import 'package:tennisbookings/global_helpers/index.dart';

import '../../../../../state/index.dart';

Future<String?> uploadImage({required UserNotifier userNotifier, required Uint8List? imageBytes}) async {
  if (imageBytes != null && imageBytes.isNotEmpty) {
    final (newUrl, uploadErrorInfo) = await userNotifier.uploadProfilePhoto(imageBytes: imageBytes);
    if (uploadErrorInfo != null) {
      final messageType = uploadErrorInfo.$1;
      final message = uploadErrorInfo.$2;
      messageType.tbLogger('Message Type');
      message.tbLogger('Message');
      return newUrl;
    }
    return newUrl;
  }
  return null;
}
