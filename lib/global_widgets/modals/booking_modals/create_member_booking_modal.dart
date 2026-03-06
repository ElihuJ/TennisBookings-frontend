import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../text/index.dart';
import '../widget/closed_booking.dart';
import '../widget/open_booking.dart';

enum BookingMode { closed, open }

class CreateMemberBookingModal extends StatefulHookConsumerWidget {
  const CreateMemberBookingModal(
      {super.key,
      required this.clubSelected,
      required this.courtSelected,
      required this.date,
      required this.bookedTimes,
      required this.context});
  final Club clubSelected;
  final Court courtSelected;
  final DateTime date;
  final List<BookedTimeEpoch> bookedTimes;
  final BuildContext context; // This is a workaround to avoid passing context in the constructor

  @override
  ConsumerState<CreateMemberBookingModal> createState() => _CreateBookingModalState();
}

class _CreateBookingModalState extends ConsumerState<CreateMemberBookingModal> {
  BookingMode _bookingMode = BookingMode.closed;
  String _titleValue = 'Booking';
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  late int endDateEpoch;
  late int startDateEpoch;

  @override
  void initState() {
    super.initState();
    startTimeController.text = TimeOfDay(hour: widget.date.hour, minute: widget.date.minute).format(widget.context);
    endTimeController.text = TimeOfDay(hour: widget.date.hour + 1, minute: widget.date.minute).format(widget.context);
    DateTime startDate = DateTime(widget.date.year, widget.date.month, widget.date.day, widget.date.hour, widget.date.minute).toUtc();
    startDateEpoch = dateTimeToEpochUtc(startDate);
    endDateEpoch = dateTimeToEpochUtc(startDate.add(const Duration(hours: 1)));
  }

  void switchBookingMode() {
    setState(() {
      _bookingMode = _bookingMode == BookingMode.open ? BookingMode.closed : BookingMode.open;
      _titleValue = _bookingMode == BookingMode.closed ? 'Booking' : 'Looking for a player';
    });
  }

  void setTitleValue(String value) {
    setState(() {
      _titleValue = value;
    });
  }

  void setStartDateEpoch(int value) {
    setState(() {
      startDateEpoch = value;
    });
  }

  void setEndDateEpoch(int value) {
    setState(() {
      endDateEpoch = value;
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
            setTitleValue: setTitleValue,
            titleValue: _titleValue,
            startTimeController: startTimeController,
            endTimeController: endTimeController,
            startDateEpoch: startDateEpoch,
            endDateEpoch: endDateEpoch,
            setStartDateEpoch: setStartDateEpoch,
            setEndDateEpoch: setEndDateEpoch,
          )
        : OpenBooking(
            clubSelected: widget.clubSelected,
            courtSelected: widget.courtSelected,
            date: widget.date,
            switchBookingMode: switchBookingMode,
            context: context,
            confirmedBookedTimes: widget.bookedTimes,
            setTitleValue: setTitleValue,
            titleValue: _titleValue,
            startTimeController: startTimeController,
            endTimeController: endTimeController,
            startDateEpoch: startDateEpoch,
            endDateEpoch: endDateEpoch,
            setStartDateEpoch: setStartDateEpoch,
            setEndDateEpoch: setEndDateEpoch,
          );

    final dateString = prettyDateUtcFromEpoch(widget.date.millisecondsSinceEpoch);
    final bookingModeString = _bookingMode == BookingMode.open ? 'Searching for a player' : 'Booking';

    return AlertDialog(
      title: PrettyText(
        '${widget.courtSelected.name} $bookingModeString \n$dateString',
        textAlign: TextAlign.center,
      ),
      content: content,
    );
  }
}

void showCreateMemberBookingModal(
    {required BuildContext context,
    required Club clubSelected,
    required Court courtSelected,
    required DateTime date,
    required List<BookedTimeEpoch> bookedTimes}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CreateMemberBookingModal(
          clubSelected: clubSelected, courtSelected: courtSelected, date: date, bookedTimes: bookedTimes, context: context);
    },
  );
}
