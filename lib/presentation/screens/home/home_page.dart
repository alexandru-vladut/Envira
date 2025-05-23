// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/presentation/screens/home/action_card.dart';
import 'package:flutter_app_base/presentation/screens/home/home_app_theme.dart';
import 'package:flutter_app_base/presentation/screens/home/overview_card.dart';
import 'package:flutter_app_base/presentation/screens/home/title_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.animationController});

  final AnimationController? animationController;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {

  final user = FirebaseAuth.instance.currentUser!;
  int thisMonthPoints = -1;
  int thisMonthPercentage = -1;
  int userRank = 0;
  UserModel? userData;

  List<Widget> listViews = <Widget>[];

  @override
  void initState() {
    addAllListData();
    getUserData();
    getThisMonthPoints();
    super.initState();
  }

  void getUserData() async {
    
    final userCollection = await FirebaseFirestore.instance.collection('users').where('uid', isEqualTo: user.uid).get();
    final userDoc = userCollection.docs[0];

    userData = UserModel.fromDocumentSnapshot(userDoc);

    // --------------------------------------------------------------------------------------

    // Reference to Firestore collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Query to get users in the same company, ordered by totalPoints
    QuerySnapshot querySnapshot = await users
        .where('companyId', isEqualTo: userData!.companyId)
        .where('role', isNotEqualTo: 'admin')
        .orderBy('role')
        .orderBy('totalPoints', descending: true)
        .get();

    // Iterate through the query results to find the current user's rank
    int rank = 1;
    for (var doc in querySnapshot.docs) {
      if (doc['uid'] == user.uid) {
        break;
      }
      rank++;
    }

    userRank = rank;

    // --------------------------------------------------------------------------------------

    // Calculate the start of the current month
    DateTime startDateOfCurrentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

    // Query Firestore
    var querySnapshotAgain = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userUid', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDateOfCurrentMonth))
        .get();

    int thisMonthPointsAgain = 0;
    // Summing the 'amount' fields
    for (var doc in querySnapshotAgain.docs) {
      var data = doc.data();
      int value = data['value'];
      if (value > 0) {
        thisMonthPointsAgain += value;
      }
    }

    CollectionReference collection = FirebaseFirestore.instance.collection('companies');
    DocumentSnapshot documentSnapshot = await collection.doc(userData!.companyId).get();
    int pointsGoal = documentSnapshot.get('pointsGoal');

    thisMonthPercentage = ((thisMonthPointsAgain / pointsGoal) * 100).toInt();

    listViews = <Widget>[];
    addAllListData();
    setState(() {});
  }

  void getThisMonthPoints() async {

    // Calculate the start of the current month
    DateTime startOfCurrentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

    // Query Firestore
    var querySnapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('userUid', isEqualTo: user.uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfCurrentMonth))
        .get();

    // Summing the 'amount' fields
    for (var doc in querySnapshot.docs) {
      var data = doc.data();
      int value = data['value'];
      if (value > 0) {
        thisMonthPoints += value;
      }
    }

    thisMonthPoints += 1;

    listViews = <Widget>[];
    addAllListData();
    setState(() {});
  }

  void addAllListData() {

    const int count = 5;

    listViews.add(
      Padding(
        padding: const EdgeInsets.only(left: 24, bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Hi, ',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 32, 32, 32).withOpacity(0.7),
                    fontSize: 35,
                  )
                ),
                Text(
                  (userData != null) ? userData!.name : '',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 32, 32, 32).withOpacity(0.7),
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  )
                ),
                Text(
                  '.',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 32, 32, 32).withOpacity(0.7),
                    fontSize: 35,
                  )
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: (userData != null) ?
                Image.asset(
                  (userData!.companyId == '355aInOtLhMaQm6fyMCh') ? 'assets/images/singleton.png' : 'assets/images/technova.png',
                  width: 200,
                )
                : const SizedBox(),
            )
          ],
        ),
      ),
    );
    
    listViews.add(
      TitleView(
        titleTxt: 'Overview',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    listViews.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: OverviewCard(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
              parent: widget.animationController!,
              curve: const Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController!,
          thisMonthPoints: thisMonthPoints,
          userData: userData,
          userRank: userRank,
          thisMonthPercentage: thisMonthPercentage,
        ),
      ),
    );

    listViews.add(
      TitleView(
        titleTxt: 'Actions',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController!,
      ),
    );

    listViews.add(
      ActionCard(
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController!,
            curve: const Interval((1 / count) * 3, 1.0, curve: Curves.fastOutSlowIn))),
        mainScreenAnimationController: widget.animationController,
      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: HomeAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView.builder(
          padding: const EdgeInsets.only(top: 60),
          itemCount: listViews.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            widget.animationController?.forward();
            return listViews[index];
          },
        ) 
      ),
    );
  }

}
