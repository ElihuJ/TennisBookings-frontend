import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/config.dart';
import '../../../strings/index.dart';
import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';
import '../../../screens/payments/casual_payment_screen.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';
import '../../index.dart';

class CasualBooking extends StatefulHookConsumerWidget {
  const CasualBooking({
    super.key,
    required this.clubSelected,
    required this.courtSelected,
    required this.date,
    required this.context,
    required this.confirmedBookedTimes,
  });
  final Club clubSelected;
  final Court courtSelected;
  final DateTime date;
  final BuildContext context;
  final List<BookedTimeEpoch> confirmedBookedTimes;

  @override
  ConsumerState<CasualBooking> createState() => _CasualBookingState();
}

class _CasualBookingState extends ConsumerState<CasualBooking> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  BookingFormat _bookingFormat = BookingFormat.singles;
  String _visibilityValue = 'Public';
  String titleValue = 'Casual Booking';
  late int endDateEpoch;
  late int startDateEpoch;

  void Function()? submitFunction;
  Config config = Config();

  @override
  void initState() {
    super.initState();
    startTimeController.text = TimeOfDay(hour: widget.date.hour, minute: widget.date.minute).format(widget.context);
    endTimeController.text = TimeOfDay(hour: widget.date.hour + 1, minute: widget.date.minute).format(widget.context);
    DateTime startDate = DateTime(widget.date.year, widget.date.month, widget.date.day, widget.date.hour, widget.date.minute).toUtc();
    startDateEpoch = dateTimeToEpochUtc(startDate);
    endDateEpoch = dateTimeToEpochUtc(startDate.add(const Duration(hours: 1)));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() {
          final defaultBooking = Booking(
            id: getUuid(),
            confirmedPlayerIds: [],
            courtId: widget.courtSelected.id,
            format: _bookingFormat,
            startTime: startDateEpoch,
            endTime: endDateEpoch,
            private: _visibilityValue == 'Private',
            ownerId: ref.read(userProvider).uid,
            requests: [],
            restrictions: null,
            status: BookingStatus.confirmed,
            title: titleValue,
            clubId: widget.clubSelected.id,
            clubName: widget.clubSelected.name,
            courtName: widget.courtSelected.name,
          );
          submitFunction = () => Navigator.of(context).pushNamed(CasualPaymentScreen.route, arguments: defaultBooking);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      onChanged: () {
        if (_formKey.currentState?.validate() ?? false) {
          final booking = Booking(
            id: getUuid(),
            confirmedPlayerIds: [],
            courtId: widget.courtSelected.id,
            format: _bookingFormat,
            startTime: startDateEpoch,
            endTime: endDateEpoch,
            private: _visibilityValue == 'Private',
            ownerId: ref.read(userProvider).uid,
            requests: [],
            restrictions: null,
            status: BookingStatus.confirmed,
            title: titleValue,
            clubId: widget.clubSelected.id,
            clubName: widget.clubSelected.name,
            courtName: widget.courtSelected.name,
          );
          submitFunction = () => Navigator.of(context).pushNamed(CasualPaymentScreen.route, arguments: booking);
        } else {
          submitFunction = null;
        }
        setState(() {});
      },
      child: Column(
        spacing: 15,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            key: const Key('titleField'),
            initialValue: titleValue,
            decoration: InputDecoration(
              labelText: context.localeString(BookingFormStrings.titleLabel),
            ),
            onChanged: (value) {
              titleValue = value;
            },
            validator: (value) {
              String? validationError;
              if (value == null || value.isEmpty) {
                validationError = context.localeString(BookingFormStrings.pleaseEnterTitle);
              }
              return validationError;
            },
          ),
          // ^ =============== FORMAT FIELD ===============
          DropdownButtonFormField<String>(
            key: const Key('formatField'),
            initialValue: _bookingFormat.name,
            decoration: InputDecoration(labelText: context.localeString(BookingFormStrings.formatLabel)),
            items: [
              DropdownMenuItem(value: BookingFormat.singles.name, child: PrettyText(context.localeString(BookingFormStrings.singles))),
              DropdownMenuItem(value: BookingFormat.doubles.name, child: PrettyText(context.localeString(BookingFormStrings.doubles))),
            ],
            onChanged: (value) {
              setState(() {
                _bookingFormat = BookingFormat.fromString(value!);
              });
            },
            validator: (value) {
              String? validationError;
              if (value == null || value.isEmpty) {
                submitFunction = null;
                validationError = context.localeString(BookingFormStrings.pleaseEnterFormat);
              }
              return validationError;
            },
          ),
          // ^ =============== VISIBILITY FIELD ===============
          DropdownButtonFormField<String>(
            key: const Key('visibilityField'),
            initialValue: _visibilityValue,
            decoration: InputDecoration(labelText: context.localeString(BookingFormStrings.visibilityLabel)),
            items: [
              DropdownMenuItem(value: 'Public', child: PrettyText(context.localeString(BookingFormStrings.publicOption))),
              DropdownMenuItem(value: 'Private', child: PrettyText(context.localeString(BookingFormStrings.privateOption))),
            ],
            onChanged: (value) {
              setState(() {
                _visibilityValue = value!;
              });
            },
            validator: (value) {
              String? validationError;
              if (value == null || value.isEmpty) {
                submitFunction = null;
                validationError = context.localeString(BookingFormStrings.pleaseSelectVisibility);
              }
              return validationError;
            },
          ),
          // ^ =============== START TIME FIELD ===============
          TextFormField(
            key: const Key('startTimeField'),
            controller: startTimeController,
            decoration: InputDecoration(labelText: context.localeString(BookingFormStrings.startTime)),
            onTap: () async {
              TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(widget.date),
                initialEntryMode: TimePickerEntryMode.dial,
              );
              if (picked != null && context.mounted) {
                picked = roundToNearestQuarter(picked);
                startDateEpoch = timeOfDayToEpochUtc(picked, widget.date);
                startTimeController.text = picked.format(context);
              }
            },
          ),
          // ^ =============== END TIME FIELD ===============
          TextFormField(
            key: const Key('endTimeField'),
            controller: endTimeController,
            decoration: InputDecoration(labelText: context.localeString(BookingFormStrings.endTime)),
            readOnly: true,
            onTap: () async {
              TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(widget.date.add(const Duration(hours: 1))),
                initialEntryMode: TimePickerEntryMode.dial,
              );
              if (picked != null && context.mounted) {
                picked = roundToNearestQuarter(picked);
                endDateEpoch = timeOfDayToEpochUtc(picked, widget.date);
                endTimeController.text = picked.format(context);
                _formKey.currentState?.validate();
              }
            },
            validator: (String? _) {
              final validationError = validateNewTime(
                startDateEpoch: startDateEpoch,
                endDateEpoch: endDateEpoch,
                bookedTimes: widget.confirmedBookedTimes,
                context: context,
              );
              if (validationError != null) {}

              return validationError;
            },
          ),
          const SizedBox(height: 10),
          // ^ =============== BUTTONS ===============
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TbTextButton(
                color: AppColors.red,
                text: context.localeString(GeneralStrings.cancel),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TbTextButton(
                text: context.localeString(BookingFormStrings.proceedToPayment),
                onPressed: submitFunction,
                color: AppColors.primaryGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
