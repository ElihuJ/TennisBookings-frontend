import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../global_widgets/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';
import 'card.dart';

double _fontTitleSize = 24.0;
Color _fontColor = AppColors.white;

class ClubTitleCard extends StatelessWidget {
  const ClubTitleCard({super.key, required this.clubSelected});

  final Club clubSelected;

  @override
  Widget build(BuildContext context) {
    return CardTemplate(
      backgroundColor: AppColors.blueGrey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PrettyText(
            clubSelected.name,
            fontSize: _fontTitleSize,
            color: _fontColor,
            textAlign: TextAlign.center,
          ),
          Divider(color: _fontColor),
          _AddressSection(clubSelected: clubSelected),
        ],
      ),
    );
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection({required this.clubSelected});

  final Club clubSelected;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          final googleMapsUrl = Uri.encodeFull(
            'https://www.google.com/maps/search/?api=1&query=${clubSelected.streetAddress}, ${clubSelected.suburb}, ${clubSelected.city}, ${clubSelected.state}, ${clubSelected.postcode}',
          );
          launchUrl(Uri.parse(googleMapsUrl));
        },
        child: PrettyText(
          color: _fontColor,
          '${clubSelected.streetAddress}, ${clubSelected.suburb}, ${clubSelected.city}, ${clubSelected.state}, ${clubSelected.postcode}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
