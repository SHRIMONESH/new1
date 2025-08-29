// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Issue _$IssueFromJson(Map<String, dynamic> json) => Issue(
      id: json['id'] as String,
      source: json['source'] as String,
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      authorName: json['authorName'] as String?,
      authorHandle: json['authorHandle'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      engagementCount: json['engagementCount'] as int?,
    );

Map<String, dynamic> _$IssueToJson(Issue instance) => <String, dynamic>{
      'id': instance.id,
      'source': instance.source,
      'text': instance.text,
      'imageUrl': instance.imageUrl,
      'timestamp': instance.timestamp.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'authorName': instance.authorName,
      'authorHandle': instance.authorHandle,
      'sourceUrl': instance.sourceUrl,
      'engagementCount': instance.engagementCount,
    };
