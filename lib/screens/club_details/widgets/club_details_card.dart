import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../../../global_widgets/index.dart';
import '../../../state/index.dart';
import '../../../strings/index.dart';
import '../../../theme/index.dart';
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
            context.localeString(ClubsStrings.detailsTitle),
            textAlign: TextAlign.center,
            fontSize: _fontTitleSize,
            color: _fontColor,
          ),
          const Divider(),
          PrettyText(
            '${context.localeString(ClubsStrings.hardCourts)} ${clubSelected.hardCourts}',
            fontSize: _fontSize,
            color: _fontColor,
          ),
          PrettyText(
            '${context.localeString(ClubsStrings.clayCourts)} ${clubSelected.clayCourts}',
            fontSize: _fontSize,
            color: _fontColor,
          ),
          PrettyText(
            '${context.localeString(ClubsStrings.grassCourts)} ${clubSelected.grassCourts}',
            fontSize: _fontSize,
            color: _fontColor,
          ),
          PrettyText(
            '${context.localeString(ClubsStrings.otherCourts)} ${clubSelected.otherSurfaceCourts}',
            fontSize: _fontSize,
            color: _fontColor,
          ),
          space,
          PrettyText(
            '${context.localeString(ClubsStrings.publicBookingsAllowed)} ${clubSelected.onlyMembers ? context.localeString(GeneralStrings.no) : context.localeString(GeneralStrings.yes)}',
            fontSize: _fontSize,
            color: _fontColor,
          ),
          space,
          PrettyText(
            '${context.localeString(ClubsStrings.annualMembershipFee)} \$${clubSelected.annualFee.toStringAsFixed(2)}',
            fontSize: _fontSize,
            color: _fontColor,
          ),
          if (clubSelected.casualFee != null)
            PrettyText(
              '${context.localeString(ClubsStrings.casualBooking)} \$${clubSelected.casualFee!.toStringAsFixed(2)}',
              fontSize: _fontSize,
              color: _fontColor,
            ),
          space,
          PrettyText(
            '${context.localeString(ClubsStrings.totalMembers)} ${clubSelected.memberIds.length}',
            fontSize: _fontSize,
            color: _fontColor,
          ),
        ],
      ),
    );
  }
}
