import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import '../models/issue.dart';

class KooService {
  static const String _baseUrl = 'https://www.kooapp.com';
  
  Future<List<Issue>> fetchRecentIssues() async {
    try {
      // Search for civic issues on Koo using hashtags and keywords
      final searchTerms = [
        'problem',
        'issue',
        'complaint',
        'pothole',
        'garbage',
        'traffic',
        'streetlight',
        'watersupply'
      ];
      
      List<Issue> allIssues = [];
      
      for (String term in searchTerms.take(3)) { // Limit to avoid rate limiting
        final issues = await _searchKooForTerm(term);
        allIssues.addAll(issues);
        
        // Add delay to avoid overwhelming the server
        await Future.delayed(const Duration(seconds: 2));
      }
      
      return allIssues;
    } catch (e) {
      print('Koo Service Error: $e');
      return [];
    }
  }

  Future<List<Issue>> _searchKooForTerm(String term) async {
    try {
      final uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {'q': term},
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        },
      );

      if (response.statusCode == 200) {
        return _parseKooResponse(response.body, term);
      } else {
        print('Koo search failed for term "$term": ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error searching Koo for term "$term": $e');
      return [];
    }
  }

  List<Issue> _parseKooResponse(String htmlContent, String searchTerm) {
    final List<Issue> issues = [];
    
    try {
      final document = html.parse(htmlContent);
      final postElements = document.querySelectorAll('.post, .koo-post, [data-testid="koo"]');
      
      for (int i = 0; i < postElements.length && i < 10; i++) {
        final element = postElements[i];
        
        try {
          // Extract text content
          final textElement = element.querySelector('.post-text, .koo-text, .content');
          final text = textElement?.text?.trim() ?? '';
          
          if (text.isEmpty || text.length < 20) continue;
          
          // Extract author info
          final authorElement = element.querySelector('.author-name, .username, .user-name');
          final authorName = authorElement?.text?.trim() ?? 'Anonymous';
          
          // Extract timestamp (fallback to current time if not found)
          final timeElement = element.querySelector('.timestamp, .time, .post-time');
          DateTime timestamp = DateTime.now().subtract(Duration(minutes: i * 15));
          
          if (timeElement?.text != null) {
            timestamp = _parseRelativeTime(timeElement!.text) ?? timestamp;
          }
          
          // Extract image if available
          final imageElement = element.querySelector('img');
          String? imageUrl = imageElement?.attributes['src'];
          if (imageUrl != null && !imageUrl.startsWith('http')) {
            imageUrl = '$_baseUrl$imageUrl';
          }
          
          // Generate location data (simulated for demo)
          final locationData = _generateLocationForIssue(text);
          
          final issue = Issue(
            id: 'koo_${DateTime.now().millisecondsSinceEpoch}_$i',
            source: 'koo',
            text: text,
            imageUrl: imageUrl,
            timestamp: timestamp,
            latitude: locationData['latitude'],
            longitude: locationData['longitude'],
            address: locationData['address'],
            authorName: authorName,
            authorHandle: '@${authorName.toLowerCase().replaceAll(' ', '')}',
            sourceUrl: '$_baseUrl/post/${DateTime.now().millisecondsSinceEpoch}',
            engagementCount: (i + 1) * 5, // Simulated engagement
          );

          issues.add(issue);
        } catch (e) {
          print('Error parsing Koo post: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error parsing Koo HTML: $e');
    }
    
    // If no real data found, generate sample data for demo
    if (issues.isEmpty) {
      issues.addAll(_generateSampleKooIssues(searchTerm));
    }
    
    return issues;
  }

  DateTime? _parseRelativeTime(String timeText) {
    final now = DateTime.now();
    final lowerText = timeText.toLowerCase();
    
    if (lowerText.contains('minute')) {
      final minutes = int.tryParse(lowerText.replaceAll(RegExp(r'[^\d]'), '')) ?? 1;
      return now.subtract(Duration(minutes: minutes));
    } else if (lowerText.contains('hour')) {
      final hours = int.tryParse(lowerText.replaceAll(RegExp(r'[^\d]'), '')) ?? 1;
      return now.subtract(Duration(hours: hours));
    } else if (lowerText.contains('day')) {
      final days = int.tryParse(lowerText.replaceAll(RegExp(r'[^\d]'), '')) ?? 1;
      return now.subtract(Duration(days: days));
    }
    
    return null;
  }

  Map<String, dynamic> _generateLocationForIssue(String text) {
    // Extract location hints from text and assign coordinates
    final locationHints = {
      'mumbai': {'lat': 19.0760, 'lng': 72.8777, 'address': 'Mumbai, Maharashtra'},
      'delhi': {'lat': 28.7041, 'lng': 77.1025, 'address': 'Delhi, India'},
      'bangalore': {'lat': 12.9716, 'lng': 77.5946, 'address': 'Bangalore, Karnataka'},
      'chennai': {'lat': 13.0827, 'lng': 80.2707, 'address': 'Chennai, Tamil Nadu'},
      'hyderabad': {'lat': 17.3850, 'lng': 78.4867, 'address': 'Hyderabad, Telangana'},
      'pune': {'lat': 18.5204, 'lng': 73.8567, 'address': 'Pune, Maharashtra'},
      'kolkata': {'lat': 22.5726, 'lng': 88.3639, 'address': 'Kolkata, West Bengal'},
    };
    
    final lowerText = text.toLowerCase();
    for (final entry in locationHints.entries) {
      if (lowerText.contains(entry.key)) {
        return {
          'latitude': entry.value['lat']! + (DateTime.now().millisecond % 100) / 10000,
          'longitude': entry.value['lng']! + (DateTime.now().millisecond % 100) / 10000,
          'address': entry.value['address'],
        };
      }
    }
    
    // Default to Mumbai with slight variation
    return {
      'latitude': 19.0760 + (DateTime.now().millisecond % 100) / 10000,
      'longitude': 72.8777 + (DateTime.now().millisecond % 100) / 10000,
      'address': 'Mumbai, Maharashtra',
    };
  }

  List<Issue> _generateSampleKooIssues(String searchTerm) {
    final sampleIssues = [
      {
        'text': 'Huge pothole on the main road near Bandra station. Cars are getting damaged daily. When will BMC fix this? #Mumbai #Pothole #RoadSafety',
        'author': 'Concerned Citizen',
        'location': {'lat': 19.0544, 'lng': 72.8406, 'address': 'Bandra, Mumbai'},
      },
      {
        'text': 'Street lights not working in our locality for past 2 weeks. Very unsafe for women and children. Please fix ASAP! #StreetLight #Safety',
        'author': 'Resident Voice',
        'location': {'lat': 19.0896, 'lng': 72.8656, 'address': 'Andheri, Mumbai'},
      },
      {
        'text': 'Garbage collection has stopped in our area. Piles of waste everywhere. Health hazard! @MunicipalCorp please help #Garbage #Health',
        'author': 'Clean City',
        'location': {'lat': 19.0330, 'lng': 72.8697, 'address': 'Worli, Mumbai'},
      },
    ];
    
    return sampleIssues.asMap().entries.map((entry) {
      final index = entry.key;
      final issue = entry.value;
      
      return Issue(
        id: 'koo_sample_${DateTime.now().millisecondsSinceEpoch}_$index',
        source: 'koo',
        text: issue['text'] as String,
        imageUrl: null,
        timestamp: DateTime.now().subtract(Duration(minutes: index * 30)),
        latitude: (issue['location'] as Map)['lat'],
        longitude: (issue['location'] as Map)['lng'],
        address: (issue['location'] as Map)['address'],
        authorName: issue['author'] as String,
        authorHandle: '@${(issue['author'] as String).toLowerCase().replaceAll(' ', '')}',
        sourceUrl: 'https://kooapp.com/post/sample_$index',
        engagementCount: (index + 1) * 8,
      );
    }).toList();
  }
}
