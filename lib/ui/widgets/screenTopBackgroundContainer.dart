import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class ScreenTopBackgroundContainer extends StatelessWidget {
  final Widget? child;
  final double? heightPercentage;
  final EdgeInsets? padding;

  const ScreenTopBackgroundContainer({
    super.key,
    this.child,
    this.heightPercentage,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = Utils.getColorScheme(context).primary;

    /// CHANGE STATUS BAR COLOR HERE
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: bgColor,                 // ← same color as container
        statusBarIconBrightness: Brightness.light, // for dark bg use light icons
      ),
    );

    return Container(
      padding: padding ??
          EdgeInsets.only(
            top: MediaQuery.of(context).padding.top +
                Utils.screenContentTopPadding,
          ),
      alignment: Alignment.topCenter,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height *
          (heightPercentage ?? Utils.appBarBiggerHeightPercentage),
      decoration: BoxDecoration(
        color: bgColor, // ← your current bg color
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: child,
    );
  }
}

