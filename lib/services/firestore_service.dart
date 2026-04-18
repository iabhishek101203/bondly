import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Track the logged-in user dynamically
  Stream<UserModel?> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  // Fetch Favorite Speakers (Mock logic: just list all users sorted by streak/tokens)
  Stream<List<UserModel>> getFavoriteSpeakers() {
    return _db
        .collection('users')
        .orderBy('streak', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Fetch Live Rooms
  Stream<List<RoomModel>> getLiveRooms() {
    return _db
        .collection('rooms')
        .where('isLive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoomModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Claim Daily Reward
  Future<void> claimDailyReward(String uid) async {
    final docRef = _db.collection('users').doc(uid);
    
    return _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      
      if (!snapshot.exists) {
        throw Exception("User does not exist!");
      }

      final data = snapshot.data()!;
      final user = UserModel.fromMap(data, snapshot.id);
      
      final now = DateTime.now();
      final lastDate = user.lastCallDate;
      
      // Check if already claimed today
      if (lastDate != null && 
          lastDate.year == now.year && 
          lastDate.month == now.month && 
          lastDate.day == now.day) {
        throw Exception("You have already claimed your reward today.");
      }
      
      // Calculate new streak
      int newStreak = user.streak;
      if (lastDate != null) {
        final difference = now.difference(lastDate).inDays;
        if (difference == 1) {
          newStreak += 1;
        } else if (difference > 1) {
          newStreak = 1; // Reset streak if missed a day
        }
      } else {
        newStreak = 1; // First ever claim
      }

      // Calculate tokens
      int addedTokens = 10;
      if (newStreak % 3 == 0) {
        addedTokens += 25; // Bonus for 3 day streak
      }

      transaction.update(docRef, {
        'tokens': FieldValue.increment(addedTokens),
        'streak': newStreak,
        'lastCallDate': FieldValue.serverTimestamp(),
      });
    });
  }
}
