import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/index.dart';
import '../../theme/index.dart';

class PlayerIcon extends StatelessWidget {
  const PlayerIcon({
    super.key,
    required this.player,
    this.size = 35,
  });

  final ConfirmedPlayerData player;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: player.photoUrl,
      fit: BoxFit.cover,
      cacheKey: player.photoUrl,
      height: size,
      width: size,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        backgroundImage: imageProvider,
        radius: 15,
      ),
      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person),
      ),
    );
  }
}

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, required this.verified});

  final bool verified;

  @override
  Widget build(BuildContext context) {
    return verified
        ? const Icon(
            Icons.verified,
            color: AppColors.blue,
            size: 25,
          )
        : const Icon(
            Icons.question_mark_rounded,
            color: AppColors.grey,
            size: 20,
          );
  }
}
