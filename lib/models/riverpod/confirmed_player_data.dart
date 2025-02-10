import 'dart:collection';

import '../../global_types/index.dart';

import '../../global_helpers/index.dart';

class ConfirmedPlayerData extends MapView<String, dynamic> implements FirestoreModel, HasId {
  @override
  final String id;
  final String name;
  final double? utrRating;
  final bool utrVerified;
  final String photoUrl;

  @override
  final List<String> allFields = ConfirmedPlayerDataFields.values.map((e) => e.name).toList();

  ConfirmedPlayerData({required this.id, required this.name, this.utrRating, required this.utrVerified, required this.photoUrl})
      : super({
          ConfirmedPlayerDataFields.id.name: id,
          ConfirmedPlayerDataFields.name.name: name,
          ConfirmedPlayerDataFields.utrRating.name: utrRating,
          ConfirmedPlayerDataFields.utrVerified.name: utrVerified,
          ConfirmedPlayerDataFields.photoUrl.name: photoUrl,
        });

  ConfirmedPlayerData.empty()
      : this(
          id: getUuid(),
          name: '',
          utrRating: 0,
          utrVerified: false,
          photoUrl: '',
        );

  factory ConfirmedPlayerData.fromJson(Map<dynamic, dynamic> json) {
    return ConfirmedPlayerData(
      id: json[ConfirmedPlayerDataFields.id.name],
      name: json[ConfirmedPlayerDataFields.name.name],
      utrRating: json[ConfirmedPlayerDataFields.utrRating.name],
      utrVerified: json[ConfirmedPlayerDataFields.utrVerified.name],
      photoUrl: json[ConfirmedPlayerDataFields.photoUrl.name],
    );
  }

  @override
  String toString() {
    return 'ConfirmedPlayerData(id: $id, name: $name, utrRating: $utrRating, utrVerified: $utrVerified)';
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
