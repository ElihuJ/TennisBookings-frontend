import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/cloud_functions/index.dart';
import 'package:tennisbookings/cloud_functions/types.dart';
import 'package:tennisbookings/global_widgets/index.dart';

import '../../../cloud_functions/dto/index.dart';
import '../../../config/config.dart';
import '../../../global_helpers/index.dart';
import '../../../global_types/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';
import 'buttons.dart';

class OpenBooking extends StatefulHookConsumerWidget {
  const OpenBooking({
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
  ConsumerState<OpenBooking> createState() => _OpenBookingState();
}

class _OpenBookingState extends ConsumerState<OpenBooking> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  late int endDateEpoch;
  late int startDateEpoch;
  String _titleValue = '';
  BookingFormat _bookingFormat = BookingFormat.singles;
  BookingRestrictions? _bookingRestrictions;
  bool _withRestrictions = false;

  void Function()? submitFunction;

  bool isValid = false;
  Config config = Config();

  void setBookingRestrictions(BookingRestrictions bookingRestrictions) {
    _bookingRestrictions = bookingRestrictions;
  }

  @override
  initState() {
    super.initState();
    _startTimeController.text = TimeOfDay(hour: widget.date.hour, minute: widget.date.minute).format(widget.context);
    _endTimeController.text = TimeOfDay(hour: widget.date.hour + 1, minute: widget.date.minute).format(widget.context);
    DateTime startDate = DateTime(widget.date.year, widget.date.month, widget.date.day, widget.date.hour, widget.date.minute).toUtc();
    startDateEpoch = dateTimeToEpochUtc(startDate);
    endDateEpoch = dateTimeToEpochUtc(startDate.add(const Duration(hours: 1)));
  }

  Future<CFResult> onSubmit() async {
    final eventsNotifier = ref.read(eventsProvider.notifier);
    final clubsNotifier = ref.read(clubsProvider.notifier);
    final cloudFunctionsNotifier = ref.read(cloudFunctionsProvider.notifier);
    final user = ref.read(userProvider);
    final newBooking = Booking(
      id: getUuid(),
      confirmedPlayerIds: [user.uid],
      courtId: widget.courtSelected.id,
      format: _bookingFormat,
      from: startDateEpoch,
      to: endDateEpoch,
      private: false,
      ownerId: user.uid,
      requests: [],
      restrictions: _bookingRestrictions,
      status: BookingStatus.open,
      title: _titleValue,
    );

    final payload = CreateBookingPayload(
      booking: newBooking,
      clubId: widget.clubSelected.id,
      isOpenBooking: false,
    );

    Navigator.of(context).pop();
    eventsNotifier.showLoading(title: "Creating booking...");
    final result = await cloudFunctionsNotifier.createBooking(payload);
    eventsNotifier.hideLoading();
    final success = result.data;
    if (success != null && success) {
      clubsNotifier.addBooking(court: widget.courtSelected, booking: newBooking, isPrivate: false);
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
                  onPressed: widget.switchBookingMode,
                  color: AppColors.grey,
                ),
                TbButton(
                  text: 'Open',
                  color: AppColors.blue,
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
            // ^ =============== RESTRICTIONS FIELD ===============
            DropdownButtonFormField<bool>(
              value: _withRestrictions,
              decoration: const InputDecoration(labelText: 'Restrictions'),
              items: [
                DropdownMenuItem(value: true, child: PrettyText('Yes')),
                DropdownMenuItem(value: false, child: PrettyText('No')),
              ],
              onChanged: (withRestrictions) {
                setState(() {
                  _withRestrictions = withRestrictions!;
                  if (!_withRestrictions) {
                    _bookingRestrictions = null;
                  } else {
                    _bookingRestrictions = BookingRestrictions.empty();
                  }
                });
              },
              validator: (value) {
                String? validationError;
                if (value == null) {
                  submitFunction = null;
                  validationError = 'Please enter a restriction';
                }
                return validationError;
              },
            ),
            // ^ =============== RESTRICTIONS DETAILS WIDGET ===============
            if (_withRestrictions)
              RestrictionsField(
                bookingRestrictions: _bookingRestrictions!,
                setBookingRestrictions: setBookingRestrictions,
              ),
            // ^ =============== START DATE FIELD ===============
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
            // ^ =============== END DATE FIELD ===============
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
              validator: (String? _) {
                final validationError = validateNewTime(
                  startDateEpoch: startDateEpoch,
                  endDateEpoch: endDateEpoch,
                  bookedTimes: widget.confirmedBookedTimes,
                  date: widget.date,
                );
                if (validationError != null) {
                  submitFunction = null;
                }
                return validationError;
              },
            ),
            // ^ =============== BUTTONS ===============
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

class RestrictionsField extends StatefulWidget {
  const RestrictionsField({
    super.key,
    required this.bookingRestrictions,
    required this.setBookingRestrictions,
  });
  final BookingRestrictions bookingRestrictions;
  final Function(BookingRestrictions bookingRestrictions) setBookingRestrictions;

  @override
  RestrictionsFieldState createState() => RestrictionsFieldState();
}

class RestrictionsFieldState extends State<RestrictionsField> {
  late bool _utrVerified;
  TextEditingController utrGtController = TextEditingController();
  TextEditingController utrLtController = TextEditingController();

  utrGtListener() {
    final utrGreaterThan = double.tryParse(utrGtController.text);
    if (utrGreaterThan == null) {
      return;
    }
    final newBookingRestrictions = widget.bookingRestrictions.copyWith(utrGt: utrGreaterThan);
    widget.setBookingRestrictions(newBookingRestrictions);
  }

  utrLtListener() {
    final utrLowerThan = double.tryParse(utrLtController.text);
    if (utrLowerThan == null) {
      return;
    }
    final newBookingRestrictions = widget.bookingRestrictions.copyWith(utrLt: utrLowerThan);
    widget.setBookingRestrictions(newBookingRestrictions);
  }

  @override
  void initState() {
    super.initState();
    _utrVerified = widget.bookingRestrictions.utrVerified;
    utrGtController.text = widget.bookingRestrictions.utrGt.toString();
    utrLtController.text = widget.bookingRestrictions.utrLt.toString();
    utrGtController.addListener(utrGtListener);
    utrLtController.addListener(utrLtListener);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<bool>(
          value: _utrVerified,
          decoration: const InputDecoration(labelText: 'UTR Verified'),
          items: [
            DropdownMenuItem(value: true, child: PrettyText('Yes')),
            DropdownMenuItem(value: false, child: PrettyText('No')),
          ],
          onChanged: (value) {
            setState(() {
              _utrVerified = value!;
              final newBookingRestrictions = widget.bookingRestrictions.copyWith(utrVerified: _utrVerified);
              widget.setBookingRestrictions(newBookingRestrictions);
            });
          },
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'UTR Lower Than'),
          keyboardType: TextInputType.number,
          validator: (value) {
            String? error;
            error = utrValueValidator(value, context);
            if (error != null) {
              return error;
            }
            error = validateUtrComparison(utrGt: utrGtController.text, utrLt: utrLtController.text, context: context);
            return error;
          },
          controller: utrLtController,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'UTR Greater Than'),
          keyboardType: TextInputType.number,
          validator: (value) => utrValueValidator(value, context),
          controller: utrGtController,
        ),
      ],
    );
  }
}
