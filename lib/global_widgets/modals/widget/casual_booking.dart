import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/config.dart';
import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';
import '../../../screens/payments/casual_payment_screen.dart';
import '../../../state/index.dart';
import '../../../strings/index.dart';
import '../../../theme/colors.dart';
import 'modal_shell.dart';

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
          final defaultBooking = _buildBooking();
          submitFunction = () => Navigator.of(context).pushNamed(CasualPaymentScreen.route, arguments: defaultBooking);
        });
      }
    });
  }

  Booking _buildBooking() => Booking(
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      onChanged: () {
        if (_formKey.currentState?.validate() ?? false) {
          final booking = _buildBooking();
          submitFunction = () => Navigator.of(context).pushNamed(CasualPaymentScreen.route, arguments: booking);
        } else {
          submitFunction = null;
        }
        setState(() {});
      },
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            key: const Key('titleField'),
            initialValue: titleValue,
            decoration: modalFieldDecoration(label: context.localeString(BookingFormStrings.titleLabel), prefixIcon: Icons.title),
            onChanged: (v) => titleValue = v,
            validator: (v) => (v == null || v.isEmpty) ? context.localeString(BookingFormStrings.pleaseEnterTitle) : null,
          ),
          DropdownButtonFormField<String>(
            key: const Key('formatField'),
            initialValue: _bookingFormat.name,
            decoration: modalFieldDecoration(label: context.localeString(BookingFormStrings.formatLabel), prefixIcon: Icons.people_outline),
            items: [
              DropdownMenuItem(value: BookingFormat.singles.name, child: Text(context.localeString(BookingFormStrings.singles))),
              DropdownMenuItem(value: BookingFormat.doubles.name, child: Text(context.localeString(BookingFormStrings.doubles))),
            ],
            onChanged: (v) => setState(() => _bookingFormat = BookingFormat.fromString(v!)),
            validator: (v) => (v == null || v.isEmpty) ? context.localeString(BookingFormStrings.pleaseEnterFormat) : null,
          ),
          DropdownButtonFormField<String>(
            key: const Key('visibilityField'),
            initialValue: _visibilityValue,
            decoration: modalFieldDecoration(
                label: context.localeString(BookingFormStrings.visibilityLabel), prefixIcon: Icons.visibility_outlined),
            items: [
              DropdownMenuItem(value: 'Public', child: Text(context.localeString(BookingFormStrings.publicOption))),
              DropdownMenuItem(value: 'Private', child: Text(context.localeString(BookingFormStrings.privateOption))),
            ],
            onChanged: (v) => setState(() => _visibilityValue = v!),
            validator: (v) => (v == null || v.isEmpty) ? context.localeString(BookingFormStrings.pleaseSelectVisibility) : null,
          ),
          TextFormField(
            key: const Key('startTimeField'),
            controller: startTimeController,
            decoration: modalFieldDecoration(label: context.localeString(BookingFormStrings.startTime), prefixIcon: Icons.schedule),
            readOnly: true,
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
          TextFormField(
            key: const Key('endTimeField'),
            controller: endTimeController,
            decoration: modalFieldDecoration(label: context.localeString(BookingFormStrings.endTime), prefixIcon: Icons.schedule_outlined),
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
            validator: (_) => validateNewTime(
              startDateEpoch: startDateEpoch,
              endDateEpoch: endDateEpoch,
              bookedTimes: widget.confirmedBookedTimes,
              context: context,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSubtle,
                    side: const BorderSide(color: AppColors.borderCancel),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(context.localeString(GeneralStrings.cancel)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: submitFunction,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    disabledBackgroundColor: AppColors.disabledGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(context.localeString(BookingFormStrings.proceedToPayment)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
