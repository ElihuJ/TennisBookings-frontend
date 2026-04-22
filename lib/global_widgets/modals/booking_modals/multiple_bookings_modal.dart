import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../models/index.dart';
import '../../../screens/calendar/widgets/index.dart';
import '../../../state/index.dart';
import '../../../strings/index.dart';
import '../../../theme/colors.dart';
import '../../index.dart';
import '../widget/modal_shell.dart';

class MultipleBookingsModal extends HookConsumerWidget {
  const MultipleBookingsModal({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final club = ref.watch(clubsProvider).firstWhere((club) => club.id == booking.clubId);
    final isMemberOfClub = user.memberships.any((m) => m.clubId == booking.clubId);

    return EventfulWidget(
      child: ModalShell(
        icon: Icons.calendar_month_outlined,
        title: context.localeString(BookingModalStrings.multipleTitle),
        maxWidth: 720,
        body: SizedBox(
          height: 420,
          child: CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              enlargeCenterPage: true,
              height: 420,
              viewportFraction: 0.88,
            ),
            items: booking.mergedBookings.map((b) {
              final bookingAndUserContext =
                  getBookingAndUserContext(booking: b, user: user, onlyMembers: club.onlyMembers, isMemberOfClub: isMemberOfClub);
              final bookingDetailsType = getBookingDetailsType(bookingAndUserContext);
              return BookingDetailsModal(
                booking: b,
                bookingDetailsType: bookingDetailsType,
                multipleBookingsView: true,
              );
            }).toList(),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.grey,
              side: const BorderSide(color: AppColors.borderCancel),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(context.localeString(GeneralStrings.close)),
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
