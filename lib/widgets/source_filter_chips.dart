import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';

class SourceFilterChips extends StatelessWidget {
  final String selectedSource;
  final Function(String) onSourceChanged;

  const SourceFilterChips({
    super.key,
    required this.selectedSource,
    required this.onSourceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        final twitterCount = dataService.getIssuesBySource('twitter').length;
        final kooCount = dataService.getIssuesBySource('koo').length;
        final facebookCount = dataService.getIssuesBySource('facebook').length;
        final totalCount = dataService.issues.length;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                'All Sources',
                'all',
                totalCount,
                Colors.grey[700]!,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Twitter',
                'twitter',
                twitterCount,
                const Color(0xFF1DA1F2),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Koo',
                'koo',
                kooCount,
                const Color(0xFFFFD700),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Facebook',
                'facebook',
                facebookCount,
                const Color(0xFF1877F2),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value, int count, Color color) {
    final isSelected = selectedSource == value;
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(label),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.white,
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onSourceChanged(value);
        }
      },
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      backgroundColor: Colors.white,
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }
}
