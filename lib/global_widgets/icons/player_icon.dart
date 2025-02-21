import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/index.dart';

class PlayerIcon extends StatelessWidget {
  const PlayerIcon({
    super.key,
    required this.player,
    this.size = 30,
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
