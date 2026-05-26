// lib/models/room_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String id;
  final String speakerUid;
  final String speakerName;
  final String title;
  final String category;
  final int participants;
  final bool isLive;
  final String? thumbnailUrl;
  final int totalGiftsReceived;
  final DateTime? startedAt;

  RoomModel({
    required this.id,
    required this.speakerUid,
    required this.speakerName,
    required this.title,
    required this.category,
    required this.participants,
    required this.isLive,
    this.thumbnailUrl,
    this.totalGiftsReceived = 0,
    this.startedAt,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map, String id) {
    return RoomModel(
      id: id,
      speakerUid: map['speakerUid'] ?? '',
      speakerName: map['speakerName'] ?? 'Speaker',
      title: map['title'] ?? 'Live Room',
      category: map['category'] ?? 'chat',
      participants: (map['participants'] ?? 0) as int,
      isLive: map['isLive'] ?? false,
      thumbnailUrl: map['thumbnailUrl'],
      totalGiftsReceived: (map['totalGiftsReceived'] ?? 0) as int,
      startedAt: (map['startedAt'] as Timestamp?)?.toDate(),
    );
  }

  String get categoryEmoji {
    switch (category) {
      case 'singing': return '🎵';
      case 'games':   return '🎮';
      case 'fun':     return '😂';
      default:        return '💬';
    }
  }
}
