// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../models/call_model.dart';
import '../models/gift_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No signed-in user found.');
    return user.uid;
  }

  // ── User ──────────────────────────────────────────────────────────

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
    String role = 'listener',
    String gender = 'other',
    String preference = 'any',
    List<String> interests = const [],
  }) async {
    final ref = _db.collection('users').doc(_uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'name': name,
        'email': email ?? '',
        'phone': phone ?? '',
        'role': role,
        'gender': gender,
        'preference': preference,
        'kycStatus': 'none',
        'tokens': 50,
        'earningTokens': 0,
        'totalWithdrawn': 0,
        'streak': 0,
        'lastCallDate': null,
        'interests': interests,
        'isOnline': true,
        'isLive': false,
        'isFavoriteSpeaker': false,
        'rating': 0.0,
        'totalCalls': 0,
        'totalMinutes': 0,
        'favoriteUids': [],
        'followers': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.update({'isOnline': true});
    }
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    try { await _db.collection('users').doc(_uid).update({'isOnline': isOnline}); }
    catch (_) {}
  }

  Future<void> updateProfile({String? name, List<String>? interests}) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (interests != null) updates['interests'] = interests;
    if (updates.isNotEmpty) await _db.collection('users').doc(_uid).update(updates);
  }

  // ── Speakers Feed (for listeners) ─────────────────────────────────

  /// Returns live speakers filtered by listener's preference
  Stream<List<UserModel>> getLiveSpeakers({String preference = 'any'}) {
    Query query = _db.collection('users')
        .where('role', isEqualTo: 'speaker')
        .where('isLive', isEqualTo: true);

    if (preference != 'any') {
      query = query.where('gender', isEqualTo: preference);
    }

    return query.limit(20).snapshots().map((snap) =>
        snap.docs.map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());
  }

  /// Returns online speakers (not necessarily live)
  Stream<List<UserModel>> getOnlineSpeakers({String preference = 'any'}) {
    Query query = _db.collection('users')
        .where('role', isEqualTo: 'speaker')
        .where('isOnline', isEqualTo: true);

    if (preference != 'any') {
      query = query.where('gender', isEqualTo: preference);
    }

    return query.limit(30).snapshots().map((snap) =>
        snap.docs.map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>, d.id))
            .where((u) => u.uid != _uid).toList());
  }

  // ── Online Users (connect screen) ─────────────────────────────────

  Stream<List<UserModel>> getOnlineUsers() {
    return _db.collection('users').where('isOnline', isEqualTo: true).limit(20)
        .snapshots().map((snap) => snap.docs
            .map((d) => UserModel.fromMap(d.data(), d.id))
            .where((u) => u.uid != _uid).toList());
  }

  // ── Favorites ──────────────────────────────────────────────────────

  Stream<List<UserModel>> getFavoriteSpeakers() {
    return _db.collection('users')
        .where('isFavoriteSpeaker', isEqualTo: true)
        .orderBy('rating', descending: true)
        .limit(10)
        .snapshots()
        .map((snap) => snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList());
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

  // ── Live Rooms ──────────────────────────────────────────────────────

  Stream<List<RoomModel>> getLiveRooms({String? category}) {
    Query query = _db.collection('rooms').where('isLive', isEqualTo: true);
    if (category != null) query = query.where('category', isEqualTo: category);
    return query.snapshots().map((snap) =>
        snap.docs.map((d) => RoomModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());
  }

  Future<String> createRoom({
    required String title,
    required String category,
  }) async {
    final me = await getUser(_uid);
    final ref = await _db.collection('rooms').add({
      'speakerUid': _uid,
      'speakerName': me?.name ?? 'Speaker',
      'title': title,
      'category': category,
      'participants': 0,
      'isLive': true,
      'totalGiftsReceived': 0,
      'startedAt': FieldValue.serverTimestamp(),
    });
    await _db.collection('users').doc(_uid).update({
      'isLive': true,
      'currentRoomId': ref.id,
    });
    return ref.id;
  }

  Future<void> endRoom(String roomId) async {
    await _db.collection('rooms').doc(roomId).update({'isLive': false});
    await _db.collection('users').doc(_uid).update({
      'isLive': false,
      'currentRoomId': null,
    });
  }

  Future<void> joinRoom(String roomId) async {
    await _db.collection('rooms').doc(roomId).update({
      'participants': FieldValue.increment(1),
    });
  }

  Future<void> leaveRoom(String roomId) async {
    await _db.collection('rooms').doc(roomId).update({
      'participants': FieldValue.increment(-1),
    });
  }

  // ── Gifts ───────────────────────────────────────────────────────────

  Future<void> sendGift({
    required String toUid,
    required String roomId,
    required GiftItem gift,
    required String senderName,
  }) async {
    // Check balance
    final snap = await _db.collection('users').doc(_uid).get();
    final balance = (snap.data()?['tokens'] ?? 0) as int;
    if (balance < gift.tokens) throw Exception('Insufficient tokens.');

    final batch = _db.batch();

    // Deduct from listener
    batch.update(_db.collection('users').doc(_uid), {
      'tokens': FieldValue.increment(-gift.tokens),
    });

    // Credit 50% to speaker
    final speakerEarning = (gift.tokens * 0.5).floor();
    batch.update(_db.collection('users').doc(toUid), {
      'earningTokens': FieldValue.increment(speakerEarning),
    });

    // Log gift in room
    batch.set(_db.collection('rooms').doc(roomId).collection('gifts').doc(), {
      'fromUid': _uid,
      'fromName': senderName,
      'toUid': toUid,
      'giftId': gift.id,
      'giftName': gift.name,
      'giftEmoji': gift.emoji,
      'tokens': gift.tokens,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update room gift total
    batch.update(_db.collection('rooms').doc(roomId), {
      'totalGiftsReceived': FieldValue.increment(gift.tokens),
    });

    // Log commission in ledger
    batch.set(_db.collection('commissions').doc(), {
      'fromUid': _uid,
      'toUid': toUid,
      'type': 'gift',
      'totalTokens': gift.tokens,
      'speakerShare': speakerEarning,
      'platformShare': gift.tokens - speakerEarning,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Stream of recent gifts in a room (for live gift animations)
  Stream<List<Map<String, dynamic>>> getRoomGifts(String roomId) {
    return _db.collection('rooms').doc(roomId).collection('gifts')
        .orderBy('timestamp', descending: true).limit(20)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }

  // ── Withdrawal (Speaker) ────────────────────────────────────────────

  Future<void> requestWithdrawal(int tokenAmount) async {
    final snap = await _db.collection('users').doc(_uid).get();
    final balance = (snap.data()?['earningTokens'] ?? 0) as int;
    final inrAmount = tokenAmount * 0.5;

    if (balance < tokenAmount) throw Exception('Insufficient earning balance.');
    if (inrAmount < 500) throw Exception('Minimum withdrawal is ₹500.');

    await _db.collection('withdrawals').add({
      'speakerUid': _uid,
      'tokenAmount': tokenAmount,
      'inrAmount': inrAmount,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });

    // Hold the tokens (deduct from earningTokens)
    await _db.collection('users').doc(_uid).update({
      'earningTokens': FieldValue.increment(-tokenAmount),
      'totalWithdrawn': FieldValue.increment(tokenAmount),
    });
  }

  Stream<List<Map<String, dynamic>>> getWithdrawalHistory() {
    return _db.collection('withdrawals')
        .where('speakerUid', isEqualTo: _uid)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  // ── Call History ────────────────────────────────────────────────────

  Stream<List<CallModel>> getCallHistory() {
    return _db.collection('users').doc(_uid).collection('calls')
        .orderBy('timestamp', descending: true).limit(30)
        .snapshots()
        .map((snap) => snap.docs.map((d) => CallModel.fromMap(d.data(), d.id)).toList());
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
      if (!isMissed) 'totalMinutes': FieldValue.increment((durationSeconds / 60).ceil()),
    });
  }

  // ── Daily Rewards ───────────────────────────────────────────────────

  Future<void> claimDailyReward() async {
    final docRef = _db.collection('users').doc(_uid);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception('User does not exist!');
      final user = UserModel.fromMap(snapshot.data()!, snapshot.id);
      final now = DateTime.now();
      final lastDate = user.lastCallDate;
      if (lastDate != null && lastDate.year == now.year &&
          lastDate.month == now.month && lastDate.day == now.day) {
        throw Exception('Already claimed today.');
      }
      int newStreak = user.streak;
      if (lastDate != null) {
        final diff = now.difference(lastDate).inDays;
        newStreak = diff == 1 ? newStreak + 1 : 1;
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
    });
  }

  // ── Tokens ──────────────────────────────────────────────────────────

  Future<void> addTokens(int amount) async {
    await _db.collection('users').doc(_uid).update({'tokens': FieldValue.increment(amount)});
  }

  Future<void> deductTokens(int amount) async {
    final snap = await _db.collection('users').doc(_uid).get();
    final current = (snap.data()?['tokens'] ?? 0) as int;
    if (current < amount) throw Exception('Insufficient tokens.');
    await _db.collection('users').doc(_uid).update({'tokens': FieldValue.increment(-amount)});
  }

  // ── Sign Out ────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await setOnlineStatus(false);
    await _auth.signOut();
  }
}
