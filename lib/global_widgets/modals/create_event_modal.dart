import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../../models/index.dart';
import '../../state/index.dart';
import 'widget/closed_booking.dart';
import 'widget/open_booking.dart';

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
            bookedTimes: widget.bookedTimes,
            context: context,
          )
        : OpenBooking(
            clubSelected: widget.clubSelected, courtSelected: widget.courtSelected, date: widget.date, switchBookingMode: switchBookingMode);

    final dateString = prettyDateFromEpoch(widget.date.millisecondsSinceEpoch);
    final bookingModeString = _bookingMode == BookingMode.open ? 'Open' : 'Closed';

    return AlertDialog(
      title: Text(
        '${widget.courtSelected.name} $bookingModeString Booking \n$dateString',
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





// enum BookingMode { public, private }

// class PrivateBooking extends StatefulHookConsumerWidget {
//   const PrivateBooking({super.key, required this.clubSelected, required this.courtSelected, required this.date, required this.setBookingMode});
//   final Club clubSelected;
//   final Court courtSelected;
//   final DateTime date;
//   final Function(BookingMode bookingMode) setBookingMode;

//   @override
//   ConsumerState<PrivateBooking> createState() => _PrivateBookingState();
// }

// class _PrivateBookingState extends ConsumerState<PrivateBooking> {
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           TextFormField(
//             decoration: InputDecoration(labelText: 'Event Name'),
//             validator: (value) {
//               if (value == null) {
//                 return 'Please enter an event name';
//               }
//               return null;
//             },
//             onSaved: (value) {},
//           ),
//           TextFormField(
//             decoration: InputDecoration(labelText: 'Event Date'),
//             onTap: () async {
//               FocusScope.of(context).requestFocus(FocusNode());
//               DateTime picked = await showDatePicker(
//                 context: context,
//                 initialDate: DateTime.now(),
//                 firstDate: DateTime(2000),
//                 lastDate: DateTime(2101),
//               ) as DateTime;
//             },
//             validator: (value) {
//               return null;
//             },
//             readOnly: true,
//             controller: TextEditingController(text: 'test'),
//           ),
//           TextFormField(
//             decoration: InputDecoration(labelText: 'Event Time'),
//             onTap: () async {
//               FocusScope.of(context).requestFocus(FocusNode());
//               TimeOfDay picked = await showTimePicker(
//                 context: context,
//                 initialTime: TimeOfDay.now(),
//               ) as TimeOfDay;
//             },
//             validator: (value) {
//               return null;
//             },
//             readOnly: true,
//             controller: TextEditingController(text: 'test2'),
//           ),
//         ],
//       ),
//     );
//   }
// }
