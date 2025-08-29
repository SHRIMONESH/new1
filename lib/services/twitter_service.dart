import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/issue.dart';

class TwitterService {
  static const String _baseUrl = 'https://api.twitter.com/2';
  static const String _bearerToken = 'AAAAAAAAAAAAAAAAAAAAALIb3AEAAAAA62UMhPGkQjWXXTrF9gl%2BOTE5oCo%3DhcU2mtdmKyyiaoew9Q3ZTTPzSGhgFwA49rTfpBnE0pIxG2vARW';
  
  Future<List<Issue>> fetchRecentIssues() async {
    try {
      // Search for tweets about civic issues, problems, complaints
      final query = '(problem OR issue OR complaint OR broken OR damaged OR "not working" OR pothole OR garbage OR "street light" OR "water supply" OR traffic) -is:retweet lang:en';
      
      final uri = Uri.parse('$_baseUrl/tweets/search/recent').replace(
        queryParameters: {
          'query': query,
          'max_results': '50',
          'tweet.fields': 'created_at,public_metrics,geo,attachments,author_id',
          'expansions': 'author_id,attachments.media_keys,geo.place_id',
          'user.fields': 'name,username,profile_image_url',
          'media.fields': 'url,preview_image_url',
          'place.fields': 'full_name,geo,country,place_type',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseTwitterResponse(data);
      } else {
        print('Twitter API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Twitter Service Error: $e');
      return [];
    }
  }

  List<Issue> _parseTwitterResponse(Map<String, dynamic> data) {
    final List<Issue> issues = [];
    
    if (data['data'] == null) return issues;
    
    final tweets = data['data'] as List;
    final includes = data['includes'] as Map<String, dynamic>?;
    final users = includes?['users'] as List?;
    final media = includes?['media'] as List?;
    final places = includes?['places'] as List?;

    for (final tweet in tweets) {
      try {
        // Find author info
        final authorId = tweet['author_id'];
        final author = users?.firstWhere(
          (user) => user['id'] == authorId,
          orElse: () => null,
        );

        // Find media
        String? imageUrl;
        if (tweet['attachments']?['media_keys'] != null) {
          final mediaKeys = tweet['attachments']['media_keys'] as List;
          if (mediaKeys.isNotEmpty && media != null) {
            final mediaItem = media.firstWhere(
              (m) => mediaKeys.contains(m['media_key']),
              orElse: () => null,
            );
            imageUrl = mediaItem?['url'] ?? mediaItem?['preview_image_url'];
          }
        }

        // Find location
        double? latitude, longitude;
        String? address;
        if (tweet['geo']?['place_id'] != null && places != null) {
          final placeId = tweet['geo']['place_id'];
          final place = places.firstWhere(
            (p) => p['id'] == placeId,
            orElse: () => null,
          );
          if (place != null) {
            address = place['full_name'];
            if (place['geo']?['bbox'] != null) {
              final bbox = place['geo']['bbox'] as List;
              longitude = (bbox[0] + bbox[2]) / 2;
              latitude = (bbox[1] + bbox[3]) / 2;
            }
          }
        }

        final issue = Issue(
          id: 'twitter_${tweet['id']}',
          source: 'twitter',
          text: tweet['text'],
          imageUrl: imageUrl,
          timestamp: DateTime.parse(tweet['created_at']),
          latitude: latitude,
          longitude: longitude,
          address: address,
          authorName: author?['name'],
          authorHandle: '@${author?['username'] ?? 'unknown'}',
          sourceUrl: 'https://twitter.com/i/status/${tweet['id']}',
          engagementCount: (tweet['public_metrics']?['like_count'] ?? 0) +
                          (tweet['public_metrics']?['retweet_count'] ?? 0),
        );

        issues.add(issue);
      } catch (e) {
        print('Error parsing tweet: $e');
        continue;
      }
    }

    return issues;
  }
}
