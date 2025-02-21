import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/index.dart';

class PlayerIcon extends StatelessWidget {
  const PlayerIcon({
    super.key,
    required this.player,
  });

  final ConfirmedPlayerData player;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: player.photoUrl,
      fit: BoxFit.cover,
      cacheKey: player.photoUrl,
      height: 30,
      width: 30,
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
