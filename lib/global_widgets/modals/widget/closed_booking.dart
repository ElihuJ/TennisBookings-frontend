import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../cloud_functions/dto/index.dart';
import '../../../cloud_functions/index.dart';
import '../../../cloud_functions/types.dart';
import '../../../config/config.dart';
import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../strings/index.dart';
import '../../../theme/colors.dart';
import '../../index.dart';
import 'modal_shell.dart';

class ClosedBooking extends StatefulHookConsumerWidget {
  const ClosedBooking({
    super.key,
    required this.clubSelected,
    required this.courtSelected,
    required this.date,
    required this.switchBookingMode,
    required this.context,
    required this.confirmedBookedTimes,
    required this.titleValue,
    required this.setTitleValue,
    required this.startTimeController,
    required this.endTimeController,
    required this.startDateEpoch,
    required this.endDateEpoch,
    required this.setStartDateEpoch,
    required this.setEndDateEpoch,
  });
  final Club clubSelected;
  final Court courtSelected;
  final DateTime date;
  final Function() switchBookingMode;
  final BuildContext context;
  final List<BookedTimeEpoch> confirmedBookedTimes;
  final String titleValue;
  final Function(String) setTitleValue;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final Function(int) setStartDateEpoch;
  final Function(int) setEndDateEpoch;
  final int startDateEpoch;
  final int endDateEpoch;

  @override
  ConsumerState<ClosedBooking> createState() => _ClosedBookingState();
}

class _ClosedBookingState extends ConsumerState<ClosedBooking> {
  final _formKey = GlobalKey<FormState>();

  String _visibilityValue = 'Public';
  BookingFormat _bookingFormat = BookingFormat.singles;
  void Function()? submitFunction;
  Config config = Config();

  Future<CFResult> onSubmit() async {
    final eventsNotifier = ref.read(eventProvider.notifier);
    final clubsNotifier = ref.read(clubsProvider.notifier);
    final userNotifier = ref.read(userProvider.notifier);
    final cloudFunctionsNotifier = ref.read(cloudFunctionsProvider.notifier);
    final user = ref.read(userProvider);
    final private = _visibilityValue == 'Private';
    final newBooking = Booking(
      id: getUuid(),
      confirmedPlayerIds: [],
      courtId: widget.courtSelected.id,
      format: _bookingFormat,
      startTime: widget.startDateEpoch,
      endTime: widget.endDateEpoch,
      private: private,
      ownerId: user.uid,
      requests: [],
      restrictions: null,
      status: BookingStatus.confirmed,
      title: widget.titleValue,
      clubId: widget.clubSelected.id,
      clubName: widget.clubSelected.name,
      courtName: widget.courtSelected.name,
    );

    final payload = CreateMemberBookingPayload(booking: newBooking, isOpenBooking: false);

    final creatingMsg = context.localeString(BookingFormStrings.creating);
    final createdMsg = context.localeString(BookingFormStrings.created);
    Navigator.of(context).pop();
    eventsNotifier.showLoading(title: creatingMsg);
    final result = await cloudFunctionsNotifier.createBooking(payload);
    eventsNotifier.hideLoading();
    final newBookingId = result.data;
    final success = result.responseStatus.code == CFResponseCode.ok;
    if (success) {
      final updatedBooking = newBooking.copyWith(id: newBookingId);
      clubsNotifier.addBooking(court: widget.courtSelected, booking: updatedBooking, isPrivate: private);
      userNotifier.addUserBooking(updatedBooking);
      eventsNotifier.showMessage(messageType: MessageType.success, message: createdMsg);
    } else {
      eventsNotifier.showMessage(messageType: MessageType.error, message: result.responseStatus.message.name);
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => submitFunction = onSubmit);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      onChanged: () {
        _formKey.currentState!.save();
        setState(() => submitFunction = _formKey.currentState!.validate() ? onSubmit : null);
      },
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalTabRow(
            leftLabel: context.localeString(BookingFormStrings.bookingTab),
            rightLabel: context.localeString(BookingFormStrings.lookForPlayer),
            leftActive: true,
            onLeftTap: () {},
            onRightTap: widget.switchBookingMode,
          ),
          TextFormField(
            initialValue: widget.titleValue,
            decoration: modalFieldDecoration(label: context.localeString(BookingFormStrings.titleLabel), prefixIcon: Icons.title),
            onChanged: widget.setTitleValue,
            validator: (v) => (v == null || v.isEmpty) ? context.localeString(BookingFormStrings.pleaseEnterTitle) : null,
          ),
          DropdownButtonFormField<String>(
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
            initialValue: _visibilityValue,
            decoration: modalFieldDecoration(label: context.localeString(BookingFormStrings.visibilityLabel), prefixIcon: Icons.visibility_outlined),
            items: [
              DropdownMenuItem(value: 'Public', child: Text(context.localeString(BookingFormStrings.publicOption))),
              DropdownMenuItem(value: 'Private', child: Text(context.localeString(BookingFormStrings.privateOption))),
            ],
            onChanged: (v) => setState(() => _visibilityValue = v!),
            validator: (v) => (v == null || v.isEmpty) ? context.localeString(BookingFormStrings.pleaseSelectVisibility) : null,
          ),
          TextFormField(
            controller: widget.startTimeController,
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
                widget.setStartDateEpoch(timeOfDayToEpochUtc(picked, widget.date));
                widget.startTimeController.text = picked.format(context);
              }
            },
          ),
          TextFormField(
            controller: widget.endTimeController,
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
                widget.setEndDateEpoch(timeOfDayToEpochUtc(picked, widget.date));
                widget.endTimeController.text = picked.format(context);
              }
            },
            validator: (_) {
              final err = validateNewTime(
                startDateEpoch: widget.startDateEpoch,
                endDateEpoch: widget.endDateEpoch,
                bookedTimes: widget.confirmedBookedTimes,
                context: context,
              );
              if (err != null) submitFunction = null;
              return err;
            },
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7B6E),
                    side: const BorderSide(color: Color(0xFFCCCCCC)),
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
                    disabledBackgroundColor: const Color(0xFFB0C8BB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(context.localeString(BookingFormStrings.createBooking)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
