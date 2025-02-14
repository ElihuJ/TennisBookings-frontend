import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_types/index.dart';
import '../../../global_widgets/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';

class PlayerIcons extends HookConsumerWidget {
  const PlayerIcons({super.key, required this.confirmedPlayerIds, required this.booking, required this.type});

  final List<String> confirmedPlayerIds;
  final Booking booking;
  final PlayerIconsType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userProvider).uid;
    final bookingStatus = booking.status;

    final isOwner = booking.ownerId == userId;
    final confirmedOpenBooking = bookingStatus == BookingStatus.confirmed && booking.confirmedPlayerIds.isNotEmpty;
    final ownClosedBooking = bookingStatus == BookingStatus.confirmed && isOwner && !confirmedOpenBooking;
    final isOpenBooking = bookingStatus == BookingStatus.open;
    final isPublicBooking = booking.private == false;

    final sourceOfPlayersData = getSourceOfPlayerData(
      isOpenBooking: isOpenBooking,
      confirmedOpenBooking: confirmedOpenBooking,
      type: type,
    );

    if ((isOpenBooking || ownClosedBooking || isPublicBooking) && type == PlayerIconsType.column) {
      return ColumnOfPlayerIcons(confirmedPlayerIds: confirmedPlayerIds, booking: booking, sourceOfPlayersData: sourceOfPlayersData);
    }
    if (ownClosedBooking || isPublicBooking) {
      // * EVENT CONTAINERS
      return RowOfPlayerIcons(confirmedPlayerIds: confirmedPlayerIds, booking: booking, sourceOfPlayerData: sourceOfPlayersData);
    }

    return Container();
  }
}

SourceOfPlayerData getSourceOfPlayerData({
  required bool isOpenBooking,
  required bool confirmedOpenBooking,
  required PlayerIconsType type,
}) {
  SourceOfPlayerData source = SourceOfPlayerData.firestore;
  if (type == PlayerIconsType.row) {
    return source;
  }
  // * COLUMN
  if (isOpenBooking || confirmedOpenBooking) {
    source = SourceOfPlayerData.cloudFunction;
  }
  return source;
}

enum PlayerIconsType {
  row,
  column,
}
