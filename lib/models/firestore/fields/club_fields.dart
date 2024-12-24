class ClubFields {
  static const String id = 'id';
  static const String name = 'name';
  static const String adminIds = 'adminIds';
  static const String hardCourts = 'hardCourts';
  static const String clayCourts = 'clayCourts';
  static const String grassCourts = 'grassCourts';
  static const String otherSurfaceCourts = 'otherSurfaceCourts';
  static const String annualFee = 'annualFee';
  static const String casualFee = 'casualFee';
  static const String onlyMembers = 'onlyMembers';
  static const String streetAddress = 'streetAddress';
  static const String suburb = 'suburb';
  static const String city = 'city';
  static const String postcode = 'postcode';
  static const String state = 'state';
  static const String courts = 'courts';

  static const List<String> allFields = [
    id,
    name,
    adminIds,
    hardCourts,
    clayCourts,
    grassCourts,
    otherSurfaceCourts,
    annualFee,
    casualFee,
    onlyMembers,
    streetAddress,
    suburb,
    city,
    postcode,
    state,
    courts,
  ];
}

class CourtFields {
  static const String id = 'id';
  static const String name = 'name';
  static const String surface = 'surface';
  static const String clubId = 'clubId';
  static const String bookings = 'bookings';
  static const String generalUnavailability = 'generalUnavailability';

  static const List<String> allFields = [
    id,
    name,
    surface,
    clubId,
    bookings,
    generalUnavailability,
  ];
}

class GeneralUnavailabilityFields {
  static const String dayOfTheWeek = 'dayOfTheWeek';
  static const String from = 'from';
  static const String to = 'to';

  static const List<String> allFields = [
    dayOfTheWeek,
    from,
    to,
  ];
}

class BookingFields {
  static const String id = 'id';
  static const String courtId = 'courtId';
  static const String ownerId = 'ownerId';
  static const String from = 'from';
  static const String to = 'to';
  static const String status = 'status';
  static const String restrictions = 'restrictions';
  static const String confirmedPlayerIds = 'confirmedPlayerIds';
  static const String format = 'format';
  static const String requests = 'requests';

  static const List<String> allFields = [
    id,
    courtId,
    ownerId,
    from,
    to,
    status,
    restrictions,
    confirmedPlayerIds,
    format,
    requests,
  ];
}
