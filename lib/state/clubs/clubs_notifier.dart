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

  void loadClubs() async {
    // * Getting firebase data
    final querySnapshot = await clubsCollection.get();
    final docs = querySnapshot.docs;
    if (docs.isNotEmpty) {
      // * Transform to Clubs class
      final clubs = loadClubsFromDocs(docs);

      // * Getting courts data
      for (final doc in docs) {
        final clubId = doc.id;
        final courts = await clubsCollection.doc(clubId).collection(CourtsSubCollections.courts).get();
        final club = findByIdOrNull<Club>(clubs, clubId);
        if (club == null) {
          continue;
        }
        // * Load Courts to club in data class
        club.loadCourts(courts.docs);
      }
      // * Load Bookings to courts in data class
      for (final club in clubs) {
        for (final court in club.courts) {
          await loadBookings(club, court);
        }
      }

      state = clubs;
      return;
    }
    // * If no data is found
    state = [];
  }

  Future<void> loadBookings(Club club, Court court) async {
    final querySnapshot = await clubsCollection
        .doc(club.id)
        .collection(CourtsSubCollections.courts)
        .doc(court.id)
        .collection(BookingsSubCollections.publicBookings)
        .get();
    final docs = querySnapshot.docs;
    if (docs.isNotEmpty) {
      final bookings = loadBookingsFromDocs(docs);
      court.loadBookings(bookings);
    }
  }
}
