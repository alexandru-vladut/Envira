import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/utils/calculators/env_impact_calculator.dart';
import 'package:flutter_app_base/data/models/user_model.dart';
import 'package:flutter_app_base/data/providers/users_provider.dart';
import 'package:flutter_app_base/session/auth_state_provider.dart';
import 'package:provider/provider.dart';

class EnvironmentalImpactProvider extends StatelessWidget {
  final Widget Function(EnvironmentalImpactData data) builder;

  const EnvironmentalImpactProvider({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    // Get current user UID
    final currentUserUid = context.select<AuthStateProvider, String?>((auth) => auth.uid);
    
    // Get current user data
    final currentUser = context.select<UsersProvider, UserModel?>(
      (provider) => provider.items.firstWhereOrNull((u) => u.uid == currentUserUid),
    );

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Convert createdAt from Timestamp to DateTime if needed
    final DateTime userCreatedAt = _getCreatedAtDateTime(currentUser.createdAt);

    final impactData = EnvironmentalImpactCalculator.calculateImpactAwareness(
      totalPoints: currentUser.totalPoints,
      timeSpanDescription: "all time",
      daysInTimeSpan: DateTime.now().difference(userCreatedAt).inDays
    );

    final environmentalImpactData = EnvironmentalImpactData(
      impactData: impactData,
    );

    return builder(environmentalImpactData);
  }

  DateTime _getCreatedAtDateTime(dynamic createdAt) {
    if (createdAt is DateTime) {
      return createdAt;
    } else if (createdAt is Timestamp) {
      return createdAt.toDate();
    } else {
      // Fallback to current date if createdAt is invalid
      return DateTime.now();
    }
  }
}

class EnvironmentalImpactData {
  final Map<String, dynamic> impactData;

  const EnvironmentalImpactData({
    required this.impactData,
  });
}
