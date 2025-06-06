import 'package:flutter/material.dart';
import 'package:flutter_app_base/modules/leaderboard/providers/leaderboard_provider.dart';

List memojiPaths = [
  'assets/memoji/1.png',
  'assets/memoji/2.png',
  'assets/memoji/3.png',
  'assets/memoji/4.png',
  'assets/memoji/5.png',
  'assets/memoji/6.png',
  'assets/memoji/7.png',
  'assets/memoji/8.png',
  'assets/memoji/9.png',
];

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {

  @override
  Widget build(BuildContext context) {
    // print('build() called, ${topThreeUsers?[0].name}');
    // print('build() called, ${otherUsers?[0].name}');
    return LeaderboardProvider(
      builder: (data) =>
        Scaffold(
          body: Stack(
            children: [
              Stack(
                children: [
                  Positioned(
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/leaderboard/leaderboard3.png",
                          fit: BoxFit.cover,
                        ),
                        SizedBox(
                          height: 25,
                          child: Image.asset(
                            "assets/leaderboard/line.png",
                            fit: BoxFit.fill,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 310,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: data.otherUsersAllTime.length,
                      itemBuilder: (context, index) {
                        final item = data.otherUsersAllTime[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 20, left: 20, bottom: 15),
                          child: Row(
                            children: [
      
                              Text(
                                (index + 4).toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 96, 96, 96),
                                ),
                              ),
      
                              const SizedBox(width: 15),
      
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: const Color.fromARGB(255, 240, 240, 240),
                                foregroundImage: AssetImage(memojiPaths[(index + 3) % 9]),
                              ),
      
                              const SizedBox(width: 15),
      
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
      
                              const Spacer(),
      
                              Container(
                                height: 30,
                                width: 70,
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 240, 240, 240),
                                    borderRadius: BorderRadius.circular(50)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
      
                                    const Icon(
                                      Icons.token,
                                      color: Color.fromARGB(255, 255, 187, 0),
                                    ),
      
                                    Text(
                                      item.totalPoints.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                ),
              ),
              const Positioned(
                top: 50,
                left: 100,
                child: Text(
                  "Leaderboard",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Rank 1st
              Positioned(
                top: 110,
                left: 140,
                child: rank(
                    radius: 45.0,
                    height: 3,
                    image: "assets/memoji/1.png",
                    name: data.topThreeUsersAllTime.isNotEmpty ? data.topThreeUsersAllTime[0].name : "N/A",
                    point: data.topThreeUsersAllTime.isNotEmpty ? data.topThreeUsersAllTime[0].totalPoints.toString() : "0",),
              ),
              // for rank 2nd
              Positioned(
                top: 175,
                left: 45,
                child: rank(
                    radius: 30.0,
                    height: 2,
                    image: "assets/memoji/2.png",
                    name: data.topThreeUsersAllTime.length > 1 ? data.topThreeUsersAllTime[1].name : "N/A",
                    point: data.topThreeUsersAllTime.length > 1 ? data.topThreeUsersAllTime[1].totalPoints.toString() : "0",),
              ),
              // For 3rd rank
              Positioned(
                top: 195,
                right: 45,
                child: rank(
                    radius: 30.0,
                    height: 2,
                    image: "assets/memoji/3.png",
                    name: data.topThreeUsersAllTime.length > 2 ? data.topThreeUsersAllTime[2].name : "N/A",
                    point: data.topThreeUsersAllTime.length > 2 ? data.topThreeUsersAllTime[2].totalPoints.toString() : "0",),
              ),
            ],
          ),
        ),
    );
  }

  Column rank({
    required double radius,
    required double height,
    required String image,
    required String name,
    required String point,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: const Color.fromARGB(255, 240, 240, 240),
          foregroundImage: AssetImage(image),
        ),
        SizedBox(
          height: height,
        ),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(
          height: height,
        ),
        Container(
          height: 25,
          width: 70,
          decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(50)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              const Icon(
                Icons.token,
                color: Color.fromARGB(255, 255, 187, 0),
              ),

              Text(
                point,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white),
              ),
            ],
          ),
        )
      ],
    );
  }
}
