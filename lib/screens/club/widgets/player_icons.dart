import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../global_types/index.dart';

import '../../../global_widgets/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';

class PlayerIcons extends HookConsumerWidget {
  const PlayerIcons({super.key, required this.confirmedPlayerIds, required this.booking, required this.clubId, required this.type});

  final List<String> confirmedPlayerIds;
  final Booking booking;
  final String clubId;
  final PlayerIconsType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userProvider).uid;
    final bookingStatus = booking.status;

    final isOwner = booking.ownerId == userId;

    final ownBooking = bookingStatus == BookingStatus.confirmed && isOwner;
    final isOpenBooking = bookingStatus == BookingStatus.open;

    final isPublicBooking = booking.private == false;

    final sourceOfPlayersData = getSourceOfPlayerData(isOpenBooking, ownBooking, isPublicBooking);

    if (isOpenBooking || ownBooking || isPublicBooking) {
      if (type == PlayerIconsType.column) {
        return ColumnOfPlayerIcons(
            confirmedPlayerIds: confirmedPlayerIds, booking: booking, clubId: clubId, sourceOfPlayersData: sourceOfPlayersData);
      }
      if (!isOpenBooking) {
        // * EVENT CONTAINERS (EXCEPT OPEN BOOKINGS)
        return RowOfPlayerIcons(confirmedPlayerIds: confirmedPlayerIds, booking: booking, clubId: clubId, sourceOfPlayerData: sourceOfPlayersData);
      }
    }
    return Container();
  }
}

SourceOfPlayerData getSourceOfPlayerData(bool isOpenBooking, bool ownBooking, bool isPublicBooking) {
  if (isOpenBooking) {
    return SourceOfPlayerData.cloudFunction;
  }
  if (ownBooking || isPublicBooking) {
    return SourceOfPlayerData.firestore;
  }
  return SourceOfPlayerData.firestore;
}

enum PlayerIconsType {
  row,
  column,
}
