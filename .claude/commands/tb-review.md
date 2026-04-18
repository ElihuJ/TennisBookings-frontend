# /tb-review

Review selected Flutter code against TennisBookings project conventions.

## What to check

### Architecture
- [ ] Screen extends correct base (`HookConsumerWidget` vs `StatefulHookConsumerWidget`)
- [ ] Screen has `static const String route` defined
- [ ] `ref.watch` used for reactive state, `ref.read(notifier)` for actions
- [ ] No notifier method calls directly inside `ref.watch` or `build` without a callback
- [ ] Provider/notifier pair files are separated correctly

### Models
- [ ] Extends `MapView<String, dynamic>`
- [ ] Implements correct interfaces (`FirestoreModel`, `HasId`, `HasName`)
- [ ] Has `.empty()` constructor
- [ ] Has `copyWith()`, `fromJson()`, `toJson()`
- [ ] Super constructor passes all fields to `MapView`
- [ ] Field strings referenced via `*Fields` constants — no raw strings

### Cloud Functions
- [ ] `FirebaseFunctionsException` caught before generic `catch`
- [ ] Error logged with `.tbLogger()`, not `print()`
- [ ] Returns `CFResult.ok` on success, `CFResult.internalError` on failure
- [ ] Call site checks `responseStatus.code != CFResponseCode.ok` before using `.data!`

### Widgets & Styling
- [ ] No raw hex colors — uses `AppColors.*`
- [ ] No raw `ElevatedButton` / `TextButton` — uses `TbTextButton` global widget
- [ ] `SizedBox` for spacing (not `Padding` with zero values or `Container`)
- [ ] No inline font family strings — uses theme
- [ ] Responsive check uses `isMobile()` or `MediaQuery.of(context).size.width < 800`

### Logging
- [ ] No `print()` or `debugPrint()` — uses `.tbLogger()`
- [ ] Error logs include `DebugLevel.error`

### Code style
- [ ] Files are snake_case
- [ ] Classes are PascalCase with correct suffix (`Screen`, `Notifier`, `Fields`)
- [ ] Private members have `_` prefix
- [ ] Imports use barrel `index.dart` files
- [ ] Section headers use `// ^ ====== Name ======` format
- [ ] Inline notes use `// * Explanation` format

## How to use

Select code in the editor, then run `/tb-review`. Claude will:
1. Read the selected code
2. Check it against every item above
3. List issues found (with file + line references)
4. Suggest specific fixes for each issue
5. Flag any deviations that may be intentional (edge cases)
