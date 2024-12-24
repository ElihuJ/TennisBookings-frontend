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

enum DayOfTheWeek implements IsEnum {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
  unknown;

  @override
  String get name {
    switch (this) {
      case DayOfTheWeek.monday:
        return 'monday';
      case DayOfTheWeek.tuesday:
        return 'tuesday';
      case DayOfTheWeek.wednesday:
        return 'wednesday';
      case DayOfTheWeek.thursday:
        return 'thursday';
      case DayOfTheWeek.friday:
        return 'friday';
      case DayOfTheWeek.saturday:
        return 'saturday';
      case DayOfTheWeek.sunday:
        return 'sunday';
      default:
        return 'unknown';
    }
  }

  @override
  String get locale {
    switch (this) {
      case DayOfTheWeek.monday:
        return 'monday';
      case DayOfTheWeek.tuesday:
        return 'tuesday';
      case DayOfTheWeek.wednesday:
        return 'wednesday';
      case DayOfTheWeek.thursday:
        return 'thursday';
      case DayOfTheWeek.friday:
        return 'friday';
      case DayOfTheWeek.saturday:
        return 'saturday';
      case DayOfTheWeek.sunday:
        return 'sunday';
      default:
        return 'unknown';
    }
  }

  static DayOfTheWeek fromString(String day) {
    switch (day) {
      case 'monday':
        return DayOfTheWeek.monday;
      case 'tuesday':
        return DayOfTheWeek.tuesday;
      case 'wednesday':
        return DayOfTheWeek.wednesday;
      case 'thursday':
        return DayOfTheWeek.thursday;
      case 'friday':
        return DayOfTheWeek.friday;
      case 'saturday':
        return DayOfTheWeek.saturday;
      case 'sunday':
        return DayOfTheWeek.sunday;
      default:
        return DayOfTheWeek.unknown;
    }
  }
}
