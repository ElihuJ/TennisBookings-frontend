import 'dart:collection';

import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';

final _defaultId = getUuid();

class StripeClubDetails extends MapView<String, dynamic> implements FirestoreModel {
  final String clubId;
  final String? stripeCustomerId;
  final List<String> transactionIds;

  @override
  final List<String> allFields = StripeClubDetailsFields.allFields;

  StripeClubDetails({
    required this.clubId,
    required this.stripeCustomerId,
    required this.transactionIds,
  }) : super({
          StripeClubDetailsFields.clubId: clubId,
          StripeClubDetailsFields.stripeCustomerId: stripeCustomerId,
          StripeClubDetailsFields.transactionIds: transactionIds,
        });

  StripeClubDetails.empty()
      : this(
          clubId: _defaultId,
          stripeCustomerId: null,
          transactionIds: [],
        );

  @override
  StripeClubDetails copyWith({
    String? clubId,
    String? stripeCustomerId,
    List<String>? transactionIds,
  }) {
    return StripeClubDetails(
      clubId: clubId ?? this.clubId,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      transactionIds: transactionIds ?? this.transactionIds,
    );
  }

  @override
  FirestorePayload toJson() {
    return {
      StripeClubDetailsFields.clubId: clubId,
      StripeClubDetailsFields.stripeCustomerId: stripeCustomerId,
      StripeClubDetailsFields.transactionIds: transactionIds,
    };
  }

  @override
  String toString() {
    return 'StripeClubDetails{clubId: $clubId, stripeCustomerId: $stripeCustomerId, transactionIds: $transactionIds}';
  }

  factory StripeClubDetails.fromJson(Map<String, dynamic> json) {
    try {
      // * Verify required props

      final clubId = verifyRequiredProp<String>(
          prop: json[StripeClubDetailsFields.clubId], propName: StripeClubDetailsFields.clubId, defaultValue: _defaultId);
      final stripeCustomerId = verifyNotRequiredProp<String?>(
          prop: json[StripeClubDetailsFields.stripeCustomerId], propName: StripeClubDetailsFields.stripeCustomerId);
      final transactionIdsRaw = verifyRequiredProp<List>(
          prop: json[StripeClubDetailsFields.transactionIds], propName: StripeClubDetailsFields.transactionIds, defaultValue: []);

      final transactionIds = List<String>.from(transactionIdsRaw);

      verifyProps(json, StripeClubDetailsFields.allFields);

      return StripeClubDetails(clubId: clubId, stripeCustomerId: stripeCustomerId, transactionIds: transactionIds);
    } catch (e) {
      e.tbLogger('ERROR CONSTRUCTING USER MEMBERSHIP', DebugLevel.error);
      return StripeClubDetails.empty();
    }
  }
}
