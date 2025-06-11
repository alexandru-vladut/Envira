import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/data/models/recycling_point.dart';
import 'package:flutter_app_base/modules/custom_app_bar.dart';
import 'package:flutter_app_base/modules/recycle/services/recycling_points_service.dart';
import 'package:flutter_app_base/modules/recycle/widgets/recycling_point_detail_modal.dart';

class RecyclingLocationListPage extends StatelessWidget {
  final List<RecyclingPointModel> allPoints;

  const RecyclingLocationListPage({
    super.key,
    required this.allPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.white,
      appBar: CustomAppBar(title: 'All Locations (${allPoints.length})'),
      body: _buildPointsList(),
    );
  }

  Widget _buildPointsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allPoints.length,
      itemBuilder: (context, index) {
        final point = allPoints[index];
        final isClosest = index == 0;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => RecyclingPointDetailModal.show(context, point),
            child: _buildPointListItem(context, point, isClosest),
          ),
        );
      },
    );
  }

  Widget _buildPointListItem(BuildContext context, RecyclingPointModel point, bool isClosest) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isClosest ? CustomTheme.primaryGreen.withOpacity(0.05) : CustomTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isClosest ? CustomTheme.primaryGreen : CustomTheme.grey200,
          width: isClosest ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CustomTheme.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isClosest) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: CustomTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'CLOSEST',
                              style: TextStyle(
                                color: CustomTheme.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            point.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CustomTheme.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (point.subheading.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        point.subheading,
                        style: TextStyle(
                          fontSize: 12,
                          color: CustomTheme.grey600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CustomTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  point.formattedDistance,
                  style: const TextStyle(
                    color: CustomTheme.successGreenDark,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: CustomTheme.grey600,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  point.address.isNotEmpty ? point.address : 'Address not available',
                  style: TextStyle(
                    fontSize: 12,
                    color: CustomTheme.grey600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              if (point.offersMoney) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: CustomTheme.lightGreenAccent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CustomTheme.lightGreenBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 12,
                        color: CustomTheme.successGreenDark,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Offers money',
                        style: TextStyle(
                          fontSize: 10,
                          color: CustomTheme.successGreenDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ] else
                const Spacer(),
              
              TextButton.icon(
                onPressed: () => RecyclingPointsService.openInMaps(context, point),
                icon: const Icon(
                  Icons.directions,
                  size: 16,
                ),
                label: const Text('Directions'),
                style: TextButton.styleFrom(
                  foregroundColor: CustomTheme.white,
                  backgroundColor: CustomTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
