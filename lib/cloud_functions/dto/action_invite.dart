import 'shared/index.dart';

// Class for action invite request
class ActionInvitePayload extends BasicBookingPayload {
  final String targetPlayerId;
  final InviteAction inviteAction;
  final BasicBookingPayload basicBookingPayload;
  static final endpoint = 'actionInvite';

  ActionInvitePayload({
    required this.targetPlayerId,
    required this.inviteAction,
    required this.basicBookingPayload,
  }) : super(
          bookingId: basicBookingPayload.bookingId,
          clubId: basicBookingPayload.clubId,
          courtId: basicBookingPayload.courtId,
        );

  @override
  Map<String, dynamic> toJson() => {
        'targetPlayerId': targetPlayerId,
        'inviteAction': inviteAction.value,
        ...basicBookingPayload.toJson(),
      };
}

enum InviteAction {
  accept,
  reject;

  String get value {
    switch (this) {
      case InviteAction.accept:
        return 'accept';
      case InviteAction.reject:
        return 'reject';
    }
  }
}

// * ===========  Response  ===========

class ActionInviteResponse extends BasicResponse {
  final BasicResponse response;

  ActionInviteResponse({
    required this.response,
  }) : super(data: response.data, responseStatus: response.responseStatus);

  factory ActionInviteResponse.fromJson(Map<String, dynamic> map) {
    try {
      final response = BasicResponse.fromJson(map);
      return ActionInviteResponse(response: response);
    } catch (e) {
      throw Exception('Error parsing ActionInviteResponse: $e \n\n $map');
    }
  }
}
