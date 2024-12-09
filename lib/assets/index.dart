import '../config/config.dart';
import '../global_types/index.dart';

final config = Config();

final _iconsPrefix = config.environment == Environment.prod ? 'assets/app_icons' : 'app_icons';
final _imagesPrefix = config.environment == Environment.prod ? 'assets/images' : 'images';

//* Icons
final logoPgn = '$_iconsPrefix/logo.png';

// * SVGs
final googleSvg = '$_iconsPrefix/google.svg';

// * Images
final homeBackgroundPng = '$_imagesPrefix/home_background.png';
final amanda1Png = '$_imagesPrefix/amanda_1.png';
final anthony1Png = '$_imagesPrefix/anthony_1.png';
final elihu1jpeg = '$_imagesPrefix/elihu_1.jpeg';
final elihu2jpg = '$_imagesPrefix/elihu_2.jpg';
final elihu3jpeg = '$_imagesPrefix/elihu_3.jpeg';
final matt1jpg = '$_imagesPrefix/matt_1.jpg';
