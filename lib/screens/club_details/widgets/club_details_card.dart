import 'package:flutter/material.dart';
import 'package:tennisbookings/theme/index.dart';

import '../../../global_widgets/index.dart';
import '../../../state/index.dart';
import 'card.dart';

double _fontTitleSize = 24.0;
double _fontSize = 16.0;
Color _fontColor = AppColors.white;

class ClubDetailsCard extends StatelessWidget {
  const ClubDetailsCard({super.key, required this.clubSelected});

  final Club clubSelected;

  @override
  Widget build(BuildContext context) {
    const space = SizedBox(height: 16);
    return CardTemplate(
      backgroundColor: AppColors.blueGrey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PrettyText(
            'Club Details',
            textAlign: TextAlign.center,
            fontSize: _fontTitleSize,
            color: _fontColor,
          ),
          const Divider(),
          PrettyText(
            'Hard Courts: ${clubSelected.hardCourts}',
            fontSize: _fontSize,
            color: _fontColor,
          ),
          PrettyText(
            'Clay Courts: ${clubSelected.clayCourts}',
            fontSize: _fontSize,
            color: _fontColor,
          ),
          PrettyText(
            'Grass Courts: ${clubSelected.grassCourts}',
            fontSize: _fontSize,
            color: _fontColor,
          ),
          PrettyText(
            'Other Surface Courts: ${clubSelected.otherSurfaceCourts}',
            fontSize: _fontSize,
            color: _fontColor,
          ),
          space,
          PrettyText(
            'Public Bookings Allowed: ${clubSelected.onlyMembers ? "No" : "Yes"}',
            fontSize: _fontSize,
            color: _fontColor,
          ),
          space,
          PrettyText(
            'Annual Membership Fee: \$${clubSelected.annualFee.toStringAsFixed(2)}',
            fontSize: _fontSize,
            color: _fontColor,
          ),
          if (clubSelected.casualBooking != null)
            PrettyText(
              'Casual Booking: \$${clubSelected.casualBooking!.toStringAsFixed(2)}',
              fontSize: _fontSize,
              color: _fontColor,
            ),
          space,
          PrettyText(
            'Total Members: ${clubSelected.memberIds.length}',
            fontSize: _fontSize,
            color: _fontColor,
          ),
        ],
      ),
    );
  }
}
