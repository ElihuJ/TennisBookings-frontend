class UserFields {
  static const String uid = 'uid';
  static const String accountCreationDate = 'accountCreationDate';
  static const String clubIds = 'clubIds';
  static const String dob = 'dob';
  static const String email = 'email';
  static const String gender = 'gender';
  static const String homeClubId = 'homeClubId';
  static const String lastLogin = 'lastLogin';
  static const String name = 'name';
  static const String utrRating = 'utrRating';
  static const String utrVerified = 'utrVerified';
  static const String photoUrl = 'photoUrl';
  static const String memberships = 'memberships';
  static const String stripeClubDetails = 'stripeClubDetails';

  static const List<String> allFields = [
    uid,
    accountCreationDate,
    clubIds,
    dob,
    email,
    gender,
    homeClubId,
    lastLogin,
    name,
    utrRating,
    utrVerified,
    photoUrl,
    stripeClubDetails,
    memberships,
  ];
}

class UserMembershipFields {
  static const String clubId = 'clubId';
  static const String expiry = 'expiry';

  static const List<String> allFields = [
    clubId,
    expiry,
  ];
}

class StripeClubDetailsFields {
  static const String clubId = 'clubId';
  static const String stripeCustomerId = 'stripeCustomerId';
  static const String transactionIds = 'transactionIds';

  static const List<String> allFields = [
    clubId,
    stripeCustomerId,
    transactionIds,
  ];
}
