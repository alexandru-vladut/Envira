import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';
import 'package:flutter_app_base/modules/work_log/pages/calendar_page.dart';
import 'package:flutter_app_base/modules/challenges/pages/challenges_page.dart';
import 'package:flutter_app_base/modules/home/widgets/action_list_data.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/core/theme/home_theme.dart';

class ActionCard extends StatefulWidget {
  const ActionCard({
    super.key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
  });

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> with TickerProviderStateMixin {
  AnimationController? animationController;
  List<ActionListData> actionListData = ActionListData.tabIconsList;

  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    super.initState();
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(0.0, 30 * (1.0 - widget.mainScreenAnimation!.value), 0.0),
            child: SizedBox(
              height: 216,
              width: double.infinity,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 0, bottom: 0, right: 16, left: 16),
                itemCount: actionListData.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  final int count = actionListData.length > 10 ? 10 : actionListData.length;
                  final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animationController!,
                      curve: Interval((1 / count) * index, 1.0, curve: Curves.fastOutSlowIn),
                    ),
                  );
                  animationController?.forward();

                  return ActionsView(
                    actionListData: actionListData[index],
                    animation: animation,
                    animationController: animationController!,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class ActionsView extends StatelessWidget {
  const ActionsView({
    super.key,
    this.actionListData,
    this.animationController,
    this.animation,
  });

  final ActionListData? actionListData;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(100 * (1.0 - animation!.value), 0.0, 0.0),
            child: GestureDetector(
              onTap: () async {
                String title = actionListData!.titleTxt;
                if (title == 'Recycle') {
                  await recycleService.scanBarcode(context);
                } else if (title == 'Work') {
                  AppNavigator.navigateTo(page: CalendarPage());
                } else if (title == 'Challenges') {
                  AppNavigator.navigateTo(page: ChallengesPage());
                }
              },
              child: SizedBox(
                width: 130,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 32, left: 8, right: 8, bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: HexColor(
                                actionListData!.endColor,
                              ).withOpacity(0.6),
                              offset: const Offset(1.1, 4.0),
                              blurRadius: 8.0,
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: <HexColor>[
                              HexColor(actionListData!.startColor),
                              HexColor(actionListData!.endColor),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(8.0),
                            bottomLeft: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(54.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 54,
                            left: 16,
                            right: 10,
                            bottom: 8,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                actionListData!.titleTxt,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: HomeAppTheme.fontName,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  letterSpacing: 0.2,
                                  color: HomeAppTheme.white,
                                ),
                              ),

                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        actionListData!.actions!.join('\n'),
                                        style: const TextStyle(
                                          fontFamily: HomeAppTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          letterSpacing: 0.2,
                                          color: HomeAppTheme.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: HomeAppTheme.nearlyWhite,
                                      shape: BoxShape.circle,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: HomeAppTheme.nearlyBlack
                                              .withOpacity(0.4),
                                          offset: const Offset(8.0, 8.0),
                                          blurRadius: 8.0,
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Icon(
                                        Icons.add,
                                        color: HexColor(
                                          actionListData!.endColor,
                                        ),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: HomeAppTheme.nearlyWhite.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 12,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.asset(actionListData!.imagePath),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
