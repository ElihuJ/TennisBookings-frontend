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
import '../../../theme/index.dart';
import '../../index.dart';

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
  bool isValid = false;
  Config config = Config();

  Future<CFResult> onSubmit() async {
    final eventsNotifier = ref.read(eventProvider.notifier);
    final clubsNotifier = ref.read(clubsProvider.notifier);
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

    final payload = CreateMemberBookingPayload(
      booking: newBooking,
      isOpenBooking: false, // * This is the only difference between open and closed booking
    );

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
        setState(() {
          submitFunction = onSubmit;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mobileView = isMobile(context);
    final fontSize = getFontSize(mobileView);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      onChanged: () {
        _formKey.currentState!.save();
        if (_formKey.currentState!.validate()) {
          submitFunction = onSubmit;
        } else {
          submitFunction = null;
        }
        setState(() {});
      },
      child: SizedBox(
        width: 500,
        child: Column(
          spacing: 15,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TbTextButton(
                  text: context.localeString(BookingFormStrings.bookingTab),
                  color: AppColors.primaryGreen,
                  onPressed: () {},
                ),
                TbTextButton(text: context.localeString(BookingFormStrings.lookForPlayer), onPressed: widget.switchBookingMode, color: AppColors.grey),
              ],
            ),
            // ^ =============== TITLE FIELD ===============
            TextFormField(
              style: TextStyle(fontSize: fontSize),
              initialValue: widget.titleValue,
              decoration: InputDecoration(
                labelText: context.localeString(BookingFormStrings.titleLabel),
              ),
              onChanged: (value) => widget.setTitleValue(value),
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
              style: TextStyle(fontSize: fontSize),
              controller: widget.startTimeController,
              decoration: InputDecoration(labelText: context.localeString(BookingFormStrings.startTime)),
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
            // ^ =============== END TIME FIELD ===============
            TextFormField(
              style: TextStyle(fontSize: fontSize),
              controller: widget.endTimeController,
              decoration: InputDecoration(labelText: context.localeString(BookingFormStrings.endTime)),
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
              validator: (String? _) {
                final validationError = validateNewTime(
                  startDateEpoch: widget.startDateEpoch,
                  endDateEpoch: widget.endDateEpoch,
                  bookedTimes: widget.confirmedBookedTimes,
                  context: context,
                );
                if (validationError != null) {
                  submitFunction = null;
                }
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
                  text: context.localeString(BookingFormStrings.createBooking),
                  onPressed: submitFunction,
                  color: AppColors.primaryGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
