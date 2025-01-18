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
  static const String private = 'private';
  static const String title = 'title';

  static const List<String> allFields = [id, courtId, ownerId, from, to, status, restrictions, confirmedPlayerIds, format, requests, private, title];
}

class BookingRequestFields {
  static const String playerId = 'playerId';
  static const String status = 'status';

  static const List<String> allFields = [
    playerId,
    status,
  ];
}

class BookingRestrictionsFields {
  static const utrVerified = 'utrVerified';
  static const utrGt = 'utrGt';
  static const utrLt = 'utrLt';

  static const List<String> allFields = [
    utrVerified,
    utrGt,
    utrLt,
  ];
}
