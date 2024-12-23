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

enum Gender implements IsEnum {
  male,
  female,
  unknown;

  @override
  String get name {
    switch (this) {
      case Gender.female:
        return 'Female';
      case Gender.male:
        return 'Male';
      case Gender.unknown:
        return 'Unknown';
    }
  }

  @override
  String get locale {
    switch (this) {
      case Gender.female:
        return 'female';
      case Gender.male:
        return 'male';
      case Gender.unknown:
        return 'unknown';
    }
  }
}
