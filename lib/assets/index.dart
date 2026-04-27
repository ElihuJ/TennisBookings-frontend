import 'package:flutter/foundation.dart' show kIsWeb;

import '../config/config.dart';
import '../global_types/index.dart';

final _config = Config();

// Web preserves the original environment-conditional paths.
// Native always needs the 'assets/' prefix — Flutter's asset system requires it.
final _iconsPrefix = kIsWeb
    ? (_config.environment == Environment.prod || _config.environment == Environment.uat
        ? 'assets/app_icons'
        : 'app_icons')
    : 'assets/app_icons';

final _imagesPrefix = kIsWeb
    ? (_config.environment == Environment.prod || _config.environment == Environment.uat
        ? 'assets/images'
        : 'images')
    : 'assets/images';

//* Icons
final logoPgn = '$_iconsPrefix/logo.png';

// * SVGs
final googleSvg = '$_iconsPrefix/google.svg';
final logoWhiteSvg = '$_iconsPrefix/logo_white.svg';
final logoIconSvg = '$_iconsPrefix/logo_icon.svg';
final logoPrimarySvg = '$_iconsPrefix/logo_primary.svg';

// * Images
final homeBackgroundPng = '$_imagesPrefix/home_background.jpg';
