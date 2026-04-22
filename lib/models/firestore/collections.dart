class FirestoreCollection {
  static const users = 'users';
  static const config = 'config';
  static const clubs = 'clubs';
}

class UserSubCollections {
  static const bookings = 'bookings';
}

class CourtsSubCollections {
  static const courts = 'courts';
}

class BookingsSubCollections {
  static const publicBookings = 'public_bookings';
  static const privateBookings = 'private_bookings';
}

class ConfigDocuments {
  static const versioning = 'versioning';
}
