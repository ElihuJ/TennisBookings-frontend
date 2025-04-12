import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/cloud_functions/types.dart';
import 'package:tennisbookings/global_helpers/index.dart';
import 'package:tennisbookings/models/index.dart';

import '../../cloud_functions/index.dart';
import '../../global_widgets/header/index.dart';
import '../../global_widgets/index.dart';
import '../../state/index.dart';

class MyInvitesScreen extends HookConsumerWidget {
  const MyInvitesScreen({super.key});

  static const route = 'MyInvites';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isLoggedIn = user.uid.isNotEmpty;

    if (!isLoggedIn) {
      return const NotFoundScreen();
    }
    final cloudFunctions = ref.read(cloudFunctionsProvider.notifier);

    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          appBar: Header(),
          body: Center(
            child: FutureBuilder<CFResult<List<BookingWithPopulatedRequest>>>(
              future: cloudFunctions.getActiveOpenBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingBox(
                    title: 'Loading invites...',
                  );
                } else if (snapshot.hasError) {
                  tbLogger('MyInvitesScreen error loading bookings: ${snapshot.error}');
                  return const PrettyText(
                    'Error loading bookings',
                    style: TextStyle(color: Colors.red),
                  );
                } else {
                  final bookings = snapshot.data?.data ?? [];

                  bookings.tbLogger('MyInvitesScreen bookings: ${bookings.length}');

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const PrettyText(
                          'My Invites',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        if (bookings.isEmpty)
                          const PrettyText(
                            'You have no invites',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                          )
                        else
                          // Display your invites here
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: bookings.length,
                            itemBuilder: (context, index) {
                              final booking = bookings[index];
                              return InviteContainer(booking: booking);
                            },
                          ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class InviteContainer extends StatelessWidget {
  const InviteContainer({
    super.key,
    required this.booking,
  });

  final BookingWithPopulatedRequest booking;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(booking.title),
      subtitle: booking.requests.length > 0 ? Text('Requests: ${booking.requests.length}') : const Text('No requests'),
      // Add more details based on your invite model
    );
  }
}
