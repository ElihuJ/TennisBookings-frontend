import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../models/index.dart';
import '../../../screens/club/widgets/index.dart';
import '../../../state/index.dart';
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
        title: const Text('Multiple Open bookings (Swipe across)', textAlign: TextAlign.center),
        content: SizedBox(
          width: 700,
          child: CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: booking.mergedBookings.map((booking) {
                final bookingAndUserContext = getBookingAndUserContext(
                    booking: booking, user: user, allowsPublicBookings: club.allowPublicBookings, isMemberOfClub: isMemberOfClub);
                final bookingDetailsType = getBookingDetailsType(bookingAndUserContext);
                return SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(0),
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: AppColors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: BookingDetailsModal(
                      booking: booking,
                      bookingDetailsType: bookingDetailsType,
                      multipleBookingsView: true,
                    ),
                  ),
                );
              }).toList()),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
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
