# /new-screen

Scaffold a new Flutter screen following TennisBookings conventions.

## Usage

```
/new-screen ScreenName
/new-screen ScreenName --stateful
```

- Without `--stateful`: generates `HookConsumerWidget` (no local state)
- With `--stateful`: generates `StatefulHookConsumerWidget` (local state via `setState`)

## What to generate

### 1. Screen file — `lib/screens/<feature_name>/<feature_name>_screen.dart`

**Simple (HookConsumerWidget):**

```dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../global_widgets/index.dart';
import '../../state/index.dart';

class $ScreenNameScreen extends HookConsumerWidget {
  const $ScreenNameScreen({super.key});
  static const String route = '$ScreenName';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return TbScaffold(
      body: EventfulWidget(
        child: Center(
          child: Text(user.name),
        ),
      ),
    );
  }
}
```

**Stateful (StatefulHookConsumerWidget):**

```dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../global_widgets/index.dart';
import '../../state/index.dart';

class $ScreenNameScreen extends StatefulHookConsumerWidget {
  const $ScreenNameScreen({super.key});
  static const String route = '$ScreenName';

  @override
  ConsumerState<$ScreenNameScreen> createState() => _$ScreenNameScreenState();
}

class _$ScreenNameScreenState extends ConsumerState<$ScreenNameScreen> {
  // local state vars here

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return TbScaffold(
      body: EventfulWidget(
        child: Center(
          child: Text(user.name),
        ),
      ),
    );
  }
}
```

### 2. Widgets folder — `lib/screens/<feature_name>/widgets/`

Create `index.dart` barrel and a placeholder widget file.

### 3. Register route — `lib/routes/main_routes.dart`

Add inside the `generateLoginRoutes` switch:

```dart
case $ScreenNameScreen.route:
  page = const $ScreenNameScreen();
  break;
```

### 4. Export — add to `lib/screens/index.dart` if it exists

## Reminders

- Route string must be PascalCase, unique, and match the class name prefix
- Always wrap body in `TbScaffold` + `EventfulWidget`
- Import via barrel `index.dart` files, never direct file paths
- Use `ref.watch` for reactive state, `ref.read(notifier)` for actions
- Section headers in build: `// ^ ====== Section Name ======`
- Inline notes: `// * Explanation of non-obvious decision`
