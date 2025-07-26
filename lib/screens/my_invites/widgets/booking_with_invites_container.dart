import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../global_helpers/index.dart';
import '../../../global_widgets/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';
import 'request_container.dart';

class BookingWithInvites extends HookConsumerWidget {
  const BookingWithInvites({super.key, required this.booking});

  final BookingWithPopulatedRequest booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsNotifier = ref.read(clubsProvider.notifier);

    // Create a future that gets both the club name and court name
    final namesFuture = Future.wait([
      clubsNotifier.getClubName(clubId: booking.clubId),
      clubsNotifier.getCourtName(clubId: booking.clubId, courtId: booking.courtId),
    ]);

    return FutureBuilder<List<String>>(
      future: namesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          );
        }

        final clubName = snapshot.data?[0] ?? 'Unknown Club';
        final courtName = snapshot.data?[1] ?? 'Unknown Court';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BookingDetails(
                  clubName: clubName,
                  courtName: courtName,
                  booking: booking,
                ),
                ...booking.requests.map((request) => RequestContainer(request: request, booking: booking)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BookingDetails extends StatelessWidget {
  const _BookingDetails({
    required this.clubName,
    required this.courtName,
    required this.booking,
  });

  final String clubName;
  final String courtName;
  final BookingWithPopulatedRequest booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PrettyText(
            'Booking ${booking.title}',
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          _DetailRow(
            label: 'Club',
            value: clubName,
          ),
          _DetailRow(
            label: 'Court',
            value: courtName,
          ),
          _DetailRow(
            label: 'From',
            value: prettyDateLocalWithTimeFromEpoch(booking.startTime),
          ),
          _DetailRow(
            label: 'To',
            value: prettyDateLocalWithTimeFromEpoch(booking.endTime),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PrettyText(
            '$label:  ',
            style: const TextStyle(fontSize: 14.0, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
          PrettyText(
            value,
            style: const TextStyle(fontSize: 14.0),
          ),
        ],
      ),
    );
  }
}
