import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/data/models/recycling_point.dart';
import 'package:flutter_app_base/modules/recycle/services/recycling_points_service.dart';

class RecyclingPointDetailModal extends StatelessWidget {
  final RecyclingPointModel point;

  const RecyclingPointDetailModal({
    super.key,
    required this.point,
  });

  static void show(BuildContext context, RecyclingPointModel point) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CustomTheme.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return RecyclingPointDetailModal(point: point);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CustomTheme.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationInfo(),
                  const SizedBox(height: 20),
                  _buildMaterialsList(),
                  const SizedBox(height: 20),
                  _buildAdditionalInfo(),
                  const SizedBox(height: 24),
                  _buildActionButton(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: CustomTheme.primaryGreen,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: CustomTheme.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CustomTheme.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.recycling,
                  color: CustomTheme.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: CustomTheme.white,
                      ),
                    ),
                    if (point.subheading.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        point.subheading,
                        style: TextStyle(
                          fontSize: 14,
                          color: CustomTheme.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: CustomTheme.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              point.formattedDistance,
              style: const TextStyle(
                color: CustomTheme.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CustomTheme.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on,
                size: 18,
                color: CustomTheme.primaryGreen,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  point.address.isNotEmpty
                      ? point.address
                      : 'Address not available',
                  style: const TextStyle(
                    fontSize: 15,
                    color: CustomTheme.grey800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList() {
    if (point.materials.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accepted Materials',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CustomTheme.black87,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: point.materials.length,
            itemBuilder: (context, index) {
              final material = point.materials[index];
              IconData icon = _getMaterialIcon(material);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: CustomTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        size: 18,
                        color: CustomTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        material,
                        style: const TextStyle(
                          fontSize: 15,
                          color: CustomTheme.grey800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getMaterialIcon(String material) {
    if (material.toLowerCase().contains('plastic')) {
      return Icons.local_drink_outlined;
    } else if (material.toLowerCase().contains('hârtie') || 
               material.toLowerCase().contains('carton')) {
      return Icons.article_outlined;
    } else if (material.toLowerCase().contains('metal') || 
               material.toLowerCase().contains('aluminiu')) {
      return Icons.inventory_2_outlined;
    } else if (material.toLowerCase().contains('sticlă')) {
      return Icons.wine_bar_outlined;
    } else if (material.toLowerCase().contains('textile')) {
      return Icons.checkroom_outlined;
    } else if (material.toLowerCase().contains('echipamente') || 
               material.toLowerCase().contains('deee')) {
      return Icons.devices_outlined;
    } else if (material.toLowerCase().contains('uleiuri') || 
               material.toLowerCase().contains('grăsimi')) {
      return Icons.water_drop_outlined;
    }
    return Icons.recycling;
  }

  Widget _buildAdditionalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMoneyOfferingSection(),
        const SizedBox(height: 20),
        
        // Add an info box with icon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CustomTheme.lightBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: CustomTheme.mediumBlue,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Always check with the location for current operating hours and any specific requirements for recycling.',
                  style: TextStyle(
                    fontSize: 14,
                    color: CustomTheme.mediumBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildMoneyOfferingSection() {
    if (point.offersMoney) {
      // Money is offered - positive visualization
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CustomTheme.lightGreenAccent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CustomTheme.lightGreenBorder),
          boxShadow: [
            BoxShadow(
              color: CustomTheme.successGreenDark.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CustomTheme.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: CustomTheme.successGreenDark.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.attach_money,
                size: 20,
                color: CustomTheme.successGreenDark,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Money for Materials',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: CustomTheme.successGreenDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'This location offers monetary compensation for your recycled materials',
                    style: TextStyle(
                      fontSize: 14,
                      color: CustomTheme.successGreenDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // No money offered - neutral visualization
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CustomTheme.grey100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CustomTheme.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No Monetary Compensation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CustomTheme.grey800,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CustomTheme.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: CustomTheme.grey200, width: 1),
                  ),
                  child: const Icon(
                    Icons.money_off,
                    size: 20,
                    color: CustomTheme.grey600,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This location doesn\'t offer money for recycled materials, but you\'ll still earn points in the app.',
                        style: TextStyle(
                          fontSize: 14,
                          color: CustomTheme.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => RecyclingPointsService.openInMaps(context, point),
        icon: const Icon(Icons.directions),
        label: const Text('Get Directions'),
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomTheme.primaryGreen,
          foregroundColor: CustomTheme.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
} 