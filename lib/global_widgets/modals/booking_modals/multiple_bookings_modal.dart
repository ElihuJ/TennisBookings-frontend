import 'package:flutter/material.dart';
import '../../../models/index.dart';

class MultipleBookingsModal extends StatelessWidget {
  const MultipleBookingsModal({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Multiple bookings'),
      content: const Text('This booking is a merged booking. You can book multiple slots at once.'),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

void showMultipleBookingsModal({required BuildContext context, required Booking booking}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return MultipleBookingsModal(booking: booking);
    },
  );
}
