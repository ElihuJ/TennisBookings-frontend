import 'dart:js_interop';

import 'package:web/web.dart' as web;

String getWindowOrigin() => web.window.origin;

void replaceHistoryState(String url) {
  final history = web.window.history;
  history.replaceState(history.state, '', url);
}

// Declared as void — the underlying async JS function ends with a page reload,
// so there is nothing useful to await from the Dart side.
@JS('_forceUpdate')
external void _jsForceUpdate();

void reloadPage() => _jsForceUpdate();
