import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../assets/index.dart';
import '../../global_helpers/index.dart';
import '../../global_widgets/header/index.dart';
import '../../global_widgets/index.dart';
import '../../models/index.dart';
import '../../routes/index.dart';
import '../../state/index.dart';
import '../login/widgets/containers.dart';
import 'widgets/calendar_view.dart';
import 'widgets/schedule_header.dart';

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
    super.initState();
    _dateInView = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final clubs = ref.watch(clubsProvider);
    final clubsNotifier = ref.read(clubsProvider.notifier);
    final user = ref.watch(userProvider);

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
      body: ContainerWithBackground(
        imagePath: homeBackgroundPng,
        child: EventfulWidget(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: ScheduleHeader(
                    clubSelected: _clubSelected!,
                    courts: courts,
                    courtSelected: _courtSelected!,
                    setState: (newValue) => setState(() {
                      _courtSelected = courts.firstWhere((court) => court.id == newValue);
                      clubsNotifier.loadPublicBookings(_clubSelected!, _courtSelected!, _dateInView);
                      clubsNotifier.loadPrivateBookings(_clubSelected!, _courtSelected!, _dateInView, user.uid);
                    }),
                  ),
                ),
                CalendarView(clubSelected: _clubSelected!, courtSelected: _courtSelected!, dateInView: _dateInView, setDateInView: setDateInView),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
