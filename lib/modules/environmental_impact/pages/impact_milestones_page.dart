import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/modules/environmental_impact/providers/env_impact_provider.dart';

class ImpactMilestonesPage extends StatelessWidget {
  const ImpactMilestonesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EnvironmentalImpactProvider(
      builder: (data) {
        final impactData = data.impactData;
        final projections = impactData['projections'] as Map<String, dynamic>;
        final milestones = projections['milestones'] as List<dynamic>;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Your Eco Milestones'),
            backgroundColor: CustomTheme.primaryGreen,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildProjectionsHeader(context, projections),
                _buildMilestones(context, milestones),
                _buildMotivationalSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectionsHeader(BuildContext context, Map<String, dynamic> projections) {
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
            'Your Impact Projections',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CustomTheme.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildProjectionCard(
                  'Weekly',
                  '${projections['weeklyProjection']} kg',
                  'CO₂e saved',
                ),
              ),
              Expanded(
                child: _buildProjectionCard(
                  'Monthly',
                  '${projections['monthlyProjection']} kg',
                  'CO₂e saved',
                ),
              ),
              Expanded(
                child: _buildProjectionCard(
                  'Yearly',
                  '${projections['yearlyProjection']} kg',
                  'CO₂e saved',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Based on your current activity level',
              style: TextStyle(
                fontSize: 14,
                color: CustomTheme.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionCard(String title, String value, String subtitle) {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.15),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: CustomTheme.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CustomTheme.white,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: CustomTheme.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestones(BuildContext context, List<dynamic> milestones) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Eco Milestones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CustomTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track your progress towards environmental achievements',
            style: TextStyle(
              fontSize: 14,
              color: CustomTheme.grey600,
            ),
          ),
          const SizedBox(height: 24),
          ...milestones.map((milestone) => _buildMilestoneCard(milestone as Map<String, dynamic>)),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(Map<String, dynamic> milestone) {
    final bool achieved = milestone['achieved'] as bool;
    final int progress = milestone['progress'] as int;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
        border: achieved 
            ? Border.all(color: CustomTheme.successGreen, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: achieved 
                      ? CustomTheme.lightGreenAccent
                      : CustomTheme.lightGrey,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achieved ? Icons.check : Icons.hourglass_bottom,
                  color: achieved 
                      ? CustomTheme.successGreenDark
                      : CustomTheme.grey600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone['title'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: achieved 
                            ? CustomTheme.successGreenDark
                            : CustomTheme.darkGrey,
                      ),
                    ),
                    Text(
                      milestone['description'] as String,
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
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress: $progress%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: CustomTheme.darkGrey,
                    ),
                  ),
                  Text(
                    '${milestone['threshold']} kg CO₂e',
                    style: const TextStyle(
                      fontSize: 14,
                      color: CustomTheme.grey600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: CustomTheme.grey200,
                  color: achieved 
                      ? CustomTheme.successGreen
                      : CustomTheme.primaryGreen,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CustomTheme.lightBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            '💡 Did You Know?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CustomTheme.darkGrey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Small actions add up! If everyone reduced their carbon footprint by just 5%, we could prevent millions of tons of CO₂e emissions annually.',
            style: TextStyle(
              fontSize: 14,
              color: CustomTheme.darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate back to dashboard
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomTheme.primaryGreen,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continue Your Eco Journey',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
} 