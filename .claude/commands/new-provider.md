# /new-provider

Scaffold a Riverpod `StateNotifierProvider` + `StateNotifier` pair following TennisBookings conventions.

## Usage

```
/new-provider FeatureName StateType
```

Where `StateType` is the type held in state — e.g., `List<Club>`, `MyModel`, `MyState`.

## What to generate

### 1. Notifier — `lib/state/<feature_name>/<feature_name>_notifier.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../cloud_functions/index.dart';
import '../../global_helpers/index.dart';
import '../../models/index.dart';
import '../index.dart';

class $FeatureNameNotifier extends StateNotifier<$StateType> {
  $FeatureNameNotifier(this.cloudFunctionsNotifier) : super($StateType.empty());
  // or: super([]) for List state
  final CloudFunctionsNotifier cloudFunctionsNotifier;

  Future<void> load() async {
    // * Firestore read or Cloud Function call
    // state = newValue;
  }

  void update($StateType updated) {
    state = updated;
  }

  void reset() {
    state = $StateType.empty();
  }
}
```

### 2. Provider — `lib/state/<feature_name>/<feature_name>_provider.dart`

```dart
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../cloud_functions/index.dart';
import 'index.dart';

final $featureNameProvider = StateNotifierProvider<$FeatureNameNotifier, $StateType>((ref) {
  final cloudFunctionsNotifier = ref.watch(cloudFunctionsProvider.notifier);
  return $FeatureNameNotifier(cloudFunctionsNotifier);
});
```

### 3. Barrel — `lib/state/<feature_name>/index.dart`

```dart
export '$feature_name_notifier.dart';
export '$feature_name_provider.dart';
// export any state model files here too
```

### 4. Register — export from `lib/state/index.dart`

```dart
export '<feature_name>/index.dart';
```

## Usage in screens

```dart
// Reactive — rebuilds widget when state changes
final data = ref.watch($featureNameProvider);

// Imperative — call notifier actions (never inside build without a callback)
final notifier = ref.read($featureNameProvider.notifier);
await notifier.load();
```

## Reminders

- Provider variable name is camelCase: `myFeatureProvider`
- Notifier class name is PascalCase with `Notifier` suffix: `MyFeatureNotifier`
- State must be fully replaced for Riverpod to detect changes — never mutate in place
- For List state, rebuild with `state = [...state]` after mutating list items
- Inject `CloudFunctionsNotifier` via constructor if the notifier makes API calls
- Inject other notifiers the same way if there's cross-feature dependency
- Keep notifier methods focused — one async operation per method
