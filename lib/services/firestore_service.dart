// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../models/call_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No signed-in user found.');
    return user.uid;
  }

  // ── User ─────────────────────────────────────────────────────────

  Stream<UserModel?> getCurrentUserStream() {
    return _db.collection('users').doc(_uid).snapshots().map((snap) {
      if (snap.exists) return UserModel.fromMap(snap.data()!, snap.id);
      return null;
    });
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (snap.exists) return UserModel.fromMap(snap.data()!, snap.id);
      return null;
    });
  }

  Future<UserModel?> getUser(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (snap.exists) return UserModel.fromMap(snap.data()!, snap.id);
    return null;
  }

  Future<void> createOrUpdateUser({
    required String name,
    String? email,
    String? phone,
    List<String> interests = const [],
  }) async {
    final ref = _db.collection('users').doc(_uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'name': name,
        'email': email ?? '',
        'phone': phone ?? '',
        'tokens': 50,
        'streak': 0,
        'lastCallDate': null,
        'interests': interests,
        'isOnline': true,
        'isFavoriteSpeaker': false,
        'rating': 0.0,
        'totalCalls': 0,
        'totalMinutes': 0,
        'favoriteUids': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.update({
        'isOnline': true,
        if (interests.isNotEmpty) 'interests': interests,
      });
    }
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    try {
      await _db.collection('users').doc(_uid).update({'isOnline': isOnline});
    } catch (_) {}
  }

  Future<void> updateProfile({String? name, List<String>? interests}) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (interests != null) updates['interests'] = interests;
    if (updates.isNotEmpty) {
      await _db.collection('users').doc(_uid).update(updates);
    }
  }

  // ── Favorites ─────────────────────────────────────────────────────

  Stream<List<UserModel>> getFavoriteSpeakers() {
    return _db
        .collection('users')
        .where('isFavoriteSpeaker', isEqualTo: true)
        .orderBy('rating', descending: true)
        .limit(10)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList());
  }

  Stream<List<UserModel>> getMyFavorites() {
    return _db.collection('users').doc(_uid).snapshots().asyncMap((snap) async {
      if (!snap.exists) return [];
      final favUids = List<String>.from(snap.data()?['favoriteUids'] ?? []);
      if (favUids.isEmpty) return [];
      final results = await Future.wait(favUids.map((uid) => getUser(uid)));
      return results.whereType<UserModel>().toList();
    });
  }

  Future<void> toggleFavorite(String targetUid) async {
    final ref = _db.collection('users').doc(_uid);
    final snap = await ref.get();
    final favs = List<String>.from(snap.data()?['favoriteUids'] ?? []);
    if (favs.contains(targetUid)) {
      await ref.update({'favoriteUids': FieldValue.arrayRemove([targetUid])});
    } else {
      await ref.update({'favoriteUids': FieldValue.arrayUnion([targetUid])});
    }
  }

  Future<bool> isFavorite(String targetUid) async {
    final snap = await _db.collection('users').doc(_uid).get();
    final favs = List<String>.from(snap.data()?['favoriteUids'] ?? []);
    return favs.contains(targetUid);
  }

  // ── Online Users ──────────────────────────────────────────────────

  Stream<List<UserModel>> getOnlineUsers() {
    return _db
        .collection('users')
        .where('isOnline', isEqualTo: true)
        .limit(20)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UserModel.fromMap(d.data(), d.id))
            .where((u) => u.uid != _uid)
            .toList());
  }

  // ── Rooms ─────────────────────────────────────────────────────────

  Stream<List<RoomModel>> getLiveRooms() {
    return _db
        .collection('rooms')
        .where('isLive', isEqualTo: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => RoomModel.fromMap(d.data(), d.id)).toList());
  }

  // ── Call History ──────────────────────────────────────────────────

  Stream<List<CallModel>> getCallHistory() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('calls')
        .orderBy('timestamp', descending: true)
        .limit(30)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CallModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> logCall({
    required String otherUserUid,
    required String otherUserName,
    required bool isVideo,
    required int durationSeconds,
    required bool isMissed,
  }) async {
    await _db.collection('users').doc(_uid).collection('calls').add({
      'otherUserUid': otherUserUid,
      'otherUserName': otherUserName,
      'isVideo': isVideo,
      'durationSeconds': durationSeconds,
      'isMissed': isMissed,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await _db.collection('users').doc(_uid).update({
      'totalCalls': FieldValue.increment(1),
      if (!isMissed)
        'totalMinutes': FieldValue.increment((durationSeconds / 60).ceil()),
    });
  }

  // ── Daily Rewards ─────────────────────────────────────────────────

  Future<void> claimDailyReward() async {
    final docRef = _db.collection('users').doc(_uid);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception('User does not exist!');

      final user = UserModel.fromMap(snapshot.data()!, snapshot.id);
      final now = DateTime.now();
      final lastDate = user.lastCallDate;

      if (lastDate != null &&
          lastDate.year == now.year &&
          lastDate.month == now.month &&
          lastDate.day == now.day) {
        throw Exception('You have already claimed your reward today.');
      }

      int newStreak = user.streak;
      if (lastDate != null) {
        final diff = now.difference(lastDate).inDays;
        if (diff == 1) {
          newStreak += 1;
        } else if (diff > 1) {
          newStreak = 1;
        }
      } else {
        newStreak = 1;
      }

      int addedTokens = 10;
      if (newStreak % 3 == 0) addedTokens += 25;

      transaction.update(docRef, {
        'tokens': FieldValue.increment(addedTokens),
        'streak': newStreak,
        'lastCallDate': FieldValue.serverTimestamp(),
      });
      // Note: void return — no return statement needed
    });
  }

  // ── Tokens ────────────────────────────────────────────────────────

  Future<void> deductTokens(int amount) async {
    final snap = await _db.collection('users').doc(_uid).get();
    final current = (snap.data()?['tokens'] ?? 0) as int;
    if (current < amount) throw Exception('Insufficient tokens.');
    await _db.collection('users').doc(_uid).update(
        {'tokens': FieldValue.increment(-amount)});
  }

  Future<void> addTokens(int amount) async {
    await _db
        .collection('users')
        .doc(_uid)
        .update({'tokens': FieldValue.increment(amount)});
  }

  // ── Sign Out ──────────────────────────────────────────────────────

  Future<void> signOut() async {
    await setOnlineStatus(false);
    await _auth.signOut();
  }
}
