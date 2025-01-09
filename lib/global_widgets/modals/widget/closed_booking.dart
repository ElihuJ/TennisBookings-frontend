import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/config.dart';
import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';
import 'buttons.dart';

class ClosedBooking extends StatefulHookConsumerWidget {
  const ClosedBooking({
    super.key,
    required this.clubSelected,
    required this.courtSelected,
    required this.date,
    required this.switchBookingMode,
    required this.context,
    required this.bookedTimes,
  });
  final Club clubSelected;
  final Court courtSelected;
  final DateTime date;
  final Function() switchBookingMode;
  final BuildContext context;
  final List<BookedTimeEpoch> bookedTimes;

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
  void Function()? submitFunction;
  bool isValid = false;
  Config config = Config();

  @override
  initState() {
    super.initState();
    _startTimeController.text = TimeOfDay(hour: widget.date.hour, minute: widget.date.minute).format(widget.context);
    _endTimeController.text = TimeOfDay(hour: widget.date.hour + 1, minute: widget.date.minute).format(widget.context);
    DateTime startDate = DateTime(widget.date.year, widget.date.month, widget.date.day, widget.date.hour, widget.date.minute).toUtc();
    startDateEpoch = dateTimeToEpochUtc(startDate);
    endDateEpoch = dateTimeToEpochUtc(startDate.add(const Duration(hours: 1)));
  }

  onSubmit() {
    final eventsNotifier = ref.read(eventsProvider.notifier);
    eventsNotifier.showMessage(messageType: MessageType.success, message: 'Booking created');
    Navigator.of(context).pop();
  }

  String? validateNewTime(String? _) {
    if (endDateEpoch <= startDateEpoch) {
      submitFunction = null;
      return 'End time must be after start time';
    }
    if ((endDateEpoch - startDateEpoch) > Config.maxBookingDuration) {
      submitFunction = null;
      return 'Booking must be less than ${Config.maxBookingHours} hour';
    }
    if (!validateTime(startTimeEpoch: startDateEpoch, bookedTimes: widget.bookedTimes, date: widget.date, endTimeEpoch: endDateEpoch)) {
      submitFunction = null;
      return 'Time slot is already booked';
    }
    return null;
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
                  startDateEpoch = timeOfDayToEpochUtc(picked, widget.date);
                  _startTimeController.text = picked.format(context);
                }
              },
            ),
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
                  endDateEpoch = timeOfDayToEpochUtc(picked, widget.date);
                  _endTimeController.text = picked.format(context);
                }
              },
              validator: validateNewTime,
            ),
            const SizedBox(height: 10),
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
