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
import '../../../theme/colors.dart';
import 'modal_shell.dart';

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
  Config config = Config();

  void setBookingRestrictions(BookingRestrictions r) => _bookingRestrictions = r;

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

    final payload = CreateMemberBookingPayload(booking: newBooking, isOpenBooking: true);

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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ModalTabRow(
            leftLabel: context.localeString(BookingFormStrings.bookingTab),
            rightLabel: context.localeString(BookingFormStrings.lookForPlayer),
            leftActive: false,
            onLeftTap: widget.switchBookingMode,
            onRightTap: () {},
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: widget.titleValue,
            decoration: modalFieldDecoration(label: context.localeString(BookingFormStrings.titleLabel), prefixIcon: Icons.title),
            onChanged: widget.setTitleValue,
            validator: (v) => (v == null || v.isEmpty) ? '' : null,
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          DropdownButtonFormField<bool>(
            initialValue: _withRestrictions,
            decoration:
                modalFieldDecoration(label: context.localeString(BookingFormStrings.restrictionsLabel), prefixIcon: Icons.tune_outlined),
            items: [
              DropdownMenuItem(value: true, child: Text(context.localeString(GeneralStrings.yes))),
              DropdownMenuItem(value: false, child: Text(context.localeString(GeneralStrings.no))),
            ],
            onChanged: (v) {
              setState(() {
                _withRestrictions = v!;
                _bookingRestrictions = _withRestrictions ? BookingRestrictions.empty() : null;
              });
            },
            validator: (v) => v == null ? context.localeString(BookingFormStrings.pleaseEnterRestriction) : null,
          ),
          if (_withRestrictions) ...[
            const SizedBox(height: 12),
            RestrictionsField(bookingRestrictions: _bookingRestrictions!, setBookingRestrictions: setBookingRestrictions),
          ],
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
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
          const SizedBox(height: 16),
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

class RestrictionsField extends StatefulWidget {
  const RestrictionsField({super.key, required this.bookingRestrictions, required this.setBookingRestrictions});
  final BookingRestrictions bookingRestrictions;
  final Function(BookingRestrictions) setBookingRestrictions;

  @override
  RestrictionsFieldState createState() => RestrictionsFieldState();
}

class RestrictionsFieldState extends State<RestrictionsField> {
  late bool _utrVerified;
  late Gender? _genderFilter;
  TextEditingController utrGtController = TextEditingController();
  TextEditingController utrLtController = TextEditingController();

  void utrGtListener() {
    final v = double.tryParse(utrGtController.text);
    if (v != null) widget.setBookingRestrictions(widget.bookingRestrictions.copyWith(utrGt: v));
  }

  void utrLtListener() {
    final v = double.tryParse(utrLtController.text);
    if (v != null) widget.setBookingRestrictions(widget.bookingRestrictions.copyWith(utrLt: v));
  }

  @override
  void initState() {
    super.initState();
    _utrVerified = widget.bookingRestrictions.utrVerified;
    _genderFilter = widget.bookingRestrictions.gender;
    if (widget.bookingRestrictions.utrGt != null) utrGtController.text = widget.bookingRestrictions.utrGt.toString();
    if (widget.bookingRestrictions.utrLt != null) utrLtController.text = widget.bookingRestrictions.utrLt.toString();
    utrGtController.addListener(utrGtListener);
    utrLtController.addListener(utrLtListener);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE8E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<bool>(
            initialValue: _utrVerified,
            decoration:
                modalFieldDecoration(label: context.localeString(BookingFormStrings.utrVerified), prefixIcon: Icons.verified_outlined),
            items: [
              DropdownMenuItem(value: true, child: Text(context.localeString(GeneralStrings.yes))),
              DropdownMenuItem(value: false, child: Text(context.localeString(GeneralStrings.no))),
            ],
            onChanged: (v) {
              setState(() {
                _utrVerified = v!;
                widget.setBookingRestrictions(widget.bookingRestrictions.copyWith(utrVerified: _utrVerified));
              });
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<Gender?>(
            initialValue: _genderFilter,
            decoration: modalFieldDecoration(label: context.localeString(BookingFormStrings.genderLabel), prefixIcon: Icons.wc_outlined),
            items: [
              DropdownMenuItem(value: null, child: Text(context.localeString(BookingFormStrings.anyOption))),
              DropdownMenuItem(value: Gender.male, child: Text(context.localeString(BookingFormStrings.maleOption))),
              DropdownMenuItem(value: Gender.female, child: Text(context.localeString(BookingFormStrings.femaleOption))),
            ],
            onChanged: (v) {
              setState(() {
                _genderFilter = v;
                widget.setBookingRestrictions(widget.bookingRestrictions.copyWith(gender: _genderFilter));
              });
            },
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => launchUrl(
                Uri.parse('https://www.utrsports.net/cdn/shop/files/Good-UTR-Rating-V03-1280x990-curve-of-utr-rating.png?v=1740085669')),
            icon: const Icon(Icons.help_outline, size: 16),
            label: Text(context.localeString(BookingFormStrings.whatUtr)),
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryGreen, textStyle: const TextStyle(fontSize: 13)),
          ),
          const SizedBox(height: 6),
          TextFormField(
            decoration:
                modalFieldDecoration(label: context.localeString(BookingFormStrings.utrLowerThan), prefixIcon: Icons.arrow_downward),
            keyboardType: TextInputType.number,
            controller: utrLtController,
            validator: (v) {
              if (v == null) return null;
              final err = utrValueValidator(v, context);
              if (err != null) return err;
              return validateUtrComparison(utrGt: utrGtController.text, utrLt: utrLtController.text, context: context);
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            decoration:
                modalFieldDecoration(label: context.localeString(BookingFormStrings.utrGreaterThan), prefixIcon: Icons.arrow_upward),
            keyboardType: TextInputType.number,
            controller: utrGtController,
            validator: (v) => v == null ? null : utrValueValidator(v, context),
          ),
        ],
      ),
    );
  }
}
