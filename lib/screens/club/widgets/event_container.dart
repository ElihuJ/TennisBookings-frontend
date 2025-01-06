import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../global_widgets/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';

class EventContainer extends HookConsumerWidget {
  const EventContainer({
    super.key,
    required this.events,
  });

  final List<CalendarEventData<Booking>> events;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    final booking = events.first.event!;
    final players = booking.confirmedPlayerIds;
    final isBooked = booking.status == BookingStatus.confirmed;
    final owned = booking.ownerId == user.uid;
    final isClickable = owned || !isBooked;

    // * Computing colours
    Color bookingColor = owned ? AppColors.primaryGreen : AppColors.darkGreen;
    if (!isBooked) {
      // if (true) {
      bookingColor = AppColors.brightYellow;
    }

    final bookingLengthEpoch = booking.to - booking.from;

    final bookingLessThanAnHour = bookingLengthEpoch < 3600;

    final computedTextColor = getContrastColor(bookingColor);
    final fontSize = bookingLessThanAnHour ? 10.0 : 14.0;

    return MouseRegion(
      cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: () {
          if (isClickable && user.uid.isEmpty) {
            showLoginSignupModal(context);
            return;
          }
          if (events.first.event!.ownerId == user.uid) {
            showDialog(context: context, builder: (context) => AlertDialog(content: Text('You are the owner')));
            return;
          }
          if (isClickable) {
            showDialog(context: context, builder: (context) => AlertDialog(content: Text('You can\'t book this event')));
            return;
          }
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: bookingColor,
            border: Border.all(
              color: Colors.black,
              style: BorderStyle.solid,
            ),
          ),
          height: 100,
          width: 100,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrettyText(
                  '${events.first.title}\n${events.first.description}',
                  style: TextStyle(color: computedTextColor, fontSize: fontSize),
                  textAlign: TextAlign.left,
                ),
                PrettyText('(${booking.format.name})', style: TextStyle(color: computedTextColor, fontSize: fontSize), textAlign: TextAlign.left),
                SizedBox(height: 20),
                for (final player in players)
                  CircleAvatar(
                    backgroundColor: AppColors.backgroundGreen,
                    child: Icon(
                      Icons.person,
                      color: AppColors.primaryGreen,
                    ),
                  ),
              ],
            ),
          ),
          // child: Text(events.first.title),
        ),
      ),
    );
  }
}
