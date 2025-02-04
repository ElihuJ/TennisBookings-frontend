import 'dart:collection';

import 'package:tennisbookings/global_types/index.dart';

import '../../global_helpers/index.dart';

class ConfirmedPlayerData extends MapView<String, dynamic> implements FirestoreModel, HasId {
  @override
  final String id;
  final String name;
  final String email;
  final double? utrRating;
  final bool utrVerified;
  final String photoUrl;

  @override
  final List<String> allFields = ConfirmedPlayerDataFields.values.map((e) => e.name).toList();

  ConfirmedPlayerData({required this.id, required this.name, required this.email, this.utrRating, required this.utrVerified, required this.photoUrl})
      : super({
          ConfirmedPlayerDataFields.id.name: id,
          ConfirmedPlayerDataFields.name.name: name,
          ConfirmedPlayerDataFields.email.name: email,
          ConfirmedPlayerDataFields.utrRating.name: utrRating,
          ConfirmedPlayerDataFields.utrVerified.name: utrVerified,
          ConfirmedPlayerDataFields.photoUrl.name: photoUrl,
        });

  ConfirmedPlayerData.empty()
      : this(
          id: getUuid(),
          name: '',
          email: '',
          utrRating: 0,
          utrVerified: false,
          photoUrl: '',
        );

  factory ConfirmedPlayerData.fromJson(Map<dynamic, dynamic> json) {
    return ConfirmedPlayerData(
      id: json[ConfirmedPlayerDataFields.id.name],
      name: json[ConfirmedPlayerDataFields.name.name],
      email: json[ConfirmedPlayerDataFields.email.name],
      utrRating: json[ConfirmedPlayerDataFields.utrRating.name],
      utrVerified: json[ConfirmedPlayerDataFields.utrVerified.name],
      photoUrl: json[ConfirmedPlayerDataFields.photoUrl.name],
    );
  }

  @override
  String toString() {
    return 'ConfirmedPlayerData(id: $id, name: $name, email: $email, utrRating: $utrRating, utrVerified: $utrVerified)';
  }

  @override
  ConfirmedPlayerData copyWith({
    String? id,
    String? name,
    String? email,
    double? utrRating,
    bool? utrVerified,
  }) {
    return ConfirmedPlayerData(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      utrRating: utrRating ?? this.utrRating,
      utrVerified: utrVerified ?? this.utrVerified,
      photoUrl: photoUrl,
    );
  }

  @override
  FirestorePayload toJson() {
    return {
      ConfirmedPlayerDataFields.id.name: id,
      ConfirmedPlayerDataFields.name.name: name,
      ConfirmedPlayerDataFields.email.name: email,
      ConfirmedPlayerDataFields.utrRating.name: utrRating,
      ConfirmedPlayerDataFields.utrVerified.name: utrVerified,
    };
  }
}

// * ===========  Fields  ===========
enum ConfirmedPlayerDataFields {
  id,
  name,
  email,
  utrRating,
  utrVerified,
  photoUrl,
}
