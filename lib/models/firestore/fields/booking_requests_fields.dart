class BookingFields {
  static const String id = 'id';
  static const String courtId = 'courtId';
  static const String ownerId = 'ownerId';
  static const String startTime = 'startTime';
  static const String endTime = 'endTime';
  static const String status = 'status';
  static const String restrictions = 'restrictions';
  static const String confirmedPlayerIds = 'confirmedPlayerIds';
  static const String format = 'format';
  static const String requests = 'requests';
  static const String private = 'private';
  static const String title = 'title';
  static const String clubId = 'clubId';
  static const String clubName = 'clubName';
  static const String courtName = 'courtName';

  static const List<String> allFields = [
    id,
    courtId,
    ownerId,
    startTime,
    endTime,
    status,
    restrictions,
    confirmedPlayerIds,
    format,
    requests,
    private,
    title,
    clubId,
    clubName,
    courtName
  ];
}

class BookingRequestFields {
  static const String playerId = 'playerId';
  static const String status = 'status';

  static const List<String> allFields = [
    playerId,
    status,
  ];
}

class BookingPopulatedRequestFields {
  // Populated fields
  static const String playerId = BookingRequestFields.playerId;
  static const String status = BookingRequestFields.status;
  static const String playerName = 'playerName';
  static const String playerUtrRating = 'playerUtrRating';
  static const String playerUtrVerified = 'playerUtrVerified';
  static const String playerGender = 'playerGender';

  static const List<String> allFields = [
    playerName,
    playerUtrRating,
    playerUtrVerified,
    playerGender,
    ...BookingRequestFields.allFields,
  ];
}

class BookingRestrictionsFields {
  static const utrVerified = 'utrVerified';
  static const utrGt = 'utrGt';
  static const utrLt = 'utrLt';
  static const gender = 'gender';

  static const List<String> allFields = [
    utrVerified,
    utrGt,
    utrLt,
    gender,
  ];
}
