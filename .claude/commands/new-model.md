# /new-model

Scaffold a new Riverpod data model + Firestore field constants following TennisBookings conventions.

## Usage

```
/new-model ModelName field1:String field2:int field3:bool?
```

Field types after `:` are Dart types. Append `?` for nullable.

## What to generate

### 1. Fields constants — `lib/models/firestore/fields/<model_name>_fields.dart`

```dart
class $ModelNameFields {
  static const String id = 'id';
  static const String field1 = 'field1';
  static const String field2 = 'field2';
  static const String field3 = 'field3';

  static const List<String> allFields = [id, field1, field2, field3];
}
```

### 2. Model class — `lib/models/riverpod/<model_name>.dart`

```dart
import 'dart:collection';

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../index.dart';

final _defaultId = getUuid();

class $ModelName extends MapView<String, dynamic> implements FirestoreModel, HasId {
  @override
  final String id;
  final String field1;
  final int field2;
  final bool? field3;

  @override
  final List<String> allFields = $ModelNameFields.allFields;

  $ModelName({
    required this.id,
    required this.field1,
    required this.field2,
    this.field3,
  }) : super({
          $ModelNameFields.id: id,
          $ModelNameFields.field1: field1,
          $ModelNameFields.field2: field2,
          $ModelNameFields.field3: field3,
        });

  $ModelName.empty()
      : this(
          id: _defaultId,
          field1: '',
          field2: 0,
        );

  $ModelName copyWith({
    String? id,
    String? field1,
    int? field2,
    bool? field3,
  }) =>
      $ModelName(
        id: id ?? this.id,
        field1: field1 ?? this.field1,
        field2: field2 ?? this.field2,
        field3: field3 ?? this.field3,
      );

  factory $ModelName.fromJson(Map<String, dynamic> json) => $ModelName(
        id: json[$ModelNameFields.id] ?? '',
        field1: json[$ModelNameFields.field1] ?? '',
        field2: json[$ModelNameFields.field2] ?? 0,
        field3: json[$ModelNameFields.field3],
      );

  @override
  Map<String, dynamic> toJson() => {
        $ModelNameFields.id: id,
        $ModelNameFields.field1: field1,
        $ModelNameFields.field2: field2,
        $ModelNameFields.field3: field3,
      };
}
```

### 3. Export — update barrel files

- Add export to `lib/models/firestore/fields/index.dart`:
  ```dart
  export '<model_name>_fields.dart';
  ```
- Add export to `lib/models/riverpod/index.dart`:
  ```dart
  export '<model_name>.dart';
  ```

## Reminders

- `MapView<String, dynamic>` super constructor must receive every field
- `allFields` lists all Firestore field constant strings
- Default values in `fromJson` must be safe (empty string / 0 / false / null) — never throw
- `copyWith` nullable params let callers override only what they need
- Use `getUuid()` (from `global_helpers`) for default IDs in `.empty()` constructor
- Implement `HasId` when the model has an `id` field stored in Firestore
- Implement `HasName` when the model has a `name` field used for display
