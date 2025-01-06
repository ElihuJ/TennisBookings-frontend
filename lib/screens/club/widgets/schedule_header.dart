import 'package:flutter/material.dart';

import '../../../models/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';

class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({super.key, required this.clubSelected, required this.courts, required this.courtSelected, required this.setState});

  final Club clubSelected;
  final Court courtSelected;
  final List<Court> courts;
  final void Function(String? newValue) setState;

  @override
  Widget build(BuildContext context) {
    final sortedCourts = courts..sort((a, b) => a.name.compareTo(b.name));

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            clubSelected.name,
            style: selectedTheme.textTheme.bodyLarge,
          ),
          const SizedBox(width: 50),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
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
                return DropdownMenuItem<String>(
                  value: court.id,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    margin: EdgeInsets.all(5),
                    child: Text(
                      court.name,
                    ),
                  ),
                );
              }).toList(),
              dropdownColor: AppColors.white,
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
