import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/modules/environmental_impact/pages/impact_details_page.dart';
import 'package:flutter_app_base/modules/environmental_impact/pages/impact_milestones_page.dart';
import 'package:flutter_app_base/modules/environmental_impact/providers/env_impact_provider.dart';

class ImpactDashboardPage extends StatelessWidget {
  const ImpactDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EnvironmentalImpactProvider(
      builder: (data) {
        final impactData = data.impactData;
        final co2eSavedKg = impactData['co2eSavedKg'] as double;
        final totalPoints = impactData['totalPoints'] as int;
        final impactSummary = impactData['impactSummary'] as String;
        final equivalents = impactData['equivalents'] as Map<String, dynamic>;
        final percentOfAverageFootprint = impactData['percentOfAverageFootprint'] as double;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Your Environmental Impact'),
            backgroundColor: CustomTheme.primaryGreen,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, co2eSavedKg, totalPoints, impactSummary),
                _buildEquivalentsSection(context, equivalents),
                _buildFootprintComparison(context, percentOfAverageFootprint),
                _buildNavigationButtons(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, double co2eSavedKg, int totalPoints, String impactSummary) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomTheme.primaryGreen, CustomTheme.primaryGreenDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            'Your Lifetime Impact',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CustomTheme.white,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
              Column(
                children: [
                  Text(
                    '${co2eSavedKg.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: CustomTheme.white,
                    ),
                  ),
                  const Text(
                    'kg CO₂e saved',
                    style: TextStyle(
                      fontSize: 16,
                      color: CustomTheme.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$totalPoints eco points earned',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: CustomTheme.white,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CustomTheme.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              impactSummary,
              style: const TextStyle(
                fontSize: 16,
                color: CustomTheme.darkGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquivalentsSection(BuildContext context, Map<String, dynamic> equivalents) {
    // Select the top 3 most relatable equivalents
    final topEquivalents = [
      equivalents['kilometersNotDriven'],
      equivalents['treesPlantedYearEquivalent'],
      equivalents['smartphoneCharges'],
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Impact Equivalents',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CustomTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 16),
          ...topEquivalents.map((equivalent) => _buildEquivalentCard(equivalent)),
        ],
      ),
    );
  }

  Widget _buildEquivalentCard(Map<String, dynamic> equivalent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: CustomTheme.lightGreenAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                equivalent['icon'] as String,
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equivalent['value'] as String,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CustomTheme.darkGrey,
                  ),
                ),
                Text(
                  equivalent['description'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CustomTheme.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFootprintComparison(BuildContext context, double percentOfAverageFootprint) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.lightBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomTheme.lightBlueAccent),
      ),
      child: Column(
        children: [
          const Text(
            'Your annual impact is equivalent to',
            style: TextStyle(
              fontSize: 16,
              color: CustomTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${percentOfAverageFootprint.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: CustomTheme.mediumBlue,
            ),
          ),
          const Text(
            'of an average person\'s carbon footprint',
            style: TextStyle(
              fontSize: 16,
              color: CustomTheme.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ImpactDetailsPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomTheme.primaryGreen,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'View Detailed Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ImpactMilestonesPage(),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: CustomTheme.primaryGreen),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'See Your Milestones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CustomTheme.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 