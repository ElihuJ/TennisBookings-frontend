import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../cloud_functions/dto/index.dart';
import '../../cloud_functions/index.dart';
import '../../cloud_functions/types.dart';
import '../../global_helpers/index.dart';
import '../../global_types/enums.dart';
import '../../models/index.dart';
import '../index.dart';
import 'helper.dart';

class ClubsNotifier extends StateNotifier<List<Club>> {
  ClubsNotifier(this.cloudFunctionsNotifier) : super([]);
  final clubsCollection = FirebaseFirestore.instance.collection(FirestoreCollection.clubs);
  final storageRef = FirebaseStorage.instance.ref();
  final publicQueriesMade = <String>[];
  final privateQueriesMade = <String>[];
  final CloudFunctionsNotifier cloudFunctionsNotifier;

  Future<void> loadClubs() async {
    // * Getting firebase data
    final querySnapshot = await clubsCollection.get();
    final docs = querySnapshot.docs;
    if (docs.isNotEmpty) {
      // * Transform to Clubs class
      final clubs = loadClubsFromDocs(docs);
      final existingClubs = state;
      if (existingClubs.isNotEmpty) {
        // * If clubs already exist, only add new clubs
        final newClubs = clubs.where((club) => !existingClubs.any((existingClub) => existingClub.id == club.id)).toList();
        state = [...existingClubs, ...newClubs];
        return;
      }
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

  void removeBooking({required Booking booking}) {
    final court = state.firstWhere((club) => club.id == booking.clubId).courts.firstWhere((court) => court.id == booking.courtId);
    if (booking.private) {
      court.privateBookings?.remove(booking);
    }
    court.publicBookings?.removeWhere((element) => element.id == booking.id);

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
    final privateQuery = 'Private: courtId: ${court.id}, clubId: ${club.id}';
    if (uid.isNotEmpty && !privateQueriesMade.contains(privateQuery)) {
      List<Booking> privateBookingsToLoad = [];
      final getPrivateBookingsPayload = GetPrivateBookingsPayload(getAll: true, clubId: club.id, courtId: court.id);
      final privateBookings = await cloudFunctionsNotifier.getPrivateBookings(getPrivateBookingsPayload);

      if (privateBookings.responseStatus.code != CFResponseCode.ok) {
        privateBookings.responseStatus.tbLogger('Failed to get private bookings');
      } else {
        privateQueriesMade.add(privateQuery);
        privateBookingsToLoad = privateBookings.data!;
      }

      court.loadPrivateBookings(privateBookingsToLoad);
    }

    // ^ ============================== State control ==============================
    // * Adding empty will make sure they are not null, it doesn't add if something already exists
    court.loadPrivateBookings([]);
    court.loadPublicBookings([]);
    state = [...state];
    return;
  }

  // * This function is only used for loading event containers (Main calendar)
  Future<List<ConfirmedPlayerData>> getPublicPlayerData({required Booking booking, required User user}) async {
    final confirmedPlayersData = <ConfirmedPlayerData>[];
    final confirmedPlayerIds = [...booking.confirmedPlayerIds, booking.ownerId];
    for (final playerId in confirmedPlayerIds) {
      // * If is my own booking do not fetch URL, I already have it
      if (playerId == user.uid) {
        confirmedPlayersData.add(ConfirmedPlayerData(id: playerId, name: user.name, photoUrl: user.photoUrl, utrVerified: user.utrVerified));
        continue;
      }
      final url = await storageRef.child('public_profiles/$playerId/profile.png').getDownloadURL();
      confirmedPlayersData.add(ConfirmedPlayerData(id: playerId, name: '', photoUrl: url, utrVerified: false));
    }
    return confirmedPlayersData;
  }

  void updateBooking({required Booking booking, required String userId}) {
    final club = state.firstWhere((club) => club.id == booking.clubId);
    final court = club.courts.firstWhere((court) => court.id == booking.courtId);

    court.publicBookings = court.publicBookings!.map((element) {
      if (element.id == booking.id) {
        return booking;
      }
      return element;
    }).toList();

    if (booking.private) {
      court.privateBookings = court.privateBookings!.map((element) {
        if (element.id == booking.id) {
          return booking;
        }
        return element;
      }).toList();
    }

    state = [...state];
  }

  Future<String> getPlayerPhotoUrl({required String playerId}) async => storageRef.child('public_profiles/$playerId/profile.png').getDownloadURL();

  Future<String> getClubName({required String clubId}) async {
    final clubData = await clubsCollection.doc(clubId).get();
    if (clubData.exists) {
      final club = loadClubFromDoc(clubData);
      return club?.name ?? '';
    }
    return '';
  }

  Future<String> getCourtName({required String clubId, required String courtId}) async {
    final courtData = await clubsCollection.doc(clubId).collection(CourtsSubCollections.courts).doc(courtId).get();
    if (courtData.exists) {
      final court = loadCourtFromDoc(courtData);
      return court?.name ?? '';
    }
    return '';
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
