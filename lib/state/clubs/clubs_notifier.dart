import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../global_helpers/index.dart';
import '../../models/index.dart';
import 'index.dart';

class ClubsNotifier extends StateNotifier<List<Club>> {
  ClubsNotifier() : super([]);
  final clubsCollection = FirebaseFirestore.instance.collection(FirestoreCollection.clubs);
  final storageRef = FirebaseStorage.instance.ref();
  final queriesMade = <String>[];

  // ^ Temporarily loading all clubs and courts and bookings
  // void loadAllClubs() async {
  //   // * Getting firebase data
  //   final querySnapshot = await clubsCollection.get();
  //   final docs = querySnapshot.docs;
  //   if (docs.isNotEmpty) {
  //     // * Transform to Clubs class
  //     final clubs = loadClubsFromDocs(docs);

  //     // * Getting courts data
  //     for (final doc in docs) {
  //       final clubId = doc.id;
  //       final courts = await clubsCollection.doc(clubId).collection(CourtsSubCollections.courts).get();
  //       final club = findByIdOrNull<Club>(clubs, clubId);
  //       if (club == null) {
  //         continue;
  //       }
  //       // * Load Courts to club in data class
  //       club.loadCourts(courts.docs);
  //     }
  //     // * Load Bookings to courts in data class
  //     for (final club in clubs) {
  //       for (final court in club.courts) {
  //         await loadBookings(club, court);
  //       }
  //     }

  //     state = clubs;
  //     return;
  //   }
  //   // * If no data is found
  //   state = [];
  // }

  Future<void> loadClubs() async {
    // * Getting firebase data
    final querySnapshot = await clubsCollection.get();
    final docs = querySnapshot.docs;
    if (docs.isNotEmpty) {
      // * Transform to Clubs class
      final clubs = loadClubsFromDocs(docs);
      state = clubs;
      return;
    }
    // * If no data is found
    state = [];
  }

  Future<void> loadClub(String clubId) async {
    // * Getting firebase data
    final doc = await clubsCollection.doc(clubId).get();
    if (doc.exists) {
      // * Transform to Clubs class
      final club = loadClubFromDoc(doc);
      if (club != null) state = [...state, club];
      return;
    }
    // * If no data is found
    state = [];
  }

  Future<void> loadCourts(Club club) async {
    final querySnapshot = await clubsCollection.doc(club.id).collection(CourtsSubCollections.courts).get();
    final courtsDocs = querySnapshot.docs;
    if (courtsDocs.isNotEmpty) {
      // * Load Courts to club in data class
      club.loadCourtsFromDocs(courtsDocs);
      state = [...state];
    }
  }

  Future<void> loadBookings(Club club, Court court, DateTime date) async {
    final (startDate, endDate) = getStartAndEndOfWeek(date);
    final startDateEpoch = fromDateToEpoch(startDate);
    final endDateEpoch = fromDateToEpoch(endDate);

    final query = clubsCollection
        .doc(club.id)
        .collection(CourtsSubCollections.courts)
        .doc(court.id)
        .collection(BookingsSubCollections.publicBookings)
        .where(BookingFields.from, isGreaterThan: startDateEpoch)
        .where(BookingFields.to, isLessThan: endDateEpoch);

    String queryParams = query.parameters.toString();
    queryParams += 'courtId: ${court.id}, clubId: ${club.id}';

    if (queriesMade.contains(queryParams)) {
      return;
    }

    queriesMade.add(queryParams);

    court.tbLogger('MAKING QUERY', DebugLevel.warning);
    final querySnapshot = await query.get();

    final bookingsDocs = querySnapshot.docs;
    if (bookingsDocs.isNotEmpty) {
      final bookings = loadBookingsFromDocs(bookingsDocs);
      court.loadBookings(bookings);
      state = [...state];
      return;
    }
    // * If no data is found
    court.loadBookings([]);
    state = [...state];
    return;
  }
}
