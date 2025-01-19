import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/global_types/enums.dart';

import '../../global_helpers/index.dart';
import '../../models/index.dart';
import 'index.dart';

class ClubsNotifier extends StateNotifier<List<Club>> {
  ClubsNotifier() : super([]);
  final clubsCollection = FirebaseFirestore.instance.collection(FirestoreCollection.clubs);
  final storageRef = FirebaseStorage.instance.ref();
  final publicQueriesMade = <String>[];
  final privateQueriesMade = <String>[];

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

  void addBooking({required Court court, required Booking booking, required bool isPrivate}) {
    if (isPrivate) {
      court.privateBookings?.add(booking);
      final publicBooking = booking.copyWith(
        title: 'Private Booking',
        confirmedPlayerIds: [],
      );
      court.publicBookings?.add(publicBooking);
    } else {
      court.publicBookings?.add(booking);
    }

    state = [...state];
  }

  Future<void> loadBookings(Club club, Court court, DateTime date, String uid) async {
    final (startDate, endDate) = getStartAndEndOfWeek(date);
    final startDateEpoch = dateTimeToEpochUtc(startDate);
    final endDateEpoch = dateTimeToEpochUtc(endDate);

    // ^ ============================== Loading Public Bookings ==============================
    final publicBookingsQuery = clubsCollection
        .doc(club.id)
        .collection(CourtsSubCollections.courts)
        .doc(court.id)
        .collection(BookingsSubCollections.publicBookings)
        .where(BookingFields.from, isGreaterThan: startDateEpoch)
        .where(BookingFields.to, isLessThan: endDateEpoch)
        .where(
      BookingFields.status,
      whereIn: [BookingStatus.confirmed.name, BookingStatus.open.name],
    );

    String queryParams = publicBookingsQuery.parameters.toString();
    queryParams += 'Public: courtId: ${court.id}, clubId: ${club.id}';
    final publicQueryMade = publicQueriesMade.contains(queryParams);

    if (!publicQueryMade) {
      publicQueriesMade.add(queryParams);

      final querySnapshot = await publicBookingsQuery.get();

      final bookingsDocs = querySnapshot.docs;
      if (bookingsDocs.isNotEmpty) {
        final bookings = loadBookingsFromDocs(bookingsDocs);
        court.loadPublicBookings(bookings);
      }
    }

    // ^ ============================== Loading Private Bookings ==============================
    if (uid.isNotEmpty) {
      final privateBookingsQuery = clubsCollection
          .doc(club.id)
          .collection(CourtsSubCollections.courts)
          .doc(court.id)
          .collection(BookingsSubCollections.privateBookings)
          .where(BookingFields.from, isGreaterThan: startDateEpoch)
          .where(BookingFields.to, isLessThan: endDateEpoch)
          .where(
        BookingFields.status,
        whereIn: [BookingStatus.confirmed.name, BookingStatus.open.name],
      ).where(BookingFields.ownerId, isEqualTo: uid);

      queryParams = privateBookingsQuery.parameters.toString();
      queryParams += 'Private: courtId: ${court.id}, clubId: ${club.id}';

      final privateQueryMade = privateQueriesMade.contains(queryParams);

      if (!privateQueryMade) {
        privateQueriesMade.add(queryParams);

        final querySnapshot = await privateBookingsQuery.get();

        final bookingsDocs = querySnapshot.docs;

        if (bookingsDocs.isNotEmpty) {
          final bookings = loadBookingsFromDocs(bookingsDocs);
          court.loadPrivateBookings(bookings);
        }
      }
    }

    // ^ ============================== State control ==============================

    // * If no data is found
    if (privateQueriesMade.isNotEmpty) {
      court.loadPrivateBookings([]);
    }
    court.loadPublicBookings([]);
    state = [...state];
    return;
  }

  void clearPrivateBookings() {
    for (final club in state) {
      for (final court in club.courts) {
        court.privateBookings = null;
      }
    }
    privateQueriesMade.clear();
    state = [...state];
    return;
  }
}
