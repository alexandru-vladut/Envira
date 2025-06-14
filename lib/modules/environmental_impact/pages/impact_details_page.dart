import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/modules/environmental_impact/providers/env_impact_provider.dart';

class ImpactDetailsPage extends StatelessWidget {
  const ImpactDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EnvironmentalImpactProvider(
      builder: (data) {
        final impactData = data.impactData;
        final equivalents = impactData['equivalents'] as Map<String, dynamic>;
        final contextualComparisons = impactData['contextualComparisons'] as Map<String, dynamic>;
        final timeSpan = impactData['timeSpan'] as String;
        final co2eSavedKg = impactData['co2eSavedKg'] as double;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Impact Details'),
            backgroundColor: CustomTheme.primaryGreen,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildTimeSpanHeader(context, timeSpan, co2eSavedKg),
                _buildAllEquivalents(context, equivalents),
                _buildContextualComparisons(context, contextualComparisons),
                _buildScientificBasis(context, impactData['scientificBasis'] as String),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSpanHeader(BuildContext context, String timeSpan, double co2eSavedKg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomTheme.primaryGreen, CustomTheme.primaryGreenDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Your Lifetime Impact',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CustomTheme.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${co2eSavedKg.toStringAsFixed(1)} kg CO₂e',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: CustomTheme.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'saved',
                style: TextStyle(
                  fontSize: 18,
                  color: CustomTheme.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllEquivalents(BuildContext context, Map<String, dynamic> equivalents) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Environmental Equivalents',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CustomTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your impact expressed in everyday terms',
            style: TextStyle(
              fontSize: 14,
              color: CustomTheme.grey600,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: equivalents.length,
            itemBuilder: (context, index) {
              final equivalent = equivalents.values.elementAt(index);
              return _buildEquivalentGridItem(equivalent);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEquivalentGridItem(Map<String, dynamic> equivalent) {
    return Container(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            equivalent['icon'] as String,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 12),
          Text(
            equivalent['value'] as String,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CustomTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            equivalent['description'] as String,
            style: const TextStyle(
              fontSize: 12,
              color: CustomTheme.grey600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContextualComparisons(BuildContext context, Map<String, dynamic> comparisons) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CustomTheme.lightBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How You Compare',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CustomTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildComparisonItem(
                  'Average Person',
                  '${comparisons['averagePersonDailyFootprint']} kg',
                  'daily CO₂e',
                ),
              ),
              Container(
                height: 60,
                width: 1,
                color: CustomTheme.lightBlueAccent,
              ),
              Expanded(
                child: _buildComparisonItem(
                  'Your Daily Savings',
                  '${comparisons['yourDailySavingsRate']} kg',
                  'CO₂e saved/day',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'That\'s ${comparisons['percentOfDailyFootprint']}% of an average person\'s daily carbon footprint!',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: CustomTheme.mediumBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CustomTheme.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              comparisons['contextMessage'] as String,
              style: const TextStyle(
                fontSize: 14,
                color: CustomTheme.darkGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(String title, String value, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: CustomTheme.grey600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CustomTheme.darkGrey,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: CustomTheme.grey600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScientificBasis(BuildContext context, String scientificBasis) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomTheme.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.science_outlined,
                color: CustomTheme.primaryGreen,
              ),
              const SizedBox(width: 8),
              const Text(
                'Scientific Basis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CustomTheme.darkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            scientificBasis,
            style: const TextStyle(
              fontSize: 14,
              color: CustomTheme.grey600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Our calculations are based on peer-reviewed research and industry standards for carbon accounting.',
            style: TextStyle(
              fontSize: 14,
              color: CustomTheme.grey600,
            ),
          ),
        ],
      ),
    );
  }
} 