import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';
import 'buttons.dart';

class OpenBooking extends StatefulHookConsumerWidget {
  const OpenBooking({super.key, required this.clubSelected, required this.courtSelected, required this.date, required this.switchBookingMode});
  final Club clubSelected;
  final Court courtSelected;
  final DateTime date;
  final Function() switchBookingMode;

  @override
  ConsumerState<OpenBooking> createState() => _OpenBookingState();
}

class _OpenBookingState extends ConsumerState<OpenBooking> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bookingTitleController = TextEditingController();
  final TextEditingController _visibilityController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.values[1],
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TbButton(
                  text: 'Closed',
                  color: AppColors.grey,
                  onPressed: widget.switchBookingMode,
                ),
                TbButton(text: 'Open', color: AppColors.blue),
              ],
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Booking Title'),
              controller: _bookingTitleController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a booking title';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Visibility'),
              items: const [
                DropdownMenuItem(value: 'Public', child: Text('Public')),
                DropdownMenuItem(value: 'Private', child: Text('Private')),
              ],
              onChanged: (value) {
                _visibilityController.text = value!;
              },
            ),
            TextFormField(
              controller: _startTimeController,
              decoration: const InputDecoration(labelText: 'Start Time'),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null && context.mounted) {
                  _startTimeController.text = picked.format(context);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a start time';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _endTimeController,
              decoration: const InputDecoration(labelText: 'End Time'),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null && context.mounted) {
                  _endTimeController.text = picked.format(context);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an end time';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
