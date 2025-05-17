import '../config/config.dart';
import '../global_types/index.dart';

final config = Config();

final _iconsPrefix = config.environment == Environment.prod || config.environment == Environment.uat ? 'assets/app_icons' : 'app_icons';
final _imagesPrefix = config.environment == Environment.prod || config.environment == Environment.uat ? 'assets/images' : 'images';

//* Icons
final logoPgn = '$_iconsPrefix/logo.png';

// * SVGs
final googleSvg = '$_iconsPrefix/google.svg';

// * Images
final homeBackgroundPng = '$_imagesPrefix/home_background.png';
