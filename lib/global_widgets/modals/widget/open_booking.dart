import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
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
import '../../../strings/index.dart';
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
    final userNotifier = ref.read(userProvider.notifier);
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

    final payload = CreateMemberBookingPayload(
      booking: newBooking,
      isOpenBooking: true, // * This is the only difference between open and closed booking
    );

    final creatingMsg = context.localeString(BookingFormStrings.creating);
    final createdMsg = context.localeString(BookingFormStrings.created);
    final errorMsg = context.localeString(BookingFormStrings.errorCreating);
    Navigator.of(context).pop();
    eventsNotifier.showLoading(title: creatingMsg);
    final result = await cloudFunctionsNotifier.createBooking(payload);
    eventsNotifier.hideLoading();
    final newBookingId = result.data;
    final success = result.responseStatus.code == CFResponseCode.ok;
    if (success) {
      final updatedBooking = newBooking.copyWith(id: newBookingId);
      clubsNotifier.addBooking(court: widget.courtSelected, booking: updatedBooking, isPrivate: false);
      userNotifier.addUserBooking(updatedBooking);
      eventsNotifier.showMessage(messageType: MessageType.success, message: createdMsg);
    } else {
      eventsNotifier.showMessage(messageType: MessageType.error, message: result.errorMessage ?? errorMsg);
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
                    text: context.localeString(BookingFormStrings.bookingTab),
                    onPressed: widget.switchBookingMode,
                    color: AppColors.grey,
                  ),
                  TbTextButton(
                    text: context.localeString(BookingFormStrings.lookForPlayer),
                    color: AppColors.primaryGreen,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // ^ =============== TITLE FIELD ===============
            TextFormField(
              initialValue: widget.titleValue,
              decoration: InputDecoration(
                labelText: context.localeString(BookingFormStrings.titleLabel),
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
            // ^ =============== RESTRICTIONS FIELD ===============
            DropdownButtonFormField<bool>(
              initialValue: _withRestrictions,
              decoration: InputDecoration(labelText: context.localeString(BookingFormStrings.restrictionsLabel)),
              items: [
                DropdownMenuItem(value: true, child: PrettyText(context.localeString(GeneralStrings.yes))),
                DropdownMenuItem(value: false, child: PrettyText(context.localeString(GeneralStrings.no))),
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
                  validationError = context.localeString(BookingFormStrings.pleaseEnterRestriction);
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
            // ^ =============== END DATE FIELD ===============
            TextFormField(
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
            // ^ =============== BUTTONS ===============
            const SizedBox(height: 10),
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

  void utrGtListener() {
    final utrGreaterThan = double.tryParse(utrGtController.text);
    if (utrGreaterThan == null) {
      return;
    }
    final newBookingRestrictions = widget.bookingRestrictions.copyWith(utrGt: utrGreaterThan);
    widget.setBookingRestrictions(newBookingRestrictions);
  }

  void utrLtListener() {
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
          initialValue: _utrVerified,
          decoration: InputDecoration(labelText: context.localeString(BookingFormStrings.utrVerified)),
          items: [
            DropdownMenuItem(value: true, child: PrettyText(context.localeString(GeneralStrings.yes))),
            DropdownMenuItem(value: false, child: PrettyText(context.localeString(GeneralStrings.no))),
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
          initialValue: _genderFilter,
          decoration: InputDecoration(labelText: context.localeString(BookingFormStrings.genderLabel)),
          items: [
            DropdownMenuItem(value: null, child: PrettyText(context.localeString(BookingFormStrings.anyOption))),
            DropdownMenuItem(value: Gender.male, child: PrettyText(context.localeString(BookingFormStrings.maleOption))),
            DropdownMenuItem(value: Gender.female, child: PrettyText(context.localeString(BookingFormStrings.femaleOption))),
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
              onTap: () => launchUrl(
                  Uri.parse('https://www.utrsports.net/cdn/shop/files/Good-UTR-Rating-V03-1280x990-curve-of-utr-rating.png?v=1740085669')),
              child: PrettyText(context.localeString(BookingFormStrings.whatUtr), style: TextStyle(color: AppColors.blue), textAlign: TextAlign.center),
            ),
          ),
        ),
        TextFormField(
          decoration: InputDecoration(labelText: context.localeString(BookingFormStrings.utrLowerThan)),
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
          decoration: InputDecoration(labelText: context.localeString(BookingFormStrings.utrGreaterThan)),
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
