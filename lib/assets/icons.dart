import '../config/config.dart';
import '../types/index.dart';

final config = Config();

final _prefix = config.environment == Environment.prod ? 'assets/app_icons' : 'app_icons';

//* Icons
final logoPgn = '$_prefix/logo.png';

// * SVGs
final googleSvg = '$_prefix/google.svg';
