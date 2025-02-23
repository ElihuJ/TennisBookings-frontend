import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../widget/closed_booking.dart';
import '../widget/open_booking.dart';

enum BookingMode { closed, open }

class CreateBookingModal extends StatefulHookConsumerWidget {
  const CreateBookingModal({super.key, required this.clubSelected, required this.courtSelected, required this.date, required this.bookedTimes});
  final Club clubSelected;
  final Court courtSelected;
  final DateTime date;
  final List<BookedTimeEpoch> bookedTimes;

  @override
  ConsumerState<CreateBookingModal> createState() => _CreateBookingModalState();
}

class _CreateBookingModalState extends ConsumerState<CreateBookingModal> {
  BookingMode _bookingMode = BookingMode.closed;

  void switchBookingMode() {
    setState(() {
      _bookingMode = _bookingMode == BookingMode.open ? BookingMode.closed : BookingMode.open;
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = _bookingMode == BookingMode.closed
        ? ClosedBooking(
            clubSelected: widget.clubSelected,
            courtSelected: widget.courtSelected,
            date: widget.date,
            switchBookingMode: switchBookingMode,
            confirmedBookedTimes: widget.bookedTimes,
            context: context,
          )
        : OpenBooking(
            clubSelected: widget.clubSelected,
            courtSelected: widget.courtSelected,
            date: widget.date,
            switchBookingMode: switchBookingMode,
            context: context,
            confirmedBookedTimes: widget.bookedTimes,
          );

    final dateString = prettyDateUtcFromEpoch(widget.date.millisecondsSinceEpoch);
    final bookingModeString = _bookingMode == BookingMode.open ? 'Searching for a player' : 'Booking';

    return AlertDialog(
      title: Text(
        '${widget.courtSelected.name} $bookingModeString \n$dateString',
        textAlign: TextAlign.center,
      ),
      content: content,
    );
  }
}

showCreateBookingModal(
    {required BuildContext context,
    required Club clubSelected,
    required Court courtSelected,
    required DateTime date,
    required List<BookedTimeEpoch> bookedTimes}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CreateBookingModal(clubSelected: clubSelected, courtSelected: courtSelected, date: date, bookedTimes: bookedTimes);
    },
  );
}
