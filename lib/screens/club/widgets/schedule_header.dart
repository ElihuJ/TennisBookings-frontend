import 'package:flutter/material.dart';

import '../../../global_helpers/index.dart';
import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';
import '../club_details_screen.dart';

class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({super.key, required this.clubSelected, required this.courts, required this.courtSelected, required this.setState});

  final Club clubSelected;
  final Court courtSelected;
  final List<Court> courts;
  final void Function(String? newValue) setState;

  @override
  Widget build(BuildContext context) {
    final sortedCourts = courts..sort((a, b) => a.name.compareTo(b.name));
    final mobileScreen = isMobile(context);
    final selectedCourtColor = getSurfaceColor(courtSelected.surface);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('${ClubDetailsScreen.route}?clubId=${clubSelected.id}');
              },
              child: Container(
                width: mobileScreen ? 150 : 200,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: selectedCourtColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  clubSelected.name,
                  style: selectedTheme.textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          SizedBox(width: mobileScreen ? 0 : 20),
          Container(
            decoration: BoxDecoration(
              color: selectedCourtColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: DropdownButton<String>(
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
                  value: court.id,
                  child: Container(
                    decoration: BoxDecoration(
                      color: courtColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(10),
                    margin: EdgeInsets.all(5),
                    child: Text(courtString),
                  ),
                );
              }).toList(),
              dropdownColor: selectedCourtColor,
              style: selectedTheme.textTheme.bodyLarge,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryGreen),
              underline: Container(),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ],
      ),
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
