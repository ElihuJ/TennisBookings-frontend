import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../cloud_functions/index.dart';
import '../../cloud_functions/types.dart';
import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../../models/index.dart';
import 'index.dart';

typedef NewUrl = String?;

class UserNotifier extends StateNotifier<User> {
  final CloudFunctionsNotifier cloudFunctionsNotifier;
  UserNotifier({required this.cloudFunctionsNotifier}) : super(User.empty());
  final usersCollection = FirebaseFirestore.instance.collection(FirestoreCollection.users);
  final storageRef = FirebaseStorage.instance.ref();

  String get userId => state.uid;

  void loadUser({required String uid}) async {
    final doc = await usersCollection.doc(uid).get();
    if (doc.exists) {
      final data = doc.data() as FirestoreResponse;
      state = User.fromJson(data);

      final bookingsSnap = await usersCollection.doc(uid).collection(UserSubCollections.bookings).get();
      final bookings = bookingsSnap.docs.map((doc) => Booking.fromJson(Map<String, dynamic>.from(doc.data()))).toList();
      state = state.copyWith(bookings: bookings);

      cloudFunctionsNotifier.getActiveOpenBookings().then((result) {
        if (result.responseStatus.code == CFResponseCode.ok) {
          setBookingsWithPopulatedRequests(requests: result.data!);
        }
      });
    }
  }

  void setBookingsWithPopulatedRequests({required List<BookingWithPopulatedRequest> requests}) async {
    state = state.copyWith(bookingsWithPopulatedRequests: requests);
  }

  FirestoreActionResult<Success> createUser(
      {String? name, required String uid, required String? email, ResultHandler? resultHandler}) async {
    final errorHandler = resultHandler ?? ResultHandler(success: true);
    try {
      final dateNowAsInt = nowToEpochUtc();
      User user = User(
        uid: uid,
        name: name ?? '',
        email: email ?? '',
        accountCreationDate: dateNowAsInt,
        lastLogin: dateNowAsInt,
        bookings: [],
        dob: 0,
        gender: Gender.unknown,
        photoUrl: '',
        utrVerified: false,
        memberships: [],
        stripeClubDetails: [],
      );
      final FirestorePayload userPayload = user.toJson();
      await usersCollection.doc(uid).set(userPayload);
    } catch (error) {
      errorHandler.handleError(
        errorMessage: 'Failed creating user', // ? TO TRANSLATE
        error: error,
      );
    }
    return errorHandler.result;
  }

  FirestoreActionResult<NewUrl> uploadProfilePhoto({required Uint8List imageBytes, ResultHandler? resultHandler}) async {
    final localResultHandler = resultHandler ?? ResultHandler();
    try {
      // * Upload image to storage
      final photoLocation = 'public_profiles/${state.uid}/profile.png';
      final ref = storageRef.child(photoLocation);
      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/png',
        ),
      );
      final snapshot = await uploadTask.whenComplete(
        () => null,
      );
      final url = await snapshot.ref.getDownloadURL();
      return (url, null);
    } catch (error) {
      localResultHandler.handleError(errorMessage: 'Failed uploading Image', error: error);
    }
    return (null, localResultHandler.error);
  }

  void updateUser({required User user}) async {
    final dateNowAsInt = nowToEpochUtc();
    state = user.copyWith(gender: user.gender, dob: user.dob, name: user.name, photoUrl: user.photoUrl, lastLogin: dateNowAsInt);
  }

  void addUserBooking(Booking booking) {
    state = state.copyWith(bookings: [...state.bookings, booking]);
  }

  void updateUserBooking(Booking booking) {
    state = state.copyWith(
      bookings: state.bookings.map((b) => b.id == booking.id ? booking : b).toList(),
    );
  }

  void removeBooking(String bookingId) {
    state = state.copyWith(
      bookings: state.bookings.where((b) => b.id != bookingId).toList(),
    );
  }
}
