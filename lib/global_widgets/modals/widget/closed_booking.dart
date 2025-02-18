import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../cloud_functions/dto/index.dart';
import '../../../cloud_functions/index.dart';
import '../../../cloud_functions/types.dart';
import '../../../config/config.dart';
import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';
import '../../index.dart';
import 'buttons.dart';

class ClosedBooking extends StatefulHookConsumerWidget {
  const ClosedBooking({
    super.key,
    required this.clubSelected,
    required this.courtSelected,
    required this.date,
    required this.switchBookingMode,
    required this.context,
    required this.confirmedBookedTimes,
  });
  final Club clubSelected;
  final Court courtSelected;
  final DateTime date;
  final Function() switchBookingMode;
  final BuildContext context;
  final List<BookedTimeEpoch> confirmedBookedTimes;

  @override
  ConsumerState<ClosedBooking> createState() => _ClosedBookingState();
}

class _ClosedBookingState extends ConsumerState<ClosedBooking> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  late int endDateEpoch;
  late int startDateEpoch;
  String _visibilityValue = 'Public';
  String _titleValue = '';
  BookingFormat _bookingFormat = BookingFormat.singles;

  void Function()? submitFunction;
  bool isValid = false;
  Config config = Config();

  @override
  initState() {
    super.initState();
    _startTimeController.text = TimeOfDay(hour: widget.date.hour, minute: widget.date.minute).format(widget.context);
    _endTimeController.text = TimeOfDay(hour: widget.date.hour + 1, minute: widget.date.minute).format(widget.context);
    DateTime startDate = DateTime(widget.date.year, widget.date.month, widget.date.day, widget.date.hour, widget.date.minute).toUtc();
    startDateEpoch = dateTimeToEpochSecondsUtc(startDate);
    endDateEpoch = dateTimeToEpochSecondsUtc(startDate.add(const Duration(hours: 1)));
  }

  Future<CFResult> onSubmit() async {
    final eventsNotifier = ref.read(eventsProvider.notifier);
    final clubsNotifier = ref.read(clubsProvider.notifier);
    final cloudFunctionsNotifier = ref.read(cloudFunctionsProvider.notifier);
    final user = ref.read(userProvider);
    final private = _visibilityValue == 'Private';
    final newBooking = Booking(
      id: getUuid(),
      confirmedPlayerIds: [],
      courtId: widget.courtSelected.id,
      format: _bookingFormat,
      from: startDateEpoch,
      to: endDateEpoch,
      private: private,
      ownerId: user.uid,
      requests: [],
      restrictions: null,
      status: BookingStatus.confirmed,
      title: _titleValue,
      clubId: widget.clubSelected.id,
    );

    final payload = CreateBookingPayload(
      booking: newBooking,
      clubId: widget.clubSelected.id,
      isOpenBooking: false, // * This is the only difference between open and closed booking
    );

    Navigator.of(context).pop();
    eventsNotifier.showLoading(title: "Creating booking...");
    final result = await cloudFunctionsNotifier.createBooking(payload);
    eventsNotifier.hideLoading();
    final newBookingId = result.data;
    final success = result.responseStatus.code == CFResponseCode.ok;
    if (success) {
      final updatedBooking = newBooking.copyWith(id: newBookingId);
      clubsNotifier.addBooking(court: widget.courtSelected, booking: updatedBooking, isPrivate: private);
      eventsNotifier.showMessage(messageType: MessageType.success, message: 'Booking created');
    } else {
      eventsNotifier.showMessage(messageType: MessageType.error, message: result.errorMessage ?? 'Error creating booking');
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TbButton(
                  text: 'Closed',
                  color: AppColors.blue,
                ),
                TbButton(
                  text: 'Open',
                  onPressed: widget.switchBookingMode,
                  color: AppColors.grey,
                ),
              ],
            ),
            // ^ =============== TITLE FIELD ===============
            TextFormField(
              initialValue: _titleValue,
              decoration: const InputDecoration(
                labelText: 'Booking Title',
              ),
              onChanged: (value) => _titleValue = value,
              validator: (value) {
                String? validationError;
                if (value == null || value.isEmpty) {
                  validationError = '';
                }
                return validationError;
              },
            ),
            // ^ =============== FORMAT FIELD ===============
            DropdownButtonFormField<String>(
              value: _bookingFormat.name,
              decoration: const InputDecoration(labelText: 'Format'),
              items: [
                DropdownMenuItem(value: BookingFormat.singles.name, child: PrettyText(BookingFormat.singles.name)),
                DropdownMenuItem(value: BookingFormat.doubles.name, child: PrettyText(BookingFormat.doubles.name)),
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
                  validationError = 'Please enter a format';
                }
                return validationError;
              },
            ),
            // ^ =============== VISIBILITY FIELD ===============
            DropdownButtonFormField<String>(
              value: _visibilityValue,
              decoration: const InputDecoration(labelText: 'Visibility'),
              items: const [
                DropdownMenuItem(value: 'Public', child: Text('Public')),
                DropdownMenuItem(value: 'Private', child: Text('Private')),
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
                  validationError = 'Please enter a visibility';
                }
                return validationError;
              },
            ),
            // ^ =============== START TIME FIELD ===============
            TextFormField(
              controller: _startTimeController,
              decoration: const InputDecoration(labelText: 'Start Time'),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(widget.date),
                  initialEntryMode: TimePickerEntryMode.dial,
                );
                if (picked != null && context.mounted) {
                  picked = roundToNearestQuarter(picked);
                  startDateEpoch = timeOfDayToEpochUtcSeconds(picked, widget.date);
                  _startTimeController.text = picked.format(context);
                }
              },
            ),
            // ^ =============== END TIME FIELD ===============
            TextFormField(
              controller: _endTimeController,
              decoration: const InputDecoration(labelText: 'End Time'),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(widget.date.add(const Duration(hours: 1))),
                  initialEntryMode: TimePickerEntryMode.dial,
                );
                if (picked != null && context.mounted) {
                  picked = roundToNearestQuarter(picked);
                  endDateEpoch = timeOfDayToEpochUtcSeconds(picked, widget.date);
                  _endTimeController.text = picked.format(context);
                }
              },
              validator: (String? _) {
                final validationError = validateNewTime(
                  startDateEpoch: startDateEpoch,
                  endDateEpoch: endDateEpoch,
                  bookedTimes: widget.confirmedBookedTimes,
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
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.red),
                  ),
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  onPressed: submitFunction,
                  child: const Text('Create Booking'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
