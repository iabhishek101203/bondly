// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final int tokens;
  final int streak;
  final DateTime? lastCallDate;
  final List<String> interests;
  final bool isOnline;
  final bool isFavoriteSpeaker;
  final double rating;
  final int totalCalls;
  final int totalMinutes;
  final List<String> favoriteUids;

  UserModel({
    required this.uid,
    required this.name,
    this.email = '',
    this.phone = '',
    this.tokens = 0,
    this.streak = 0,
    this.lastCallDate,
    this.interests = const [],
    this.isOnline = false,
    this.isFavoriteSpeaker = false,
    this.rating = 0.0,
    this.totalCalls = 0,
    this.totalMinutes = 0,
    this.favoriteUids = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      tokens: (map['tokens'] ?? 0) as int,
      streak: (map['streak'] ?? 0) as int,
      lastCallDate: (map['lastCallDate'] as Timestamp?)?.toDate(),
      interests: List<String>.from(map['interests'] ?? []),
      isOnline: map['isOnline'] ?? false,
      isFavoriteSpeaker: map['isFavoriteSpeaker'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalCalls: (map['totalCalls'] ?? 0) as int,
      totalMinutes: (map['totalMinutes'] ?? 0) as int,
      favoriteUids: List<String>.from(map['favoriteUids'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'tokens': tokens,
      'streak': streak,
      'lastCallDate': lastCallDate != null ? Timestamp.fromDate(lastCallDate!) : null,
      'interests': interests,
      'isOnline': isOnline,
      'isFavoriteSpeaker': isFavoriteSpeaker,
      'rating': rating,
      'totalCalls': totalCalls,
      'totalMinutes': totalMinutes,
      'favoriteUids': favoriteUids,
    };
  }
}
