import 'package:flutter/material.dart';

import '../../theme/index.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({super.key, required this.icon, this.title, this.description});
  final String? description;

  final Icon icon;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.almostWhite,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(200),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 16.0),
          Text(
            title ?? '',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          Text(
            description ?? '',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.blueGrey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
