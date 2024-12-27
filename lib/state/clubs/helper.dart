import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/index.dart';
import 'index.dart';

List<Club> loadClubsFromDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> documents) {
  return documents.map((doc) {
    final data = doc.data();
    final club = Club.fromJson(data);
    return club;
  }).toList();
}

List<Booking> loadBookingsFromDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> documents) {
  return documents.map((doc) {
    final data = doc.data();
    final booking = Booking.fromJson(data);
    return booking;
  }).toList();
}
