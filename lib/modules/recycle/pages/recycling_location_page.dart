import 'package:flutter/material.dart';
import 'package:flutter_app_base/core/utils/app_navigator.dart';
import 'package:flutter_app_base/data/models/recycling_point.dart';
import 'package:flutter_app_base/modules/recycle/pages/recycling_location_list_page.dart';
import 'package:flutter_app_base/modules/recycle/services/recycling_points_service.dart';

class RecyclingLocationPage extends StatefulWidget {
  const RecyclingLocationPage({super.key});

  @override
  State<RecyclingLocationPage> createState() => _RecyclingLocationPageState();
}

class _RecyclingLocationPageState extends State<RecyclingLocationPage> {
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
    bool clearCache = false
  }) async {

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (clearCache) {
        RecyclingPointsService.clearCache();
      }

      final position = await RecyclingPointsService.getCurrentLocation(requestPermission: requestPermission);

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
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Recycling Locations',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
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
    );
  }

  Widget _buildBody() {
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

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF3881E0)),
          SizedBox(height: 16),
          Text(
            'Finding recycling locations...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
            const SizedBox(height: 24),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _checkLocationAndLoadPoints(requestPermission: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3881E0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
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
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Location Permission Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We need your location to find nearby recycling points. Please allow location access.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _checkLocationAndLoadPoints(requestPermission: true),
              icon: const Icon(Icons.location_on),
              label: const Text('Check for nearby locations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3881E0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
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
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_searching, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'No recycling locations found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'No recycling points found within 1km of your location. Try refreshing or move to a different area.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _checkLocationAndLoadPoints(requestPermission: true, clearCache: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3881E0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with refresh button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Closest Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              IconButton(
                onPressed: () => _checkLocationAndLoadPoints(requestPermission: true, clearCache: true),
                icon: const Icon(Icons.refresh),
                color: const Color(0xFF3881E0),
                tooltip: 'Refresh locations',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Closest point card
          _buildPointCard(closestPoint),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => RecyclingPointsService.openInMaps(context, closestPoint),
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3881E0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (otherPoints.isNotEmpty) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => AppNavigator.navigateTo(page: RecyclingLocationListPage(allPoints: nearbyPoints!)),
                    icon: const Icon(Icons.list),
                    label: Text('See more (${otherPoints.length})'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3881E0),
                      side: const BorderSide(color: Color(0xFF3881E0)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Total count info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Found ${nearbyPoints!.length} recycling location${nearbyPoints!.length == 1 ? '' : 's'} within 1km',
                    style: TextStyle(color: Colors.blue[700], fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointCard(RecyclingPointModel point) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
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
                    Text(
                      point.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (point.subheading.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        point.subheading,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3881E0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  point.formattedDistance,
                  style: const TextStyle(
                    color: Color(0xFF3881E0),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  point.address.isNotEmpty
                      ? point.address
                      : 'Address not available',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),

          if (point.offersMoney) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.green[600]),
                const SizedBox(width: 4),
                Text(
                  'Offers money for materials',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[600],
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
