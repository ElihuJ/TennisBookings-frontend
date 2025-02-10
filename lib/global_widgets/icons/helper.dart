import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../theme/index.dart';

final space = 10.0;
final utrWidth = 120.0;
final nameWidth = 150.0;

class UtrBox extends StatelessWidget {
  const UtrBox({super.key, required this.utrRating, required this.verified});

  final double? utrRating;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        utrRating != null ? Text('UTR: $utrRating') : const SizedBox(),
        const SizedBox(width: 5),
        verified ? const Icon(Icons.verified, color: AppColors.blue) : const SizedBox(),
      ],
    );
  }
}

class FieldBox extends StatelessWidget {
  const FieldBox({super.key, this.child, this.width = 30});

  final Widget? child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(width: width, child: child),
    );
  }
}

class LoadingRow extends StatelessWidget {
  const LoadingRow({super.key});

  getLoadingText() {
    return LoadingAnimationWidget.waveDots(color: AppColors.primaryGreen, size: 30);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FieldBox(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
          SizedBox(width: space),
          FieldBox(width: 30, child: getLoadingText()),
          SizedBox(width: nameWidth - 30),
          SizedBox(width: space),
          FieldBox(width: 30, child: getLoadingText()),
        ],
      ),
    );
  }
}
