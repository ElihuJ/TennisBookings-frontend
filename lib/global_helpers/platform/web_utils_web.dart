import 'package:web/web.dart' as web;

String getWindowOrigin() => web.window.origin;

void replaceHistoryState(String url) {
  final history = web.window.history;
  history.replaceState(history.state, '', url);
}

void reloadPage() => web.window.location.reload();
