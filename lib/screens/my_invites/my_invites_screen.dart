import 'package:collection/collection.dart';
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

class MyInvitesScreen extends StatefulHookConsumerWidget {
  const MyInvitesScreen({super.key});

  static const route = 'MyInvites';

  @override
  ConsumerState<MyInvitesScreen> createState() => _MyInvitesScreenState();
}

class _MyInvitesScreenState extends ConsumerState<MyInvitesScreen> {
  List<BookingWithPopulatedRequest>? _bookings;

  removeInviteFromState(BookingWithPopulatedRequest booking, BookingPopulatedRequest invite) {
    final targetBooking = _bookings!.firstWhereOrNull(
      (b) => b.id == booking.id,
    );
    if (targetBooking != null) {
      targetBooking.requests.removeWhere((r) => r.playerId == invite.playerId);
      setState(() {
        _bookings = _bookings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isLoggedIn = user.uid.isNotEmpty;

    if (!isLoggedIn) {
      return const NotFoundScreen();
    }
    final cloudFunctions = ref.read(cloudFunctionsProvider.notifier);

    if (_bookings == null) {
      cloudFunctions.getActiveOpenBookings().then((result) {
        if (result.responseStatus.code == CFResponseCode.ok) {
          setState(() {
            _bookings = result.data!;
          });
        }
      });

      return LoadingScreen(
        message: 'Loading invites...',
      );
    }

    _bookings ??= [];
    final hasInvites = _bookings?.any((booking) => booking.requests.isNotEmpty);

    return EventfulWidget(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          appBar: Header(),
          body: Center(
            child: SizedBox(
              width: sectionWidth,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    const PrettyText(
                      'My Invites',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 40),
                    if (hasInvites == false)
                      Flexible(child: _NoInvitesView())
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _bookings!.length,
                        itemBuilder: (context, index) {
                          final booking = _bookings![index];
                          // * This scenario should happen when removing an invite from state
                          if (booking.requests.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return BookingWithInvites(booking: booking, removeInviteFromState: removeInviteFromState);
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
    return Center(
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
