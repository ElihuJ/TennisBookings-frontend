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
    final querySnapshot = await clubsCollection.get();
    final docs = querySnapshot.docs;
    if (docs.isNotEmpty) {
      final clubs = loadClubsFromDocs(docs);
      for (final doc in docs) {
        final clubId = doc.id;
        final courts = await clubsCollection.doc(clubId).collection(CourtsSubCollections.courts).get();
        final club = findByIdOrNull<Club>(clubs, clubId);
        if (club != null) {
          club.loadCourts(courts.docs);
        }
      }
      state = clubs;
      return;
    }
    state = [];
  }
}
