import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final int tokens;
  final int streak;
  final DateTime? lastCallDate;

  UserModel({
    required this.uid,
    required this.name,
    this.tokens = 0,
    this.streak = 0,
    this.lastCallDate,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      name: data['name'] ?? '',
      tokens: data['tokens'] ?? 0,
      streak: data['streak'] ?? 0,
      lastCallDate: data['lastCallDate'] != null 
          ? (data['lastCallDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'tokens': tokens,
      'streak': streak,
      'lastCallDate': lastCallDate != null ? Timestamp.fromDate(lastCallDate!) : null,
    };
  }
}
