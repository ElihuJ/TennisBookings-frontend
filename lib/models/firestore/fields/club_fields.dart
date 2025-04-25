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
  static const String clubLogoUrl = 'clubLogoUrl';
  static const String postcode = 'postcode';
  static const String state = 'state';
  static const String courts = 'courts';
  static const String allowPublicBookings = 'allowPublicBookings';
  static const String totalMembers = 'totalMembers';
  static const String contactEmail = 'contactEmail';
  static const String contactPhone = 'contactPhone';

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
    allowPublicBookings,
    clubLogoUrl,
    totalMembers,
    contactEmail,
    contactPhone,
  ];
}

class CourtFields {
  static const String id = 'id';
  static const String name = 'name';
  static const String surface = 'surface';
  static const String clubId = 'clubId';
  static const String publicBookings = 'public_bookings';
  static const String privateBookings = 'private_bookings';
  static const String generalUnavailability = 'generalUnavailability';

  static const List<String> allFields = [
    id,
    name,
    surface,
    clubId,
    publicBookings,
    privateBookings,
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
