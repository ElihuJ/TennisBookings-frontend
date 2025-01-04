import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

import '../../../models/index.dart';

class EventContainer extends StatelessWidget {
  const EventContainer({
    super.key,
    required this.events,
  });

  final List<CalendarEventData<Booking?>> events;

  @override
  Widget build(BuildContext context) {
    final booking = events.first.event;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.red,
        border: Border.all(
          color: Colors.black,
          style: BorderStyle.solid,
        ),
      ),
      height: 100,
      width: 100,
      child: Text('${events.first.title}\n${events.first.description}'),
      // child: Text(events.first.title),
    );
  }
}
