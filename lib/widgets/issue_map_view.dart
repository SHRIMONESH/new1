import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/data_service.dart';
import '../services/location_service.dart';
import '../models/issue.dart';

class IssueMapView extends StatefulWidget {
  final String selectedSource;

  const IssueMapView({
    super.key,
    required this.selectedSource,
  });

  @override
  State<IssueMapView> createState() => _IssueMapViewState();
}

class _IssueMapViewState extends State<IssueMapView> {
  final MapController _mapController = MapController();
  Issue? _selectedIssue;

  @override
  Widget build(BuildContext context) {
    return Consumer2<DataService, LocationService>(
      builder: (context, dataService, locationService, child) {
        if (dataService.isLoading && dataService.issues.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading map data...'),
              ],
            ),
          );
        }

        List<Issue> issues = widget.selectedSource == 'all'
            ? dataService.getIssuesWithLocation()
            : dataService.getIssuesBySource(widget.selectedSource)
                .where((issue) => issue.hasLocation)
                .toList();

        if (issues.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No location data available',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Issues without location information cannot be displayed on the map',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // Default center (Mumbai)
        LatLng center = const LatLng(19.0760, 72.8777);
        
        // Use user's current location if available
        if (locationService.currentPosition != null) {
          center = LatLng(
            locationService.currentPosition!.latitude,
            locationService.currentPosition!.longitude,
          );
        } else if (issues.isNotEmpty) {
          // Center on first issue
          center = LatLng(issues.first.latitude!, issues.first.longitude!);
        }

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 12.0,
                minZoom: 5.0,
                maxZoom: 18.0,
                onTap: (_, __) {
                  setState(() {
                    _selectedIssue = null;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.explore_page_app',
                ),
                MarkerLayer(
                  markers: [
                    // User location marker
                    if (locationService.currentPosition != null)
                      Marker(
                        point: LatLng(
                          locationService.currentPosition!.latitude,
                          locationService.currentPosition!.longitude,
                        ),
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    
                    // Issue markers
                    ...issues.map((issue) => Marker(
                      point: LatLng(issue.latitude!, issue.longitude!),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIssue = issue;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: issue.sourceColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedIssue?.id == issue.id
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getIconForIssue(issue.text),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ],
            ),
            
            // Selected issue card
            if (_selectedIssue != null)
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: _buildIssueCard(_selectedIssue!),
              ),
            
            // Map controls
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton(
                    mini: true,
                    heroTag: "zoom_in",
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    mini: true,
                    heroTag: "zoom_out",
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    },
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    mini: true,
                    heroTag: "my_location",
                    onPressed: () {
                      if (locationService.currentPosition != null) {
                        _mapController.move(
                          LatLng(
                            locationService.currentPosition!.latitude,
                            locationService.currentPosition!.longitude,
                          ),
                          15.0,
                        );
                      } else {
                        locationService.getCurrentLocation();
                      }
                    },
                    child: locationService.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
            
            // Legend
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Legend',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildLegendItem(Colors.blue, 'Your Location', Icons.person),
                    _buildLegendItem(const Color(0xFF1DA1F2), 'Twitter', Icons.report_problem),
                    _buildLegendItem(const Color(0xFFFFD700), 'Koo', Icons.report_problem),
                    _buildLegendItem(const Color(0xFF1877F2), 'Facebook', Icons.report_problem),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 10,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  IconData _getIconForIssue(String text) {
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains('pothole') || lowerText.contains('road')) {
      return Icons.construction;
    } else if (lowerText.contains('traffic') || lowerText.contains('signal')) {
      return Icons.traffic;
    } else if (lowerText.contains('water') || lowerText.contains('supply')) {
      return Icons.water_drop;
    } else if (lowerText.contains('garbage') || lowerText.contains('waste')) {
      return Icons.delete;
    } else if (lowerText.contains('light') || lowerText.contains('electricity')) {
      return Icons.lightbulb;
    } else if (lowerText.contains('drainage') || lowerText.contains('sewage')) {
      return Icons.water_damage;
    } else {
      return Icons.report_problem;
    }
  }

  Widget _buildIssueCard(Issue issue) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: issue.sourceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    issue.sourceName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  issue.timeAgo,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIssue = null;
                    });
                  },
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              issue.text,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (issue.address != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      issue.address!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
