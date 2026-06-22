import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Logo J FIGHT — asset em assets/images/logo.png
class JFightLogoImage extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;
  final BoxFit fit;
  final Color backgroundColor;

  const JFightLogoImage({
    super.key,
    this.height = 88,
    this.width,
    this.borderRadius = 16,
    this.fit = BoxFit.contain,
    this.backgroundColor = corFundoEscuro,
  });

  static const assetPath = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    final w = width ?? height;
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: ColoredBox(
          color: backgroundColor,
          child: Image.asset(
            assetPath,
            width: w,
            height: height,
            fit: fit,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) {
              return SizedBox(
                width: w,
                height: height,
                child: Icon(Icons.sports_martial_arts, size: height * 0.45, color: Colors.grey.shade400),
              );
            },
          ),
        ),
      ),
    );
  }
}
