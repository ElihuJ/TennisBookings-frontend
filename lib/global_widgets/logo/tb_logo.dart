import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../assets/index.dart';

/// White/reversed logo — for use on dark or gradient green backgrounds.
class TbLogoWhite extends StatelessWidget {
  const TbLogoWhite({super.key, this.width = 200});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(logoWhiteSvg, width: width);
  }
}

/// Primary logo — for use on light/white backgrounds.
class TbLogoDark extends StatelessWidget {
  const TbLogoDark({super.key, this.width = 200});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(logoPrimarySvg, width: width);
  }
}

/// Badge icon only — hex with racket. For small/compact placements.
class TbLogoIcon extends StatelessWidget {
  const TbLogoIcon({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(logoIconSvg, width: size, height: size);
  }
}
