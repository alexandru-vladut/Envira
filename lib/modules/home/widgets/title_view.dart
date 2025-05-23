import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/home_theme.dart';

class TitleView extends StatelessWidget {
  final String titleTxt;
  final AnimationController? animationController;
  final Animation<double>? animation;

  const TitleView({
    super.key,
    this.titleTxt = "",
    this.animationController,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      titleTxt,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontFamily: HomeAppTheme.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        letterSpacing: 0.5,
                        color: HomeAppTheme.lightText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
