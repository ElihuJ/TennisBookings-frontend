import 'dart:collection';

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../index.dart';

final defaultBookingRequestId = getUuid();

class BookingRequest extends MapView<String, dynamic> implements FirestoreModel {
  final String playerId;
  final BookingRequestStatus status;

  @override
  final List<String> allFields = BookingRequestFields.allFields;

  BookingRequest({
    required this.playerId,
    required this.status,
  }) : super({
          BookingRequestFields.playerId: playerId,
          BookingRequestFields.status: status,
        });

  BookingRequest.empty()
      : this(
          playerId: defaultBookingRequestId,
          status: BookingRequestStatus.pending,
        );

  @override
  BookingRequest copyWith({
    String? playerId,
    BookingRequestStatus? status,
  }) {
    return BookingRequest(
      playerId: playerId ?? this.playerId,
      status: status ?? this.status,
    );
  }

  @override
  FirestorePayload toJson() {
    return {
      BookingRequestFields.playerId: playerId,
      BookingRequestFields.status: status.name,
    };
  }

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    try {
      // * Verify required props
      final playerId = verifyRequiredProp<String>(
          prop: json[BookingRequestFields.playerId], propName: BookingRequestFields.playerId, defaultValue: defaultBookingRequestId);
      final status = BookingRequestStatus.fromString(json[BookingRequestFields.status]);

      verifyProps(json, BookingRequestFields.allFields);

      return BookingRequest(
        playerId: playerId,
        status: status,
      );
    } catch (e) {
      e.tbLogger('ERROR CONSTRUCTING BOOKING REQUEST', DebugLevel.error);
      return BookingRequest.empty();
    }
  }
}

/*
* This class extends BookingRequest and adds additional fields which are the private data of the player that requested
* to join the booking 
*/
class PopulatedRequest extends BookingRequest {
  final String playerName;
  final double? playerUtrRating;
  final bool playerUtrVerified;
  final Gender playerGender;

  @override
  List<String> get allFields => BookingRequestFields.allFields;

  PopulatedRequest({
    required this.playerName,
    this.playerUtrRating,
    required this.playerUtrVerified,
    required this.playerGender,
    required super.playerId,
    required super.status,
  });

  PopulatedRequest.empty()
      : this(
            playerGender: Gender.unknown,
            playerName: '',
            playerUtrRating: null,
            playerUtrVerified: false,
            playerId: defaultBookingRequestId,
            status: BookingRequestStatus.unknown);

  @override
  PopulatedRequest copyWith({
    String? playerId,
    BookingRequestStatus? status,
    String? playerName,
    double? playerUtrRating,
    Gender? playerGender,
    bool? playerUtrVerified,
  }) {
    return PopulatedRequest(
      playerId: playerId ?? this.playerId,
      status: status ?? this.status,
      playerName: playerName ?? this.playerName,
      playerUtrRating: playerUtrRating ?? this.playerUtrRating,
      playerUtrVerified: playerUtrVerified ?? this.playerUtrVerified,
      playerGender: playerGender ?? this.playerGender,
    );
  }

  @override
  FirestorePayload toJson() {
    return {
      BookingPopulatedRequestFields.playerId: playerId,
      BookingPopulatedRequestFields.status: status.name,
      BookingPopulatedRequestFields.playerName: playerName,
      BookingPopulatedRequestFields.playerUtrRating: playerUtrRating,
      BookingPopulatedRequestFields.playerUtrVerified: playerUtrVerified,
      BookingPopulatedRequestFields.playerGender: playerGender.name,
    };
  }

  factory PopulatedRequest.fromJson(Map<String, dynamic> json) {
    try {
      // * Verify required props
      final playerId = verifyRequiredProp<String>(
          prop: json[BookingPopulatedRequestFields.playerId],
          propName: BookingPopulatedRequestFields.playerId,
          defaultValue: defaultBookingRequestId);
      final status = BookingRequestStatus.fromString(json[BookingRequestFields.status]);
      final playerName = verifyRequiredProp<String>(
          prop: json[BookingPopulatedRequestFields.playerName], propName: BookingPopulatedRequestFields.playerName, defaultValue: '');
      final playerUtrRating = verifyNotRequiredProp<double?>(
          prop: json[BookingPopulatedRequestFields.playerUtrRating], propName: BookingPopulatedRequestFields.playerUtrRating);

      final playerUtrVerified = verifyRequiredProp<bool>(
          prop: json[BookingPopulatedRequestFields.playerUtrVerified],
          propName: BookingPopulatedRequestFields.playerUtrVerified,
          defaultValue: false);
      final genderRaw = verifyRequiredProp<String>(
          prop: json[BookingPopulatedRequestFields.playerGender],
          propName: BookingPopulatedRequestFields.playerGender,
          defaultValue: Gender.unknown.name);

      final playerGender = Gender.values.firstWhere(
        (g) => g.name == genderRaw,
        orElse: () => Gender.unknown,
      );

      verifyProps(json, BookingPopulatedRequestFields.allFields);

      // Debug print all props
      final booking = PopulatedRequest(
        playerId: playerId,
        status: status,
        playerName: playerName,
        playerUtrRating: playerUtrRating,
        playerUtrVerified: playerUtrVerified,
        playerGender: playerGender,
      );

      return booking;
    } catch (e) {
      e.tbLogger('ERROR CONSTRUCTING BOOKING REQUEST', DebugLevel.error);
      return PopulatedRequest.empty();
    }
  }

  @override
  String toString() {
    return 'BookingPopulatedRequest(playerId: $playerId, status: $status, playerName: $playerName, playerUtrRating: $playerUtrRating, playerUtrVerified: $playerUtrVerified, playerGender: $playerGender)';
  }
}
