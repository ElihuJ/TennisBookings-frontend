import 'dart:collection';

import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';

final _defaultId = getUuid();

class UserMembership extends MapView<String, dynamic> implements FirestoreModel {
  final String clubId;
  final int expiry;

  @override
  final List<String> allFields = UserMembershipFields.allFields;

  UserMembership({
    required this.clubId,
    required this.expiry,
  }) : super({
          UserMembershipFields.clubId: clubId,
          UserMembershipFields.expiry: expiry,
        });

  UserMembership.empty()
      : this(
          clubId: _defaultId,
          expiry: 0,
        );

  @override
  UserMembership copyWith({
    String? clubId,
    int? expiry,
  }) {
    return UserMembership(
      clubId: clubId ?? this.clubId,
      expiry: expiry ?? this.expiry,
    );
  }

  @override
  FirestorePayload toJson() {
    return {
      UserMembershipFields.clubId: clubId,
      UserMembershipFields.expiry: expiry,
    };
  }

  @override
  String toString() {
    return 'UserMembership{clubId: $clubId, expiry: $expiry}';
  }

  factory UserMembership.fromJson(Map<String, dynamic> json) {
    try {
      // * Verify required props

      final clubId = verifyRequiredProp<String>(
          prop: json[UserMembershipFields.clubId], propName: UserMembershipFields.clubId, defaultValue: _defaultId);
      final expiry =
          verifyRequiredProp<int>(prop: json[UserMembershipFields.expiry], propName: UserMembershipFields.expiry, defaultValue: 0);

      verifyProps(json, UserMembershipFields.allFields);

      return UserMembership(clubId: clubId, expiry: expiry);
    } catch (e) {
      e.tbLogger('ERROR CONSTRUCTING USER MEMBERSHIP', DebugLevel.error);
      return UserMembership.empty();
    }
  }
}
