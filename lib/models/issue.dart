import 'package:json_annotation/json_annotation.dart';

part 'issue.g.dart';

@JsonSerializable()
class Issue {
  final String id;
  final String source; // 'twitter', 'koo', 'facebook'
  final String text;
  final String? imageUrl;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? authorName;
  final String? authorHandle;
  final String? sourceUrl;
  final int? engagementCount;

  Issue({
    required this.id,
    required this.source,
    required this.text,
    this.imageUrl,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.address,
    this.authorName,
    this.authorHandle,
    this.sourceUrl,
    this.engagementCount,
  });

  factory Issue.fromJson(Map<String, dynamic> json) => _$IssueFromJson(json);
  Map<String, dynamic> toJson() => _$IssueToJson(this);

  bool get hasLocation => latitude != null && longitude != null;
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Color get sourceColor {
    switch (source.toLowerCase()) {
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'koo':
        return const Color(0xFFFFD700);
      case 'facebook':
        return const Color(0xFF1877F2);
      default:
        return const Color(0xFF666666);
    }
  }

  String get sourceName {
    switch (source.toLowerCase()) {
      case 'twitter':
        return 'Twitter';
      case 'koo':
        return 'Koo';
      case 'facebook':
        return 'Facebook';
      default:
        return source;
    }
  }
}
