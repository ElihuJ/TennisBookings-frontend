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
        ''.tbLogger('ListOrder.name: $this', DebugLevel.warning);
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
        return 'female';
      case Gender.male:
        return 'male';
      case Gender.unknown:
        ''.tbLogger('Gender.name: $this', DebugLevel.warning);
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
        ''.tbLogger('Gender.locale: $this', DebugLevel.warning);
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
        ''.tbLogger('DayOfTheWeek.name: $this', DebugLevel.warning);
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
        ''.tbLogger('DayOfTheWeek.locale: $this', DebugLevel.warning);
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
        ''.tbLogger('DayOfTheWeek.fromString: $day', DebugLevel.warning);
        return DayOfTheWeek.unknown;
    }
  }
}

enum BookingFormat implements IsEnum {
  singles,
  doubles,
  coaching,
  unknown,
  merged;

  @override
  String get name {
    switch (this) {
      case BookingFormat.singles:
        return 'singles';
      case BookingFormat.doubles:
        return 'doubles';
      case BookingFormat.coaching:
        return 'coaching';
      case BookingFormat.unknown:
        return 'unknown';

      case BookingFormat.merged: // * ONLY FOR FRONT END
        return 'merged';
      default:
        ''.tbLogger('BookingFormat.name: $this', DebugLevel.warning);
        return 'unknown';
    }
  }

  @override
  String get locale {
    switch (this) {
      case BookingFormat.singles:
        return 'singles';
      case BookingFormat.doubles:
        return 'doubles';
      case BookingFormat.coaching:
        return 'coaching';
      case BookingFormat.unknown:
        return 'unknown';
      case BookingFormat.merged: // * ONLY FOR FRONT END
        return 'merged';
      default:
        ''.tbLogger('BookingFormat.locale: $this', DebugLevel.warning);
        return 'unknown';
    }
  }

  static BookingFormat fromString(String day) {
    switch (day) {
      case 'singles':
        return BookingFormat.singles;
      case 'doubles':
        return BookingFormat.doubles;
      case 'coaching':
        return BookingFormat.coaching;
      case 'merged':
        return BookingFormat.merged;
      case 'unknown':
        return BookingFormat.unknown;
      default:
        ''.tbLogger('BookingFormat.fromString: $day', DebugLevel.warning);
        return BookingFormat.unknown;
    }
  }
}

enum BookingStatus implements IsEnum {
  confirmed,
  open,
  cancelled,
  overridden,
  unknown;

  @override
  String get name {
    switch (this) {
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.open:
        return 'open';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.overridden:
        return 'overridden';
      default:
        ''.tbLogger('BookingStatus.name: $this', DebugLevel.warning);
        return 'unknown';
    }
  }

  @override
  String get locale {
    switch (this) {
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.open:
        return 'open';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.overridden:
        return 'overridden';
      default:
        ''.tbLogger('BookingStatus.locale: $this', DebugLevel.warning);
        return 'unknown';
    }
  }

  static BookingStatus fromString(String day) {
    switch (day) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'open':
        return BookingStatus.open;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'overridden':
        return BookingStatus.overridden;
      default:
        ''.tbLogger('BookingStatus.fromString: $day', DebugLevel.warning);
        return BookingStatus.unknown;
    }
  }
}

enum BookingRequestStatus implements IsEnum {
  pending,
  accepted,
  rejected,
  unknown;

  @override
  String get name {
    switch (this) {
      case BookingRequestStatus.pending:
        return 'pending';
      case BookingRequestStatus.accepted:
        return 'accepted';
      case BookingRequestStatus.rejected:
        return 'rejected';
      default:
        ''.tbLogger('BookingRequestStatus.name: $this', DebugLevel.warning);
        return 'unknown';
    }
  }

  @override
  String get locale {
    switch (this) {
      case BookingRequestStatus.pending:
        return 'pending';
      case BookingRequestStatus.accepted:
        return 'accepted';
      case BookingRequestStatus.rejected:
        return 'rejected';
      default:
        ''.tbLogger('BookingRequestStatus.locale: $this', DebugLevel.warning);

        return 'unknown';
    }
  }

  static BookingRequestStatus fromString(String day) {
    switch (day) {
      case 'pending':
        return BookingRequestStatus.pending;
      case 'accepted':
        return BookingRequestStatus.accepted;
      case 'rejected':
        return BookingRequestStatus.rejected;
      default:
        ''.tbLogger('BookingRequestStatus.fromString: $day', DebugLevel.warning);
        return BookingRequestStatus.unknown;
    }
  }
}
