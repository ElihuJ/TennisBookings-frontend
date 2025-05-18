import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/global_widgets/index.dart';

import '../../../global_helpers/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';
import '../../club_details/club_details_screen.dart';

final _buttonsHeight = 60.0;

class ScheduleHeader extends HookConsumerWidget {
  const ScheduleHeader({super.key, required this.clubSelected, required this.courts, required this.courtSelected, required this.setState});

  final Club clubSelected;
  final Court courtSelected;
  final List<Court> courts;
  final void Function(String? newValue) setState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortedCourts = courts..sort((a, b) => a.name.compareTo(b.name));
    final mobileScreen = isMobile(context);
    final selectedCourtColor = getSurfaceColor(courtSelected.surface);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ClubDetailsButton(clubSelected: clubSelected, selectedCourtColor: selectedCourtColor),
            mobileScreen ? Container() : _MembershipStatus(clubSelected: clubSelected),
            _CourtSelectionButton(
                selectedCourtColor: selectedCourtColor, courtSelected: courtSelected, setState: setState, sortedCourts: sortedCourts),
          ],
        ),
      ),
    );
  }
}

class _MembershipStatus extends HookConsumerWidget {
  const _MembershipStatus({required this.clubSelected});

  final Club clubSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isMember = user.memberships.any((membership) => membership.clubId == clubSelected.id);
    return isMember
        ? _HeaderButton(
            courtColor: AppColors.secondaryGreen,
            text: 'You are a Member 🎾',
            onTap: () {
              Navigator.of(context).pushNamed('${ClubDetailsScreen.route}?clubId=${clubSelected.id}');
            },
          )
        : Container();
  }
}

class _CourtSelectionButton extends StatelessWidget {
  const _CourtSelectionButton({
    required this.selectedCourtColor,
    required this.courtSelected,
    required this.setState,
    required this.sortedCourts,
  });

  final dynamic selectedCourtColor;
  final Court courtSelected;
  final void Function(String? newValue) setState;
  final List<Court> sortedCourts;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selectedCourtColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButton<String>(
        itemHeight: _buttonsHeight,
        value: courtSelected.id,
        onChanged: (String? newValue) {
          if (newValue != courtSelected.id) {
            setState(newValue);
          }
        },
        items: sortedCourts.map<DropdownMenuItem<String>>((court) {
          final courtString = textToTitleCase('${court.name} - ${court.surface}');
          final courtColor = getSurfaceColor(court.surface);
          return DropdownMenuItem<String>(
            alignment: Alignment.center,
            value: court.id,
            child: _HeaderButton(
              courtColor: courtColor,
              text: courtString,
              padding: EdgeInsets.all(0),
            ),
          );
        }).toList(),
        dropdownColor: Colors.white,
        style: selectedTheme.textTheme.bodyLarge,
        icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryGreen),
        underline: Container(),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.courtColor, required this.text, this.padding, this.onTap});
  final VoidCallback? onTap;

  final dynamic courtColor;
  final String text;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: courtColor,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: padding ?? const EdgeInsets.all(16),
          margin: EdgeInsets.all(15),
          child: PrettyText(
            text,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
      ),
    );
  }
}

class _ClubDetailsButton extends StatelessWidget {
  const _ClubDetailsButton({
    required this.clubSelected,
    required this.selectedCourtColor,
  });

  final Club clubSelected;
  final dynamic selectedCourtColor;

  @override
  Widget build(BuildContext context) {
    return _HeaderButton(
      courtColor: selectedCourtColor,
      text: clubSelected.name,
      onTap: () {
        Navigator.of(context).pushNamed('${ClubDetailsScreen.route}?clubId=${clubSelected.id}');
      },
    );
  }
}

getSurfaceColor(String surface) {
  final surfaceString = surface.toLowerCase();
  switch (surfaceString) {
    case 'grass':
      return SurfaceColors.grass;
    case 'clay':
      return SurfaceColors.clay;
    case 'hard':
      return SurfaceColors.hard;
    default:
      return AppColors.white;
  }
}
