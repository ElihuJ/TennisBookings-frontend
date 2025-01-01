import 'package:flutter/material.dart';
import 'package:tennisbookings/theme/index.dart';

import '../../../models/index.dart';
import '../../../state/index.dart';

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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 50),
          DropdownButton<String>(
            value: courtSelected.id,
            onChanged: (String? newValue) {
              if (newValue != courtSelected.id) {
                setState(newValue);
              }
            },
            items: sortedCourts.map<DropdownMenuItem<String>>((court) {
              return DropdownMenuItem<String>(
                value: court.id,
                child: Container(margin: EdgeInsets.all(5), child: Text(court.name)),
              );
            }).toList(),
            dropdownColor: AppColors.backgroundGreen,
            icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryGreen),
            underline: Container(),
            borderRadius: BorderRadius.circular(15),
          ),
        ],
      ),
    );
  }
}
