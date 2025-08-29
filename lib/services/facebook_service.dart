import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import '../models/issue.dart';

class FacebookService {
  static const String _baseUrl = 'https://www.facebook.com';
  
  Future<List<Issue>> fetchRecentIssues() async {
    try {
      // Since Facebook has strict scraping policies, we'll generate realistic sample data
      // In a production app, you'd need Facebook Graph API with proper permissions
      return _generateSampleFacebookIssues();
    } catch (e) {
      print('Facebook Service Error: $e');
      return [];
    }
  }

  List<Issue> _generateSampleFacebookIssues() {
    final sampleIssues = [
      {
        'text': 'Traffic signal at Cross Road Junction has been malfunctioning for 3 days. Causing major traffic jams during peak hours. Authorities please take immediate action! 🚦',
        'author': 'Traffic Watch Mumbai',
        'location': {'lat': 19.0176, 'lng': 72.8562, 'address': 'Dadar, Mumbai'},
        'image': 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400',
      },
      {
        'text': 'Water supply has been disrupted in our building for 48 hours. No prior notice given. Residents are facing severe inconvenience. When will this be restored? 💧',
        'author': 'Residents Welfare Association',
        'location': {'lat': 19.1136, 'lng': 72.8697, 'address': 'Malad, Mumbai'},
        'image': null,
      },
      {
        'text': 'Broken footpath near Metro Station. People are forced to walk on the road. Very dangerous especially during monsoon. Please repair urgently! 🚶‍♂️',
        'author': 'Pedestrian Safety Group',
        'location': {'lat': 19.0728, 'lng': 72.8826, 'address': 'Ghatkopar, Mumbai'},
        'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
      },
      {
        'text': 'Overflowing drainage system in our locality. Sewage water on roads. Health department needs to act fast before diseases spread! 🦠',
        'author': 'Health Awareness Mumbai',
        'location': {'lat': 19.0521, 'lng': 72.8636, 'address': 'Kurla, Mumbai'},
        'image': null,
      },
      {
        'text': 'Public toilet facility near bus stop is in terrible condition. No maintenance for months. Commuters are suffering. BMC please take note! 🚽',
        'author': 'Commuter Voice',
        'location': {'lat': 19.0825, 'lng': 72.8811, 'address': 'Powai, Mumbai'},
        'image': null,
      },
      {
        'text': 'Illegal parking blocking emergency vehicle access. Fire brigade had difficulty reaching our building yesterday. Traffic police action needed! 🚒',
        'author': 'Emergency Access Alert',
        'location': {'lat': 19.0596, 'lng': 72.8295, 'address': 'Juhu, Mumbai'},
        'image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      },
      {
        'text': 'Construction debris dumped on public road. Blocking half the lane. Vehicles struggling to pass. Municipal corporation please clear immediately! 🚧',
        'author': 'Road Safety Mumbai',
        'location': {'lat': 19.0270, 'lng': 72.8777, 'address': 'Lower Parel, Mumbai'},
        'image': null,
      },
      {
        'text': 'Stray dogs becoming aggressive in our area. Children afraid to play outside. Animal control department intervention required urgently! 🐕',
        'author': 'Child Safety Forum',
        'location': {'lat': 19.1075, 'lng': 72.8263, 'address': 'Borivali, Mumbai'},
        'image': null,
      },
    ];
    
    return sampleIssues.asMap().entries.map((entry) {
      final index = entry.key;
      final issue = entry.value;
      
      return Issue(
        id: 'facebook_sample_${DateTime.now().millisecondsSinceEpoch}_$index',
        source: 'facebook',
        text: issue['text'] as String,
        imageUrl: issue['image'] as String?,
        timestamp: DateTime.now().subtract(Duration(minutes: index * 45)),
        latitude: (issue['location'] as Map)['lat'],
        longitude: (issue['location'] as Map)['lng'],
        address: (issue['location'] as Map)['address'],
        authorName: issue['author'] as String,
        authorHandle: '@${(issue['author'] as String).toLowerCase().replaceAll(' ', '').replaceAll('mumbai', '')}',
        sourceUrl: 'https://facebook.com/post/sample_$index',
        engagementCount: (index + 1) * 12,
      );
    }).toList();
  }
}
