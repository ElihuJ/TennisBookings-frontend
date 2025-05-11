class ClubFields {
  static const String id = 'id';
  static const String name = 'name';
  static const String adminIds = 'adminIds';
  static const String hardCourts = 'hardCourts';
  static const String clayCourts = 'clayCourts';
  static const String grassCourts = 'grassCourts';
  static const String otherSurfaceCourts = 'otherSurfaceCourts';
  static const String annualFee = 'annualFee';
  static const String casualBooking = 'casualBooking';
  static const String onlyMembers = 'onlyMembers';
  static const String streetAddress = 'streetAddress';
  static const String suburb = 'suburb';
  static const String city = 'city';
  static const String clubLogoUrl = 'clubLogoUrl';
  static const String postcode = 'postcode';
  static const String state = 'state';
  static const String courts = 'courts';
  static const String contactEmail = 'contactEmail';
  static const String contactPhone = 'contactPhone';
  static const String memberIds = 'memberIds';

  static const List<String> allFields = [
    id,
    name,
    adminIds,
    hardCourts,
    clayCourts,
    grassCourts,
    otherSurfaceCourts,
    annualFee,
    casualBooking,
    onlyMembers,
    streetAddress,
    suburb,
    city,
    postcode,
    state,
    courts,
    clubLogoUrl,
    memberIds,
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
  static const String startTime = 'startTime';
  static const String endTime = 'endTime';

  static const List<String> allFields = [
    dayOfTheWeek,
    startTime,
    endTime,
  ];
}
