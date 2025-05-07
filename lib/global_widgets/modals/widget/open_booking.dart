import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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

class OpenBooking extends StatefulHookConsumerWidget {
  const OpenBooking({
    super.key,
    required this.clubSelected,
    required this.courtSelected,
    required this.date,
    required this.switchBookingMode,
    required this.context,
    required this.confirmedBookedTimes,
    required this.setTitleValue,
    required this.titleValue,
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
  final Function(String value) setTitleValue;
  final String titleValue;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final int startDateEpoch;
  final int endDateEpoch;
  final Function(int value) setStartDateEpoch;
  final Function(int value) setEndDateEpoch;

  @override
  ConsumerState<OpenBooking> createState() => _OpenBookingState();
}

class _OpenBookingState extends ConsumerState<OpenBooking> {
  final _formKey = GlobalKey<FormState>();
  BookingFormat _bookingFormat = BookingFormat.singles;
  BookingRestrictions? _bookingRestrictions;
  bool _withRestrictions = false;

  void Function()? submitFunction;

  bool isValid = false;
  Config config = Config();

  void setBookingRestrictions(BookingRestrictions bookingRestrictions) {
    _bookingRestrictions = bookingRestrictions;
  }

  Future<CFResult> onSubmit() async {
    final eventsNotifier = ref.read(eventProvider.notifier);
    final clubsNotifier = ref.read(clubsProvider.notifier);
    final cloudFunctionsNotifier = ref.read(cloudFunctionsProvider.notifier);
    final user = ref.read(userProvider);
    final newBooking = Booking(
      id: getUuid(),
      confirmedPlayerIds: [],
      courtId: widget.courtSelected.id,
      format: _bookingFormat,
      startTime: widget.startDateEpoch,
      endTime: widget.endDateEpoch,
      private: false,
      ownerId: user.uid,
      requests: [],
      restrictions: _bookingRestrictions,
      status: BookingStatus.open,
      title: widget.titleValue,
      clubId: widget.clubSelected.id,
      clubName: widget.clubSelected.name,
      courtName: widget.courtSelected.name,
    );

    final payload = CreateBookingPayload(
      booking: newBooking,
      isOpenBooking: true, // * This is the only difference between open and closed booking
    );

    Navigator.of(context).pop();
    eventsNotifier.showLoading(title: "Creating booking...");
    final result = await cloudFunctionsNotifier.createBooking(payload);
    eventsNotifier.hideLoading();
    final newBookingId = result.data;
    final success = result.responseStatus.code == CFResponseCode.ok;
    if (success) {
      final updatedBooking = newBooking.copyWith(id: newBookingId);
      clubsNotifier.addBooking(court: widget.courtSelected, booking: updatedBooking, isPrivate: false);
      eventsNotifier.showMessage(messageType: MessageType.success, message: 'Booking created');
    } else {
      eventsNotifier.showMessage(messageType: MessageType.error, message: result.errorMessage ?? 'Error creating booking');
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
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TbTextButton(
                    text: 'Booking',
                    onPressed: widget.switchBookingMode,
                    color: AppColors.grey,
                  ),
                  TbTextButton(
                    text: 'Look for a player',
                    color: AppColors.primaryGreen,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // ^ =============== TITLE FIELD ===============
            TextFormField(
              initialValue: widget.titleValue,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
              onChanged: (value) => widget.setTitleValue(value),
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
              controller: widget.startTimeController,
              decoration: const InputDecoration(labelText: 'Start Time'),
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
            // ^ =============== END DATE FIELD ===============
            TextFormField(
              controller: widget.endTimeController,
              decoration: const InputDecoration(labelText: 'End Time'),
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
                TbTextButton(
                  color: AppColors.red,
                  text: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TbTextButton(
                  text: 'Create Booking',
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
  late Gender? _genderFilter; // Added gender filter
  TextEditingController utrGtController = TextEditingController();
  TextEditingController utrLtController = TextEditingController();
  MouseCursor cursor = SystemMouseCursors.click;

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
    _genderFilter = widget.bookingRestrictions.gender; // Initialize gender filter

    if (widget.bookingRestrictions.utrGt != null) {
      utrGtController.text = widget.bookingRestrictions.utrGt.toString();
    }

    if (widget.bookingRestrictions.utrLt != null) {
      utrLtController.text = widget.bookingRestrictions.utrLt.toString();
    }

    utrGtController.addListener(utrGtListener);
    utrLtController.addListener(utrLtListener);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
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
        // Gender filter dropdown
        DropdownButtonFormField<Gender?>(
          value: _genderFilter,
          decoration: const InputDecoration(labelText: 'Gender'),
          items: [
            DropdownMenuItem(value: null, child: PrettyText('Any')),
            DropdownMenuItem(value: Gender.male, child: PrettyText('Male')),
            DropdownMenuItem(value: Gender.female, child: PrettyText('Female')),
          ],
          onChanged: (value) {
            setState(() {
              _genderFilter = value;
              final newBookingRestrictions = widget.bookingRestrictions.copyWith(gender: _genderFilter);
              widget.setBookingRestrictions(newBookingRestrictions);
            });
          },
        ),
        MouseRegion(
          cursor: cursor,
          onHover: (_) {
            setState(() {
              cursor = SystemMouseCursors.help;
            });
          },
          onExit: (_) {
            setState(() {
              cursor = SystemMouseCursors.basic;
            });
          },
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(vertical: 15),
            child: GestureDetector(
              onTap: () => launchUrl(Uri.parse(
                  'https://www.utrsports.net/cdn/shop/files/Good-UTR-Rating-V03-1280x990-curve-of-utr-rating.png?v=1740085669')), // TODO: Add URL to asset file
              child: PrettyText('What UTR should I use?', style: TextStyle(color: AppColors.blue), textAlign: TextAlign.center),
            ),
          ),
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'UTR Lower Than'),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null) return null;

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
          validator: (value) {
            if (value == null) return null;
            return utrValueValidator(value, context);
          },
          controller: utrGtController,
        ),
      ],
    );
  }
}
