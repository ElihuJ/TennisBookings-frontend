import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../global_helpers/index.dart';
import '../../global_widgets/index.dart';
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
    final mobileView = isMobile(context);
    final fontSize = getFontSize(mobileView);

    if (!isLoggedIn) {
      return const NotFoundScreen();
    }

    final bookingsWithInvites = user.bookingsWithPopulatedRequests;

    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: TbScaffold(
          body: Center(
            child: SizedBox(
              width: sectionWidth,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    PrettyText(
                      'My Invites',
                      style: TextStyle(
                        fontSize: fontSize + 6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (bookingsWithInvites.isEmpty)
                      _NoInvitesView()
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: bookingsWithInvites.length,
                        itemBuilder: (context, index) {
                          final booking = bookingsWithInvites[index];
                          // * This scenario should happen when removing an invite from state
                          if (booking.requests.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return BookingWithInvites(booking: booking);
                        },
                      ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoInvitesView extends StatelessWidget {
  const _NoInvitesView();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(32.0),
      child: MessageCard(
        icon: Icon(
          Icons.mail_outline,
          size: 48.0,
          color: Colors.blueGrey[300],
        ),
        title: 'No Invites',
        description: 'You have no invites at the moment.',
      ),
    );
  }
}
