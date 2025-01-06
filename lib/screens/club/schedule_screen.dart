import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/global_helpers/index.dart';
import 'package:tennisbookings/global_widgets/loading/loading_screen.dart';
import 'package:tennisbookings/screens/club/widgets/schedule_header.dart';

import '../../global_widgets/header/index.dart';
import '../../models/index.dart';
import '../../routes/index.dart';
import '../../state/clubs/index.dart';
import 'widgets/calendar_view.dart';

class ScheduleScreen extends StatefulHookConsumerWidget {
  final ClubSelectedQueryParams clubSelectedQueryParams;
  const ScheduleScreen({super.key, required this.clubSelectedQueryParams});
  static const String route = 'ClubSchedule';

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreen();
}

class _ScheduleScreen extends ConsumerState<ScheduleScreen> {
  Court? _courtSelected;
  Club? _clubSelected;
  String get paramClubId => widget.clubSelectedQueryParams.clubId;
  late DateTime _dateInView;
  void setDateInView(DateTime newDate) {
    setState(() {
      _dateInView = newDate;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dateInView = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final clubs = ref.watch(clubsProvider);
    final clubsNotifier = ref.read(clubsProvider.notifier);

    // * This will execute when refreshing page or loading specific URL directly
    // ^ ============================== If clubs are not loaded  ==============================
    if (clubs.isEmpty) {
      clubsNotifier.loadClub(paramClubId);
      return const LoadingScreen(message: 'Loading clubs...');
    }

    // ^ ============================== If club is not found  ==============================

    _clubSelected = findByIdOrNull(clubs, paramClubId);
    if (_clubSelected == null) return NotFoundScreen();

    // ^ ============================== Loading courts  ==============================

    List<Court> courts = sortAlphabetically(_clubSelected!.courts);

    if (courts.isEmpty) {
      clubsNotifier.loadCourts(_clubSelected!);
      return const LoadingScreen(message: 'Loading courts..');
    }

    // ^ ============================== Setting default court ==============================

    _courtSelected ??= courts.first;

    // ^ ==============================  Main View  =======================================

    return Scaffold(
      appBar: Header(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScheduleHeader(
              clubSelected: _clubSelected!,
              courts: courts,
              courtSelected: _courtSelected!,
              setState: (newValue) => setState(() {
                _courtSelected = courts.firstWhere((court) => court.id == newValue);
              }),
            ),
            CalendarView(clubSelected: _clubSelected!, courtSelected: _courtSelected!, dateInView: _dateInView, setDateInView: setDateInView),
          ],
        ),
      ),
    );
  }
}
