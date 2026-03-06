import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' show Stripe;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../cloud_functions/cloud_functions_provider.dart';
import '../../../cloud_functions/dto/get_casual_payment_intent.dart';
import '../../../cloud_functions/types.dart';
import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../index.dart';
import '../widget/casual_booking.dart';
import '../widget/stripe_casual_payment.dart';

enum _ViewMode {
  booking,
  payment,
}

class CreateCasualBookingModal extends StatefulHookConsumerWidget {
  const CreateCasualBookingModal(
      {super.key,
      required this.clubSelected,
      required this.courtSelected,
      required this.date,
      required this.bookedTimes,
      required this.context});
  final Club clubSelected;
  final Court courtSelected;
  final DateTime date;
  final List<BookedTimeEpoch> bookedTimes;
  final BuildContext context; // This is a workaround to avoid passing context in the constructor

  @override
  ConsumerState<CreateCasualBookingModal> createState() => _CreateCasualBookingModalState();
}

class _CreateCasualBookingModalState extends ConsumerState<CreateCasualBookingModal> {
  _ViewMode _viewMode = _ViewMode.booking;
  Booking? _booking;
  late Future<CFResult<GetCasualPaymentIntentResponseData>> getCasualPaymentIntent;

  @override
  void initState() {
    super.initState();
  }

  void proceedToPayment(Booking booking) {
    setState(() {
      _viewMode = _viewMode == _ViewMode.booking ? _ViewMode.payment : _ViewMode.booking;
      _booking = booking;
      getCasualPaymentIntent = ref.read(cloudFunctionsProvider.notifier).getCasualPaymentIntent(booking: booking);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateString = prettyDateUtcFromEpoch(widget.date.millisecondsSinceEpoch);

    return EventfulWidget(
      child: AlertDialog(
        title: PrettyText(
          '${widget.courtSelected.name} Casual Booking \n$dateString',
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          width: 500,
          child: _viewMode == _ViewMode.booking
              ? CasualBooking(
                  clubSelected: widget.clubSelected,
                  courtSelected: widget.courtSelected,
                  date: widget.date,
                  confirmedBookedTimes: widget.bookedTimes,
                  context: context,
                  proceedToPayment: proceedToPayment,
                )
              : FutureBuilder(
                  future: getCasualPaymentIntent,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: 300,
                        child: LoadingScreen(
                          message: 'Loading payment data...',
                          noScaffold: true,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      snapshot.error?.tbLogger('Error loading club payment data');
                      return const NotFoundScreen(
                        message: 'Error loading club payment data',
                        noScaffold: true,
                      );
                    }
                    final response = snapshot.data?.data;
                    if (response == null) {
                      'Client secret is null'.tbLogger();
                      return const NotFoundScreen(
                        message: 'Error loading club payment data',
                        noScaffold: true,
                      );
                    }

                    Stripe.stripeAccountId = response.clubStripeAccountId; // Default account ID

                    return FutureBuilder(
                      future: Stripe.instance.applySettings(),
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                          return SizedBox(
                            height: 300,
                            child: LoadingScreen(
                              message: 'Initializing payment form...',
                              noScaffold: true,
                            ),
                          );
                        }
                        return StripePaymentModalForm(
                          clientSecret: response.clientSecret,
                          club: widget.clubSelected,
                          booking: _booking!,
                          court: widget.courtSelected,
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

void showCreateCasualBookingModal(
    {required BuildContext context,
    required Club clubSelected,
    required Court courtSelected,
    required DateTime date,
    required List<BookedTimeEpoch> bookedTimes}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CreateCasualBookingModal(
          clubSelected: clubSelected, courtSelected: courtSelected, date: date, bookedTimes: bookedTimes, context: context);
    },
  );
}
