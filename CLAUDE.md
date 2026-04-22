# TennisBookings Frontend — Claude Context

Flutter web application for tennis court booking management. Firebase backend with Riverpod state management.

---

## Stack

| Concern | Choice |
|---|---|
| Framework | Flutter (web-first) |
| State | Hooks Riverpod v2 (`StateNotifierProvider`) |
| Backend | Firebase (Auth, Firestore, Storage, Cloud Functions) |
| Payments | Stripe (`flutter_stripe` + `flutter_stripe_web`) |
| Auth | Firebase Auth, Google Sign-In, Apple Sign-In |
| i18n | `flutter_locales` — 6 locales: en, es, pt, fr, de, it |
| Font | FredokaOne (single font family) |

---

## Directory Layout

```
lib/
├── main.dart                  # Env init, Firebase, Stripe setup
├── entry.dart                 # ProviderScope + LocaleBuilder + MaterialApp
├── cloud_functions/           # Firebase Cloud Functions calls + DTOs
│   ├── cloud_functions_notifier.dart
│   ├── cloud_functions_provider.dart
│   └── dto/                   # *Payload (request) + *Response (response) per endpoint
├── config/                    # Config singleton (env/firebase/stripe keys), SizeConfig
├── global_helpers/            # Extension methods, utilities, mixins
│   └── index.dart             # barrel export
├── global_types/              # Enums + abstract base types
├── global_widgets/            # Shared UI components
│   ├── buttons/, cards/, containers/, icons/
│   ├── input_fields/, modals/, scaffold/, text/
│   └── eventful/              # EventfulWidget — global event listener
├── models/
│   ├── firestore/fields/      # *Fields constants classes per model
│   └── riverpod/              # Data model classes
├── routes/                    # generateLoginRoutes + QueryParams wrappers
├── screens/                   # Feature screens + per-screen widgets/
├── state/                     # Riverpod providers + notifiers
│   ├── clubs/, user/, firebase/, config/, event_status/
├── strings/                   # Localised UI strings
└── theme/                     # ThemeData, AppColors
```

Every directory exposes a barrel `index.dart`. Always import via the barrel, never direct file paths.

---

## Architecture Patterns

### Screens

Two screen base types — pick based on whether local `setState` is needed:

```dart
// Simple screen (no local state)
class MyScreen extends HookConsumerWidget {
  const MyScreen({super.key});
  static const String route = 'MyScreen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final clubs = ref.watch(clubsProvider);
    // ...
  }
}

// Screen with local mutable state
class MyScreen extends StatefulHookConsumerWidget {
  const MyScreen({super.key});
  static const String route = 'MyScreen';

  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  MyLocalType? _localVar;

  @override
  Widget build(BuildContext context) {
    final clubs = ref.watch(clubsProvider);
    // ...
  }
}
```

**Required screen conventions:**
- `static const String route = 'ScreenName';` — PascalCase, no spaces
- Wrap body in `TbScaffold` + `EventfulWidget`
- Use `ContainerWithBackground` when the screen needs the background image
- Use `// ^ ====== Section header ======` comments to separate logical blocks inside `build`
- Use `// * Note` for inline explanations of non-obvious decisions

### State — Providers

```dart
// lib/state/my_feature/my_feature_provider.dart
final myFeatureProvider = StateNotifierProvider<MyFeatureNotifier, MyFeatureState>((ref) {
  final cloudFunctionsNotifier = ref.watch(cloudFunctionsProvider.notifier);
  return MyFeatureNotifier(cloudFunctionsNotifier);
});
```

### State — Notifiers

```dart
class MyFeatureNotifier extends StateNotifier<MyFeatureState> {
  MyFeatureNotifier(this.cloudFunctionsNotifier) : super(MyFeatureState.empty());
  final CloudFunctionsNotifier cloudFunctionsNotifier;

  Future<void> loadData() async {
    // Firestore direct read or Cloud Function call
    state = state.copyWith(data: newData);
  }

  void localUpdate(MyFeatureState updated) {
    state = updated;
  }
}
```

**Conventions:**
- `ref.watch(provider)` to read reactive state in `build`
- `ref.read(provider.notifier)` to call notifier methods (actions)
- Never call notifier methods inside `ref.watch`
- Rebuild by reassigning `state = [...state]` or `state = state.copyWith(...)`

### Models

