// lib/services/chat_service.dart
// Add these methods to your FirestoreService or use as a standalone service.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // ── Chat ID ───────────────────────────────────────────────────────
  // Always the same regardless of who initiates — sorted UIDs joined by "_"
  String getChatId(String otherUid) {
    final sorted = [_uid, otherUid]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  // ── Send Message ──────────────────────────────────────────────────
  Future<void> sendMessage(String otherUid, String text) async {
    if (text.trim().isEmpty) return;
    final chatId = getChatId(otherUid);

    // Write message
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'text': text.trim(),
      'senderId': _uid,
      'timestamp': FieldValue.serverTimestamp(),
      'seen': false,
    });

    // Update chat metadata (for inbox/recent chats list)
    await _db.collection('chats').doc(chatId).set({
      'participants': [_uid, otherUid],
      'lastMessage': text.trim(),
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastSenderId': _uid,
    }, SetOptions(merge: true));
  }

  // ── Stream Messages ───────────────────────────────────────────────
  Stream<List<MessageModel>> getMessages(String otherUid) {
    final chatId = getChatId(otherUid);
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ── Mark Messages as Seen ────────────────────────────────────────
  Future<void> markSeen(String otherUid) async {
    final chatId = getChatId(otherUid);
    final unseen = await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('seen', isEqualTo: false)
        .where('senderId', isNotEqualTo: _uid)
        .get();

    if (unseen.docs.isEmpty) return;

    final batch = _db.batch();
    for (final doc in unseen.docs) {
      batch.update(doc.reference, {'seen': true});
    }
    await batch.commit();
  }

  // ── Unread Count ─────────────────────────────────────────────────
  Stream<int> getUnreadCount(String otherUid) {
    final chatId = getChatId(otherUid);
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('seen', isEqualTo: false)
        .where('senderId', isNotEqualTo: _uid)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ── Delete Message ────────────────────────────────────────────────
  Future<void> deleteMessage(String otherUid, String messageId) async {
    final chatId = getChatId(otherUid);
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }
}
