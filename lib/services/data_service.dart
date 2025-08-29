import 'dart:async';
import 'package:flutter/material.dart';
import '../models/issue.dart';
import 'twitter_service.dart';
import 'koo_service.dart';
import 'facebook_service.dart';

class DataService extends ChangeNotifier {
  final TwitterService _twitterService = TwitterService();
  final KooService _kooService = KooService();
  final FacebookService _facebookService = FacebookService();
  
  List<Issue> _issues = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastRefresh;
  Timer? _refreshTimer;
  
  List<Issue> get issues => _issues;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastRefresh => _lastRefresh;
  
  DataService() {
    _startPeriodicRefresh();
    refreshData();
  }
  
  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      refreshData();
    });
  }
  
  Future<void> refreshData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final List<Future<List<Issue>>> futures = [
        _twitterService.fetchRecentIssues(),
        _kooService.fetchRecentIssues(),
        _facebookService.fetchRecentIssues(),
      ];
      
      final results = await Future.wait(futures);
      
      List<Issue> allIssues = [];
      for (final result in results) {
        allIssues.addAll(result);
      }
      
      // Sort by timestamp (newest first)
      allIssues.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Remove duplicates based on similar text content
      _issues = _deduplicateIssues(allIssues);
      _lastRefresh = DateTime.now();
      
    } catch (e) {
      _error = 'Failed to fetch data: $e';
      print('Data refresh error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  List<Issue> _deduplicateIssues(List<Issue> issues) {
    final Map<String, Issue> uniqueIssues = {};
    
    for (final issue in issues) {
      // Create a key based on similar text content
      final key = _createDeduplicationKey(issue.text);
      
      // Keep the issue with more engagement or newer timestamp
      if (!uniqueIssues.containsKey(key) || 
          (issue.engagementCount ?? 0) > (uniqueIssues[key]!.engagementCount ?? 0) ||
          issue.timestamp.isAfter(uniqueIssues[key]!.timestamp)) {
        uniqueIssues[key] = issue;
      }
    }
    
    return uniqueIssues.values.toList();
  }
  
  String _createDeduplicationKey(String text) {
    // Normalize text for deduplication
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .substring(0, text.length > 50 ? 50 : text.length);
  }
  
  List<Issue> getIssuesWithLocation() {
    return _issues.where((issue) => issue.hasLocation).toList();
  }
  
  List<Issue> getIssuesBySource(String source) {
    return _issues.where((issue) => issue.source.toLowerCase() == source.toLowerCase()).toList();
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
