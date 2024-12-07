import '../global_helpers/index.dart';

enum Environment { dev, prod, staging }

enum MessageType { success, error, warning, info }

enum ListOrder implements IsEnum {
  asc,
  desc;

  @override
  String get name {
    switch (this) {
      case ListOrder.asc:
        return 'Ascending';
      case ListOrder.desc:
        return 'Descending';
      default:
        return '';
    }
  }

  @override
  String get locale {
    switch (this) {
      case ListOrder.asc:
        return 'filters_ascending';
      case ListOrder.desc:
        return 'filters_descending';
    }
  }
}
