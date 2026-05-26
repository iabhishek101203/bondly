// lib/screens/listener/live_room_screen.dart

import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/avatar_utils.dart';
import '../../models/user_model.dart';
import '../../models/room_model.dart';
import '../../models/gift_model.dart';
import '../../services/firestore_service.dart';
import '../../services/chat_service.dart';
import '../listener/gift_panel.dart';
import '../listener/dumb_charades_screen.dart';

class LiveRoomScreen extends StatefulWidget {
  final RoomModel room;
  final UserModel currentUser;

  const LiveRoomScreen({super.key, required this.room, required this.currentUser});

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> {
  final FirestoreService _fs = FirestoreService();
  final ChatService _chat = ChatService();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Local list of gift animations
  final List<Map<String, dynamic>> _giftAnimations = [];

  @override
  void initState() {
    super.initState();
    _fs.joinRoom(widget.room.id);
    _listenForGifts();
  }

  @override
  void dispose() {
    _fs.leaveRoom(widget.room.id);
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _listenForGifts() {
    _fs.getRoomGifts(widget.room.id).listen((gifts) {
      if (gifts.isNotEmpty && mounted) {
        final latest = gifts.first;
        setState(() {
          _giftAnimations.add(latest);
        });
        // Remove animation after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _giftAnimations.remove(latest));
        });
      }
    });
  }

  void _openGiftPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => GiftPanel(
        currentUser: widget.currentUser,
        speakerUid: widget.room.speakerUid,
        roomId: widget.room.id,
        onGiftSent: (gift) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${gift.emoji} ${gift.name} sent! -${gift.tokens} tokens'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ));
        },
      ),
    );
  }

  void _openDumbCharades() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => DumbCharadesScreen(
        room: widget.room,
        currentUser: widget.currentUser,
      ),
    ));
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();
    await _chat.sendMessage(widget.room.speakerUid, text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Background (speaker video placeholder) ─────────────
          _buildBackground(),

          // ── Gift Animations ─────────────────────────────────────
          ..._giftAnimations.map((g) => _buildGiftAnimation(g)),

          // ── Top Bar ─────────────────────────────────────────────
          SafeArea(child: _buildTopBar()),

          // ── Bottom Area ─────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple.shade900,
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(AvatarUtils.getAvatarUrl(widget.room.speakerName)),
            ),
            const SizedBox(height: 16),
            Text(widget.room.speakerName,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: Colors.white, size: 8),
                  SizedBox(width: 5),
                  Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(AvatarUtils.getAvatarUrl(widget.room.speakerName)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.room.speakerName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _fs.getRoomGifts(widget.room.id),
                  builder: (context, snap) {
                    return Text('${widget.room.participants} watching',
                        style: const TextStyle(color: Colors.white60, fontSize: 11));
                  },
                ),
              ],
            ),
          ),
          // Token balance pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text('${widget.currentUser.tokens}',
                    style: const TextStyle(color: Color(0xFFFFAB00), fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftAnimation(Map<String, dynamic> gift) {
    return Positioned(
      bottom: 200,
      left: 16,
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryPink.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(gift['giftEmoji'] ?? '🎁', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(gift['fromName'] ?? 'Someone',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('sent ${gift['giftName']}',
                      style: const TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomArea() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.95), Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
      padding: EdgeInsets.only(
        left: 12, right: 12, top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Chat messages ──────────────────────────────────────
          SizedBox(
            height: 150,
            child: StreamBuilder(
              stream: _chat.getMessages(widget.room.speakerUid),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isMe = msg.senderId == widget.currentUser.uid;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe) ...[
                            CircleAvatar(
                              radius: 10,
                              backgroundImage: NetworkImage(
                                  AvatarUtils.getAvatarUrl(widget.room.speakerName)),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? AppColors.primaryPink.withValues(alpha: 0.8)
                                    : Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(msg.text,
                                  style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // ── Action buttons + input ─────────────────────────────
          Row(
            children: [
              // Chat input
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Say something…',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Send
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryPink, shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 8),

              // Gift
              GestureDetector(
                onTap: _openGiftPanel,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFAB00).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFAB00).withValues(alpha: 0.5)),
                  ),
                  child: const Center(child: Text('🎁', style: TextStyle(fontSize: 18))),
                ),
              ),
              const SizedBox(width: 8),

              // Dumb Charades game
              GestureDetector(
                onTap: _openDumbCharades,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.purple.withValues(alpha: 0.5)),
                  ),
                  child: const Center(child: Text('🎭', style: TextStyle(fontSize: 18))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
