import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../global_helpers/index.dart';
import '../../theme/index.dart';

class TbImageField<T extends HasPhotoUrl> extends StatelessWidget {
  final String? photoUrl;
  final Uint8List imageBytes;
  final Future Function() selectImage;

  const TbImageField({
    super.key,
    required this.photoUrl,
    required this.imageBytes,
    required this.selectImage,
  });

  @override
  Widget build(BuildContext context) {
    final currentProfilePhoto = photoUrl;

    return GestureDetector(
      onTap: selectImage,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        height: 100,
        width: 100,
        decoration: const BoxDecoration(shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: AppColors.primaryGreen, width: 1))),
        child: ClipOval(
          child: imageBytes.isNotEmpty
              ? Image.memory(
                  imageBytes,
                  fit: BoxFit.scaleDown,
                )
              : currentProfilePhoto != null && currentProfilePhoto.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: currentProfilePhoto,
                      cacheKey: currentProfilePhoto,
                      key: Key(currentProfilePhoto),
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) {
                        error.tbLogger('Error loading image: $error');
                        return const Icon(Icons.error);
                      },
                      fit: BoxFit.contain,
                    )
                  : const Icon(
                      Icons.person,
                      size: 30,
                    ),
        ),
      ),
    );
  }
}