```dart
class MyModel extends MapView<String, dynamic> implements FirestoreModel, HasId {
  @override
  final String id;
  final String name;
  // ... other fields

  @override
  final List<String> allFields = MyModelFields.allFields;

  MyModel({
    required this.id,
    required this.name,
  }) : super({
        MyModelFields.id: id,
        MyModelFields.name: name,
      });

  MyModel.empty() : this(id: getUuid(), name: '');

  MyModel copyWith({String? id, String? name}) =>
      MyModel(id: id ?? this.id, name: name ?? this.name);

  factory MyModel.fromJson(Map<String, dynamic> json) => MyModel(
        id: json[MyModelFields.id] ?? '',
        name: json[MyModelFields.name] ?? '',
      );

  @override
  Map<String, dynamic> toJson() => {
        MyModelFields.id: id,
        MyModelFields.name: name,
      };
}
```

**Field constants — always a separate class in `lib/models/firestore/fields/`:**

```dart
class MyModelFields {
  static const String id = 'id';
  static const String name = 'name';

  static const List<String> allFields = [id, name];
}
```

### Cloud Function Endpoints

Each endpoint has a **Payload** (request) and **Response** (response) in `lib/cloud_functions/dto/`:

```dart
// dto/my_endpoint.dart
class MyEndpointPayload implements APIPayload {
  static const String endpoint = 'myEndpointFunctionName';
  final String someField;

  const MyEndpointPayload({required this.someField});

  @override
  Map<String, dynamic> toJson() => {'someField': someField};
}

class MyEndpointResponse {
  final ResponseStatus responseStatus;
  final MyEndpointData data;

  const MyEndpointResponse({required this.responseStatus, required this.data});

  factory MyEndpointResponse.fromJson(Map<String, dynamic> json) =>
      MyEndpointResponse(
        responseStatus: ResponseStatus.fromJson(json),
        data: MyEndpointData.fromJson(json['data']),
      );
}
```

**In `CloudFunctionsNotifier` — always this pattern:**

```dart
Future<CFResult<ReturnType>> myEndpoint(MyEndpointPayload payload) async {
  try {
    final HttpsCallableResult result =
        await cloudFunctions.httpsCallable(MyEndpointPayload.endpoint).call(payload.toJson());
    final response = MyEndpointResponse.fromJson(result.data);
    if (response.responseStatus.code != ResponseCodeEnum.success.value) {
      return CFResult.internalError(errorMessage: response.responseStatus.message);
    }
    return CFResult.ok<ReturnType>(data: response.data.someValue);
  } on FirebaseFunctionsException catch (error) {
    error.tbLogger('FirebaseFunctionsException myEndpoint', DebugLevel.error);
    return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
  } catch (error) {
    error.tbLogger('Error myEndpoint', DebugLevel.error);
    return CFResult.internalError(errorMessage: FirebaseErrorStrings.somethingWentWrong);
  }
}
```

### Enums

```dart
enum MyStatus implements IsEnum {
  active,
  inactive;

  @override
  String get localizationKey => 'myStatus_${name}';
}
```

---

## Navigation

```dart
// Navigate to screen
Navigator.of(context).pushNamed(MyScreen.route, arguments: queryParams);

// Navigate and replace
Navigator.of(context).pushReplacementNamed(MyScreen.route);

// Pop
Navigator.of(context).pop();
```

Routes registered in `lib/routes/main_routes.dart` in the `generateLoginRoutes` switch. Add new screens there.

**Query Params pattern** — create a class in `lib/routes/`:

```dart
class MyScreenQueryParams {
  final String requiredParam;
  final String? optionalParam;

  const MyScreenQueryParams({required this.requiredParam, this.optionalParam});
}
```

---

## Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Files | snake_case | `my_feature_screen.dart` |
| Classes | PascalCase | `MyFeatureScreen` |
| Screens | `*Screen` suffix | `ClubDetailsScreen` |
| Notifiers | `*Notifier` suffix | `ClubsNotifier` |
| Providers | `*Provider` suffix | `clubsProvider` (camelCase variable) |
| Fields constants | `*Fields` suffix | `BookingFields` |
| Enums | PascalCase name, lowercase values | `BookingStatus.confirmed` |
| Private members | `_` prefix | `_courtSelected` |
| Constants | camelCase or `_camelCase` if private | `_defaultId` |
| Routes | PascalCase string | `'ClubDetails'` |

---

## Theming & Styling

