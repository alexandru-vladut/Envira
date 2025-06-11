import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/global_instances.dart';
import 'package:flutter_app_base/core/theme/theme.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';
import 'package:flutter_app_base/data/models/recycling_point.dart';
import 'package:flutter_app_base/modules/recycle/pages/recycling_location_list_page.dart';
import 'package:flutter_app_base/modules/recycle/services/recycling_points_service.dart';

class RecyclePage extends StatefulWidget {
  const RecyclePage({super.key});

  @override
  State<RecyclePage> createState() => _RecyclePageState();
}

class _RecyclePageState extends State<RecyclePage> {
  List<RecyclingPointModel>? nearbyPoints;
  bool isLoading = false;
  bool hasLocationPermission = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLocationAndLoadPoints(requestPermission: false);
  }

  Future<void> _checkLocationAndLoadPoints({
    required bool requestPermission,
    bool clearCache = false,
  }) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (clearCache) {
        RecyclingPointsService.clearCache();
      }

      final position = await RecyclingPointsService.getCurrentLocation(
        requestPermission: requestPermission,
      );

      if (position == null) {
        setState(() {
          hasLocationPermission = false;
          isLoading = false;
        });
        return;
      }

      setState(() {
        hasLocationPermission = true;
      });

      final points = await RecyclingPointsService.getNearbyPoints(
        userLat: position.latitude,
        userLng: position.longitude,
        radiusKm: 1.0,
      );

      setState(() {
        nearbyPoints = points;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load recycling points: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // First section - Recycling locations (scrollable)
          Expanded(
            child: SingleChildScrollView(
              child: _buildRecyclingLocationsSection(),
            ),
          ),

          // Second section - Barcode scanner (fixed)
          _buildBarcodeScannerSection(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: CustomTheme.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Recycling Locations',
        style: TextStyle(
          color: CustomTheme.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: GestureDetector(
        onTap: () => AppNavigator.pop(context: context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CustomTheme.grey200,
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: CustomTheme.black87,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildRecyclingLocationsSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title with icon
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: CustomTheme.primaryGreen,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Find recycling points near you',
                style: TextStyle(
                  fontSize: 15,
                  color: CustomTheme.grey600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Location content
          _buildLocationContent(),
        ],
      ),
    );
  }

  Widget _buildLocationContent() {
    if (isLoading) {
      return _buildLoadingView();
    }

    if (errorMessage != null) {
      return _buildErrorView();
    }

    if (!hasLocationPermission) {
      return _buildNoLocationPermissionView();
    }

    if (nearbyPoints == null || nearbyPoints!.isEmpty) {
      return _buildNoPointsView();
    }

    return _buildPointsView();
  }

  Widget _buildBarcodeScannerSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: CustomTheme.primaryGreen,
        boxShadow: [
          BoxShadow(
            color: CustomTheme.grey600.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CustomTheme.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: CustomTheme.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan Product Barcode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CustomTheme.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Scan products to recycle and earn points',
                      style: TextStyle(
                        fontSize: 14,
                        color: CustomTheme.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await recycleService.scanBarcode(context);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Barcode'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.white,
                foregroundColor: CustomTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: CustomTheme.primaryGreen),
          SizedBox(height: 16),
          Text(
            'Finding recycling locations...',
            style: TextStyle(fontSize: 16, color: CustomTheme.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 70, color: CustomTheme.errorRed),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CustomTheme.errorRedDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              style: TextStyle(fontSize: 14, color: CustomTheme.grey600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed:
                  () => _checkLocationAndLoadPoints(requestPermission: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primaryGreen,
                foregroundColor: CustomTheme.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoLocationPermissionView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 70, color: CustomTheme.grey400),
            const SizedBox(height: 16),
            const Text(
              'Location Permission Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CustomTheme.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'We need your location to find nearby recycling points.',
                style: TextStyle(fontSize: 14, color: CustomTheme.grey600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed:
                  () => _checkLocationAndLoadPoints(requestPermission: true),
              icon: const Icon(Icons.location_on),
              label: const Text('Enable location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primaryGreen,
                foregroundColor: CustomTheme.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPointsView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_searching,
              size: 70,
              color: CustomTheme.grey400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No recycling locations found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CustomTheme.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'No recycling points found within 1km of your location.',
                style: TextStyle(fontSize: 14, color: CustomTheme.grey600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed:
                  () => _checkLocationAndLoadPoints(
                    requestPermission: true,
                    clearCache: true,
                  ),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primaryGreen,
                foregroundColor: CustomTheme.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsView() {
    final closestPoint = nearbyPoints!.first;
    final otherPoints =
        nearbyPoints!.length > 1
            ? nearbyPoints!.skip(1).toList()
            : <RecyclingPointModel>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with refresh button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: CustomTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.near_me,
                    color: CustomTheme.primaryGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Closest Location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: CustomTheme.grey800,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed:
                  () => _checkLocationAndLoadPoints(
                    requestPermission: true,
                    clearCache: true,
                  ),
              icon: const Icon(Icons.refresh),
              color: CustomTheme.primaryGreen,
              tooltip: 'Refresh locations',
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Closest point card with enhanced styling
        _buildPointCard(closestPoint),

        const SizedBox(height: 20),

        // Action buttons with improved styling
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    () => RecyclingPointsService.openInMaps(
                      context,
                      closestPoint,
                    ),
                icon: const Icon(Icons.directions),
                label: const Text('Get Directions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primaryGreen,
                  foregroundColor: CustomTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            if (otherPoints.isNotEmpty) ...[
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      () => AppNavigator.navigateTo(
                        page: RecyclingLocationListPage(
                          allPoints: nearbyPoints!,
                        ),
                      ),
                  icon: const Icon(Icons.list),
                  label: Text('See all (${nearbyPoints!.length})'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CustomTheme.primaryGreen,
                    side: const BorderSide(color: CustomTheme.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 20),

        // Total count info with improved styling
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: CustomTheme.lightBlue,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: CustomTheme.lightBlueAccent),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: CustomTheme.mediumBlue, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Found ${nearbyPoints!.length} recycling location${nearbyPoints!.length == 1 ? '' : 's'} nearby.',
                  style: TextStyle(color: CustomTheme.mediumBlue, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPointCard(RecyclingPointModel point) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: CustomTheme.grey600.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: CustomTheme.grey100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CustomTheme.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.recycling,
                  color: CustomTheme.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      point.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CustomTheme.black87,
                      ),
                    ),
                    if (point.subheading.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        point.subheading,
                        style: TextStyle(
                          fontSize: 13,
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
                    color: CustomTheme.primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: CustomTheme.lightGrey),
          const SizedBox(height: 16),

          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: CustomTheme.grey600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  point.address.isNotEmpty
                      ? point.address
                      : 'Address not available',
                  style: TextStyle(fontSize: 13, color: CustomTheme.grey600),
                ),
              ),
            ],
          ),

          if (point.offersMoney) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: CustomTheme.successGreenDark,
                ),
                const SizedBox(width: 8),
                Text(
                  'Offers money for materials',
                  style: TextStyle(
                    fontSize: 13,
                    color: CustomTheme.successGreenDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
