# /new-cf-endpoint

Scaffold a Firebase Cloud Functions endpoint: DTO pair + `CloudFunctionsNotifier` method.

## Usage

```
/new-cf-endpoint endpointFunctionName ReturnType
```

Where `endpointFunctionName` is the Firebase Cloud Function name (camelCase) and `ReturnType` is the Dart type the method returns inside `CFResult<T>`.

## What to generate

### 1. DTO file — `lib/cloud_functions/dto/<endpoint_name>.dart`

```dart
import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../../models/index.dart';
import '../types.dart';

// * Request payload
class $EndpointNamePayload implements APIPayload {
  static const String endpoint = '$endpointFunctionName';

  final String someField;

  const $EndpointNamePayload({required this.someField});

  @override
  Map<String, dynamic> toJson() => {
        'someField': someField,
      };
}

// * Response data
class $EndpointNameData {
  final $ReturnType result;

  const $EndpointNameData({required this.result});

  factory $EndpointNameData.fromJson(Map<String, dynamic> json) =>
      $EndpointNameData(
        result: json['result'],
      );
}

// * Response wrapper
class $EndpointNameResponse {
  final ResponseStatus responseStatus;
  final $EndpointNameData data;

  const $EndpointNameResponse({required this.responseStatus, required this.data});

  factory $EndpointNameResponse.fromJson(Map<String, dynamic> json) =>
      $EndpointNameResponse(
        responseStatus: ResponseStatus.fromJson(json),
        data: $EndpointNameData.fromJson(json['data']),
      );
}
```

### 2. Export DTO — add to `lib/cloud_functions/dto/index.dart`

```dart
export '<endpoint_name>.dart';
```

### 3. Method in `CloudFunctionsNotifier` — `lib/cloud_functions/cloud_functions_notifier.dart`

```dart
Future<CFResult<$ReturnType>> $endpointMethodName($EndpointNamePayload payload) async {
  try {
    final HttpsCallableResult result =
        await cloudFunctions.httpsCallable($EndpointNamePayload.endpoint).call(payload.toJson());
    final response = $EndpointNameResponse.fromJson(result.data);
    if (response.responseStatus.code != ResponseCodeEnum.success.value) {
      return CFResult.internalError(errorMessage: response.responseStatus.message);
    }
    return CFResult.ok<$ReturnType>(data: response.data.result);
  } on FirebaseFunctionsException catch (error) {
    error.tbLogger('FirebaseFunctionsException $endpointMethodName', DebugLevel.error);
    return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
  } catch (error) {
    error.tbLogger('Error $endpointMethodName', DebugLevel.error);
    return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
  }
}
```

### 4. Call site in a Notifier

```dart
final result = await cloudFunctionsNotifier.$endpointMethodName(
  $EndpointNamePayload(someField: value),
);

if (result.responseStatus.code != CFResponseCode.ok) {
  result.responseStatus.tbLogger('Failed to call $endpointMethodName');
  return;
}

final data = result.data!;
```

## Reminders

- `endpoint` static const must exactly match the Firebase Cloud Function name
- Always catch `FirebaseFunctionsException` FIRST, then generic `catch`
- Use `error.tbLogger(...)` — never `print()` or `debugPrint()`
- `CFResult.ok` wraps success; `CFResult.internalError` wraps all failures
- Check `result.responseStatus.code != CFResponseCode.ok` at call site before using `.data!`
- DTO field names in `toJson()` must match what the Cloud Function expects exactly
- Parse response in `fromJson` with safe defaults — never assume a field exists
