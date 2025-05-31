import 'package:flutter/material.dart';

import '../../../global_widgets/index.dart';
import '../../../state/index.dart';
import '../../../theme/index.dart';
import 'card.dart';

double _fontTitleSize = 24.0;
double _fontSize = 16.0;
Color _fontColor = AppColors.white;

class ContactCard extends StatelessWidget {
  const ContactCard({super.key, required this.clubSelected});

  final Club clubSelected;

  @override
  Widget build(BuildContext context) {
    return CardTemplate(
      backgroundColor: AppColors.blueGrey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PrettyText(
            'Contact Information',
            style: TextStyle(
              fontSize: _fontTitleSize,
              color: _fontColor,
            ),
          ),
          Divider(color: _fontColor),
          SelectableText(
            'Email: ${clubSelected.contactEmail}',
            style: TextStyle(
              fontSize: _fontSize,
              color: _fontColor,
            ),
          ),
          SelectableText(
            'Phone: ${clubSelected.contactPhone}',
            style: TextStyle(
              fontSize: _fontSize,
              color: _fontColor,
            ),
          ),
        ],
      ),
    );
  }
}
