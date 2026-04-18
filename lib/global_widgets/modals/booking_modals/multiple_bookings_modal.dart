import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../models/index.dart';
import '../../../screens/calendar/widgets/index.dart';
import '../../../state/index.dart';
import '../../../strings/index.dart';
import '../../../theme/index.dart';
import '../../index.dart';

class MultipleBookingsModal extends HookConsumerWidget {
  const MultipleBookingsModal({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final club = ref.watch(clubsProvider).firstWhere((club) => club.id == booking.clubId);
    final isMemberOfClub = user.memberships.any((membership) => membership.clubId == booking.clubId);
    return EventfulWidget(
      child: AlertDialog(
        title: PrettyText(context.localeString(BookingModalStrings.multipleTitle), textAlign: TextAlign.center),
        content: Container(
          color: AppColors.blue.withAlpha(30),
          width: 700,
          height: 400,
          child: CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              enlargeCenterPage: true,
              height: 800, // * Max Height of content box in carousel, not including title and buttons
            ),
            items: booking.mergedBookings.map((booking) {
              final bookingAndUserContext =
                  getBookingAndUserContext(booking: booking, user: user, onlyMembers: club.onlyMembers, isMemberOfClub: isMemberOfClub);
              final bookingDetailsType = getBookingDetailsType(bookingAndUserContext);
              return BookingDetailsModal(
                booking: booking,
                bookingDetailsType: bookingDetailsType,
                multipleBookingsView: true,
              );
            }).toList(),
          ),
        ),
        actions: <Widget>[
          TbTextButton(
            text: context.localeString(GeneralStrings.close),
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.grey,
          ),
        ],
      ),
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
