import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

import '../../../global_helpers/index.dart';
import '../../../global_widgets/containers/index.dart';
import '../../../models/index.dart';
import '../../../theme/index.dart';

class LoadingCalendarView extends StatelessWidget {
  const LoadingCalendarView({super.key, required this.dateInView});

  final DateTime dateInView;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CalendarControllerProvider<Booking>(
          controller: EventController(),
          child: Container(
            margin: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
            height: heightPercent(context, percentage: 80),
            child: WeekView<Booking>(
              startHour: 5,
              startDay: WeekDays.sunday,
              minuteSlotSize: MinuteSlotSize.minutes60,
              hourIndicatorSettings: HourIndicatorSettings(),
              timeLineWidth: 80,
              headerStringBuilder: (date, {DateTime? secondaryDate}) =>
                  '${prettyDateUtcFromEpochMilliseconds(date.millisecondsSinceEpoch)}   ---   ${prettyDateUtcFromEpochMilliseconds(secondaryDate!.millisecondsSinceEpoch)}',
              headerStyle: HeaderStyle(
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              showLiveTimeLineInAllDays: true, // To display live time line in all pages in day view.
              initialDay: dateInView,
              heightPerMinute: 2, // height occupied by 1 minute time span.
              showHalfHours: true,
              eventArranger: SideEventArranger(), // To define how simultaneous events will be arranged.
              keepScrollOffset: true, // To maintain scroll offset when the page changes
            ),
          ),
        ),
        Positioned.fill(
          child: LoadingBox(
            title: 'Loading bookings...',
          ),
        ),
      ],
    );
  }
}
