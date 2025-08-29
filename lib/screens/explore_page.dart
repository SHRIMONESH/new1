import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../services/location_service.dart';
import '../widgets/issue_list_view.dart';
import '../widgets/issue_map_view.dart';
import '../widgets/source_filter_chips.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedSource = 'all';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Get current location on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationService>().getCurrentLocation();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Explore Issues',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<DataService>(
            builder: (context, dataService, child) {
              return IconButton(
                icon: dataService.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                onPressed: dataService.isLoading
                    ? null
                    : () => dataService.refreshData(),
                tooltip: 'Refresh Data',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(
              icon: Icon(Icons.list),
              text: 'List View',
            ),
            Tab(
              icon: Icon(Icons.map),
              text: 'Map View',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Status Bar
          Consumer<DataService>(
            builder: (context, dataService, child) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: dataService.isLoading ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dataService.isLoading
                          ? 'Fetching latest issues...'
                          : dataService.lastRefresh != null
                              ? 'Last updated: ${_formatTime(dataService.lastRefresh!)}'
                              : 'Ready',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${dataService.issues.length} issues',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Source Filter
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SourceFilterChips(
              selectedSource: _selectedSource,
              onSourceChanged: (source) {
                setState(() {
                  _selectedSource = source;
                });
              },
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                IssueListView(selectedSource: _selectedSource),
                IssueMapView(selectedSource: _selectedSource),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
