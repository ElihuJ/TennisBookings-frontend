enum FirebaseAuthState {
  loading,
  loggedIn,
  loggedOut,
}

class FirebaseAuthErrorCode {
  static const userNotFound = 'user-not-found';
  static const wrongPassword = 'wrong-password';
  static const invalidEmail = 'invalid-email';
  static const notVerified = 'not-verified';
  static const userDisabled = 'user-disabled';
  static const emailAlreadyInUse = 'email-already-in-use';
  static const weakPassword = 'weak-password';
  static const somethingWentWrong = 'something-went-wrong'; // * Custom error

  FirebaseAuthErrorCode._();
}