### Colors — NEVER use raw hex values

All colors **must** come from `AppColors` (defined in `lib/theme/colors.dart`). Raw hex literals (`Color(0xFF...)`) and `Colors.*` shades (`Colors.red.shade600`) are **forbidden** in widget files.

**Why:** Every color change needs to propagate app-wide. Named constants in one file make that a one-line edit; scattered hex values turn it into a multi-file search-and-replace with high risk of misses.

**How to apply:**
1. Before using any color, look it up in `AppColors` first.
2. If the color you need doesn't exist, **add it to `AppColors` with a descriptive name** before using it.
3. Never pass `Color(0x...)` directly to a widget property — not even "just once".

Key palette entries:
| Token | Hex | Usage |
|---|---|---|
| `courtGreen` | `#1F6B4A` | Gradient headers, logo, hero sections |
| `primaryGreen` | `#478966` | Buttons, focus rings, interactive elements |
| `darkGreen` | `#1B3427` | Dark headings, gradient endpoint |
| `tealGreen` | `#2E8B5F` | Background accent blobs |
| `mintLight` | `#DFF0E4` | Success badge bg, card accents |
| `mintBase` | `#F2F6F2` | App background base |
| `fieldFill` | `#F5F7F5` | Form field fill |
| `surfaceGreen` | `#F0F4F1` | Tab switcher, light card surfaces |
| `textBody` | `#4A5C50` | Muted body text |
| `textSubtle` | `#6B7B6E` | Labels, hints, placeholders |
| `borderLight` | `#DDE0DD` | Default field border |
| `borderCancel` | `#CCCCCC` | Cancel/neutral button border |
| `disabledGreen` | `#B0C8BB` | Disabled green button fill |
| `dangerRed` | `#E53935` | Delete/withdraw action buttons |
| `errorRed` | `#B71C1C` | Error icon/text |
| `warningOrange` | `#E65100` | Warning icon/text |
| `infoBlue` | `#1565C0` | Info icon/text |

### Other style rules

- Spacing: use `SizedBox(height/width: N)` — no magic numbers, prefer multiples of 4/8
- Fonts: FredokaOne is the only font — set via theme, not inline
- Responsive: use `isMobile()` helper and `MediaQuery.of(context).size.width < 800` breakpoint
- Button styles: use global `TbTextButton`, `TbTextButtonWithImage` — don't inline `ElevatedButton`
- Text: use `PrettyText` global widget for styled text

---

## Logging

Use the `.tbLogger()` extension everywhere — never `print()`:

```dart
someValue.tbLogger('Context message');           // info
someError.tbLogger('Context message', DebugLevel.error);
```

---

## Firestore Collections

Constants in `lib/models/firestore/collections.dart`:
- `FirestoreCollection.clubs`
- `CourtsSubCollections.courts`
- `BookingsSubCollections.publicBookings` / `.privateBookings`

---

## Environment & Config

`Config` is a singleton accessed statically:

```dart
Config.appName        // "Tennis Bookings"
Config.functionsRegion  // "australia-southeast2"
Config.theme          // ThemeData
Config.environment    // Environment.dev | .uat | .prod
```

---

## File Checklist When Adding a New Feature

- [ ] Model class in `lib/models/riverpod/my_model.dart`
- [ ] Fields constants in `lib/models/firestore/fields/my_model_fields.dart`
- [ ] Export from `lib/models/riverpod/index.dart` and `lib/models/firestore/fields/index.dart`
- [ ] Notifier in `lib/state/my_feature/my_feature_notifier.dart`
- [ ] Provider in `lib/state/my_feature/my_feature_provider.dart`
- [ ] Barrel `lib/state/my_feature/index.dart`
- [ ] Export from `lib/state/index.dart`
- [ ] Screen in `lib/screens/my_feature/my_feature_screen.dart`
- [ ] Route registered in `lib/routes/main_routes.dart`
- [ ] DTO files in `lib/cloud_functions/dto/` (if calling a Cloud Function)

---

## Available Slash Commands

| Command | Purpose |
|---|---|
| `/new-screen` | Scaffold a new screen following project conventions |
| `/new-model` | Scaffold a model + fields constants class |
| `/new-provider` | Scaffold a notifier + provider pair |
| `/new-cf-endpoint` | Scaffold a Cloud Function DTO + notifier method |
| `/tb-review` | Review selected code against project conventions |
