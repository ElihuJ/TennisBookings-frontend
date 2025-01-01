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

Club? loadClubFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data();
  if (data == null) {
    return null;
  }
  final club = Club.fromJson(data);
  return club;
}

List<Booking> loadBookingsFromDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> documents) {
  return documents.map((doc) {
    final data = doc.data();
    if (data.isEmpty) return Booking.empty();
    final booking = Booking.fromJson(data);
    return booking;
  }).toList();
}
