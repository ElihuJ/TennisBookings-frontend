import 'package:firebase_storage/firebase_storage.dart' as fb_storage;
import 'package:uuid/uuid.dart';

import '../global_types/index.dart';
import 'index.dart';

const uuid = Uuid();

String getUuid() {
  return uuid.v4();
}

// ^ Verifies that a required prop is not null and returns the prop or a default value
// ^ Data would come from a json map (Firestore)
T verifyRequiredProp<T>({
  required Object? prop,
  required String propName,
  required T defaultValue,
}) {
  if (prop == null) {
    final classString = getClassString(StackTrace.current);
    propName.tbLogger('$classString: Required Prop Missing ', DebugLevel.warning);
    return defaultValue;
  }
  // Firestore returns int on native but double on web for numeric fields.
  if (T == double && prop is num) return prop.toDouble() as T;
  if (T == int && prop is num) return prop.toInt() as T;
  return prop as T;
}

// ^ Verifies that a not required prop is not null and returns the prop or null
// ^ Data would come from a json map (Firestore)
T? verifyNotRequiredProp<T>({required Object? prop, required String propName}) {
  if (prop == null) {
    final classString = getClassString(StackTrace.current);
    propName.tbLogger('$classString: Not Required Prop Missing', DebugLevel.info);
    return null;
  }
  if (T == double && prop is num) return prop.toDouble() as T;
  if (T == int && prop is num) return prop.toInt() as T;
  return prop as T;
}

// ^ Verifies that all props in the json map are in the props list and logs a warning if not
// ^ Data would come from a json map (Firestore)
void verifyProps(FirestoreResponse json, List<String> props) {
  try {
    final classString = getClassString(StackTrace.current);
    final propsNotInMap = json.keys.where((key) => !props.contains(key));
    if (propsNotInMap.isNotEmpty) {
      propsNotInMap.tbLogger('$classString: Props in json not in map', DebugLevel.warning);
    }
  } catch (e) {
    e.tbLogger('verifyProps error', DebugLevel.error);
  }
}

// ^ Grabs the calling class name from the stack trace
final RegExp regexFromJson = RegExp(r'\w+\.fromJson');

String getClassString(StackTrace stackTrace) {
  final stackString = stackTrace.toString();
  final Match? match = regexFromJson.firstMatch(stackString);
  final groupString = match?.group(0);
  final splitString = groupString?.split('.');
  final classString = splitString?.first;
  return classString ?? '';
}

List<Map<String, dynamic>> listToJson(List<HasJson> array) {
  final list = array.map((e) => e.toJson()).toList();
  return list;
}

class ResultHandler {
  ErrorInfo? errorInfo;
  bool success;

  ResultHandler({this.success = false});

  (bool, ErrorInfo?) get result {
    return (success, errorInfo);
  }

  ErrorInfo? get error {
    return errorInfo;
  }

  void handleError({required dynamic error, required String errorMessage}) {
    errorInfo = (MessageType.error, errorMessage);
    success = false;
    if (error is String) {
      errorInfo = (MessageType.error, error);
      error.tbLogger('String error', DebugLevel.error);
    }
    if (error is fb_storage.FirebaseException) {
      errorInfo = (MessageType.warning, error.message ?? errorMessage);
      error.message?.tbLogger('FB Storage Error', DebugLevel.error);
    }
  }
}
