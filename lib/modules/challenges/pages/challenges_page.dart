import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';

List<Map<String, String>> jobListGlobal = [
  {
    'title': 'No Car Week',
    'duration': '7 days',
    'imagePath': 'assets/challenges/no-car.png',
  },
  {
    'title': 'Zero Waste Challenge',
    'duration': '30 days',
    'imagePath': 'assets/challenges/no-waste.png',
  },
  {
    'title': 'Plant-Based Power: Embrace vegetarian meals for a week',
    'duration': '7 days',
    'imagePath': 'assets/challenges/vegetarian.png',
  },
  {
    'title': 'Sustainable Commute Sprint: Compete for the greenest route',
    'duration': '15 days',
    'imagePath': 'assets/challenges/bike.png',
  },
  {
    'title': 'Thrift Shop Challenge: Outfit your week with second-hand finds',
    'duration': '7 days',
    'imagePath': 'assets/challenges/second-hand.png',
  },
  {
    'title': 'Green Thumb Project: Plant greenery at work or community spaces',
    'duration': '60 days',
    'imagePath': 'assets/challenges/plant.png',
  },
];

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {

  List<Map<String, String>> jobList = jobListGlobal;
  List<Map<String, String>> addedJobs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Set the background color to transparent
        elevation: 0, // Remove the shadow
        title: const Text(
          'Challenges',
          style: TextStyle(color: Colors.black),
        ),
        leading: GestureDetector(
          onTap: () => AppNavigator.pop(context: context),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (addedJobs.isNotEmpty) ...[
            const Divider(),
            const Text(
              "Joined",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: addedJobs.map((job) {
                return jobComponent(job: job, isAdded: true);
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
          const Text(
            "Available",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Column(
            children: jobList.map((job) {
              return jobComponent(job: job, isAdded: false);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget jobComponent({required Map<String, String> job, required bool isAdded}) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(job['imagePath']!),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title']!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        job['duration']!,
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                if (isAdded) {
                  addedJobs.remove(job);
                  jobList.insert(0, job);
                } else {
                  addedJobs.insert(0, job);
                  jobList.remove(job);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAdded ? Colors.red : Colors.green,
              ),
              child: Icon(
                isAdded ? Icons.remove : Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
