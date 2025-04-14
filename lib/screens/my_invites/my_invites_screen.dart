import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../cloud_functions/index.dart';
import '../../cloud_functions/types.dart';
import '../../global_widgets/header/index.dart';
import '../../global_widgets/index.dart';
import '../../models/index.dart';
import '../../state/index.dart';
import 'widgets/booking_with_invites_container.dart';

const sectionWidth = 600.0;

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
                  return const PrettyText(
                    'Error loading bookings',
                    style: TextStyle(color: Colors.red),
                  );
                } else {
                  final bookings = snapshot.data?.data ?? [];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: sectionWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const PrettyText(
                              'My Invites',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
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
                              itemCount: bookings.length,
                              itemBuilder: (context, index) {
                                final booking = bookings[index];
                                return BookingWithInvites(booking: booking);
                              },
                            ),
                          const SizedBox(height: 16.0),
                        ],
                      ),
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
