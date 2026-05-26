// lib/models/message_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final DateTime? timestamp;
  final bool seen;

  MessageModel({required this.id, required this.text, required this.senderId, this.timestamp, this.seen = false});

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
      seen: map['seen'] ?? false,
    );
  }

  String get timeLabel {
    if (timestamp == null) return '';
    final h = timestamp!.hour;
    final m = timestamp!.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:$m $period';
  }
}
