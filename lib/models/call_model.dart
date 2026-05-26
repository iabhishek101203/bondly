// lib/models/call_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CallModel {
  final String id;
  final String otherUserUid;
  final String otherUserName;
  final bool isVideo;
  final int durationSeconds;
  final bool isMissed;
  final DateTime? timestamp;

  CallModel({required this.id, required this.otherUserUid, required this.otherUserName,
      required this.isVideo, required this.durationSeconds, required this.isMissed, this.timestamp});

  factory CallModel.fromMap(Map<String, dynamic> map, String id) {
    return CallModel(
      id: id,
      otherUserUid: map['otherUserUid'] ?? '',
      otherUserName: map['otherUserName'] ?? 'Unknown',
      isVideo: map['isVideo'] ?? false,
      durationSeconds: map['durationSeconds'] ?? 0,
      isMissed: map['isMissed'] ?? false,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  String get durationLabel {
    if (isMissed) return 'Missed';
    if (durationSeconds < 60) return '${durationSeconds}s';
    return '${durationSeconds ~/ 60} min${durationSeconds ~/ 60 == 1 ? '' : 's'}';
  }

  String get timeAgo {
    if (timestamp == null) return '';
    final diff = DateTime.now().difference(timestamp!);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}
