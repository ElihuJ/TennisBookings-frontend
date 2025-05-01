import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_types/index.dart';
import '../../../global_widgets/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';

class PlayerIcons extends StatefulHookConsumerWidget {
  const PlayerIcons({super.key, required this.confirmedPlayerIds, required this.booking, required this.type});

  final List<String> confirmedPlayerIds;
  final Booking booking;
  final PlayerIconsType type;

  @override
  ConsumerState createState() => PlayerIconsState();
}

class PlayerIconsState extends ConsumerState<PlayerIcons> {
  late SourceOfPlayerData sourceOfPlayerData;

  @override
  void initState() {
    super.initState();
    sourceOfPlayerData = getSourceOfPlayerData(
      isOpenBooking: widget.booking.status == BookingStatus.open,
      confirmedOpenBooking: widget.booking.status == BookingStatus.confirmed && widget.booking.confirmedPlayerIds.isNotEmpty,
      type: widget.type,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userProvider).uid;
    final bookingStatus = widget.booking.status;

    final isOwner = widget.booking.ownerId == userId;
    final confirmedOpenBooking = bookingStatus == BookingStatus.confirmed && widget.booking.confirmedPlayerIds.isNotEmpty;
    final ownClosedBooking = bookingStatus == BookingStatus.confirmed && isOwner && !confirmedOpenBooking;
    final isOpenBooking = bookingStatus == BookingStatus.open;
    final isPublicBooking = widget.booking.private == false;

    if ((isOpenBooking || ownClosedBooking || isPublicBooking) && widget.type == PlayerIconsType.column) {
      return ColumnOfPlayerIcons(confirmedPlayerIds: widget.confirmedPlayerIds, booking: widget.booking, sourceOfPlayersData: sourceOfPlayerData);
    }
    if (ownClosedBooking || isPublicBooking) {
      // * EVENT CONTAINERS (MAIN CALENDAR VIEW)
      return RowOfPlayerIcons(confirmedPlayerIds: widget.confirmedPlayerIds, booking: widget.booking, sourceOfPlayerData: sourceOfPlayerData);
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
