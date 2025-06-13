import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/modules/home/widgets/action_card.dart';
import 'package:flutter_app_base/modules/home/providers/home_data_provider.dart';
import 'package:flutter_app_base/modules/home/widgets/home_header.dart';
import 'package:flutter_app_base/modules/home/widgets/overview_card.dart';
import 'package:flutter_app_base/modules/home/widgets/title_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.animationController});

  final AnimationController? animationController;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    if (widget.animationController != null) {
      widget.animationController!.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    const int listViewCount = 5;

    return HomeDataProvider(
      builder: (data) =>
        Scaffold(
          backgroundColor: CustomTheme.white,
          body: ListView(
            padding: const EdgeInsets.only(top: 50),
            children: [
              HomeHeader(userName: data.userName),
              const SizedBox(height: 20),
              TitleView(
                titleTxt: 'Overview',
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: widget.animationController!,
                    curve: const Interval((1 / listViewCount) * 0, 1.0, curve: Curves.fastOutSlowIn),
                  ),
                ),
                animationController: widget.animationController!,
              ),
              const SizedBox(height: 12),
              OverviewCard(
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: widget.animationController!,
                    curve: const Interval((1 / listViewCount) * 1, 1.0, curve: Curves.fastOutSlowIn),
                  ),
                ),
                animationController: widget.animationController!,
                currentGoalPoints: data.currentGoalPoints,
                goalPoints: data.goalPoints,
                allTimePoints: data.allTimePoints,
                goalCompletedPercentage: data.goalCompletedPercentage,
                emissionsSaved: data.emissionsSaved,
                goalTimeLeft: data.goalTimeLeft,
                userRank: data.userRank,
              ),
              const SizedBox(height: 24),
              TitleView(
                titleTxt: 'Actions',
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: widget.animationController!,
                    curve: const Interval((1 / listViewCount) * 2, 1.0, curve: Curves.fastOutSlowIn),
                  ),
                ),
                animationController: widget.animationController!,
              ),
              ActionCard(
                mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: widget.animationController!,
                    curve: const Interval((1 / listViewCount) * 3, 1.0, curve: Curves.fastOutSlowIn),
                  ),
                ),
                mainScreenAnimationController: widget.animationController,
              ),
            ],
          ),
        ),
    );
  }
}
