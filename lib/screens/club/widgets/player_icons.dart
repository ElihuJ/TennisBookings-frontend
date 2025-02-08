import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/global_helpers/logs.dart';
import 'package:tennisbookings/global_types/index.dart';

import '../../../global_widgets/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';

class PlayerIcons extends HookConsumerWidget {
  const PlayerIcons({super.key, required this.confirmedPlayerIds, required this.booking, required this.clubId});

  final List<String> confirmedPlayerIds;
  final Booking booking;
  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userProvider).uid;
    final bookingStatus = booking.status;

    final isOwner = booking.ownerId == userId;

    final ownBooking = bookingStatus == BookingStatus.confirmed && isOwner;
    final isOpenBooking = bookingStatus == BookingStatus.open;

    final isPublicBooking = booking.private == false;

    booking.tbLogger('PlayerIcons ownBooking: $ownBooking, isOpenBooking: $isOpenBooking, isPublicBooking: $isPublicBooking');

    if (isOpenBooking || ownBooking || isPublicBooking) {
      return RowOfPlayerIcons(
        confirmedPlayerIds: confirmedPlayerIds,
        booking: booking,
        clubId: clubId,
      );
    }
    return Container();
  }
}
