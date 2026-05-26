// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;        // 'listener' | 'speaker'
  final String gender;      // 'male' | 'female' | 'other'
  final String preference;  // 'male' | 'female' | 'any'
  final String kycStatus;   // 'none' | 'pending' | 'approved' | 'rejected'
  final int tokens;
  final int earningTokens;
  final int totalWithdrawn;
  final int streak;
  final DateTime? lastCallDate;
  final List<String> interests;
  final bool isOnline;
  final bool isLive;
  final bool isFavoriteSpeaker;
  final double rating;
  final int totalCalls;
  final int totalMinutes;
  final List<String> favoriteUids;
  final int followers;
  final String? currentRoomId;

  UserModel({
    required this.uid,
    required this.name,
    this.email = '',
    this.phone = '',
    this.role = 'listener',
    this.gender = 'other',
    this.preference = 'any',
    this.kycStatus = 'none',
    this.tokens = 0,
    this.earningTokens = 0,
    this.totalWithdrawn = 0,
    this.streak = 0,
    this.lastCallDate,
    this.interests = const [],
    this.isOnline = false,
    this.isLive = false,
    this.isFavoriteSpeaker = false,
    this.rating = 0.0,
    this.totalCalls = 0,
    this.totalMinutes = 0,
    this.favoriteUids = const [],
    this.followers = 0,
    this.currentRoomId,
  });

  bool get isSpeaker => role == 'speaker';
  bool get isListener => role == 'listener';
  bool get isKycApproved => kycStatus == 'approved';
  double get earningsInr => earningTokens * 0.50;

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'listener',
      gender: map['gender'] ?? 'other',
      preference: map['preference'] ?? 'any',
      kycStatus: map['kycStatus'] ?? 'none',
      tokens: (map['tokens'] ?? 0) as int,
      earningTokens: (map['earningTokens'] ?? 0) as int,
      totalWithdrawn: (map['totalWithdrawn'] ?? 0) as int,
      streak: (map['streak'] ?? 0) as int,
      lastCallDate: (map['lastCallDate'] as Timestamp?)?.toDate(),
      interests: List<String>.from(map['interests'] ?? []),
      isOnline: map['isOnline'] ?? false,
      isLive: map['isLive'] ?? false,
      isFavoriteSpeaker: map['isFavoriteSpeaker'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalCalls: (map['totalCalls'] ?? 0) as int,
      totalMinutes: (map['totalMinutes'] ?? 0) as int,
      favoriteUids: List<String>.from(map['favoriteUids'] ?? []),
      followers: (map['followers'] ?? 0) as int,
      currentRoomId: map['currentRoomId'],
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name, 'email': email, 'phone': phone,
    'role': role, 'gender': gender, 'preference': preference,
    'kycStatus': kycStatus, 'tokens': tokens,
    'earningTokens': earningTokens, 'totalWithdrawn': totalWithdrawn,
    'streak': streak, 'interests': interests, 'isOnline': isOnline,
    'isLive': isLive, 'isFavoriteSpeaker': isFavoriteSpeaker,
    'rating': rating, 'totalCalls': totalCalls, 'totalMinutes': totalMinutes,
    'favoriteUids': favoriteUids, 'followers': followers,
  };
}
