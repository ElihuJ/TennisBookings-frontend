import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../cloud_functions/dto/get_casual_payment_intent.dart';
import '../../../cloud_functions/types.dart';
import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../index.dart';
import '../widget/casual_booking.dart';

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
  late Future<CFResult<GetCasualPaymentIntentResponseData>> getCasualPaymentIntent;

  @override
  void initState() {
    super.initState();
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
          child: CasualBooking(
            clubSelected: widget.clubSelected,
            courtSelected: widget.courtSelected,
            date: widget.date,
            confirmedBookedTimes: widget.bookedTimes,
            context: context,
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
