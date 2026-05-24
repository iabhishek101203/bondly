// lib/screens/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/colors.dart';
import '../utils/avatar_utils.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import 'call_screen.dart';

class ChatScreen extends StatefulWidget {
  final UserModel otherUser;

  const ChatScreen({super.key, required this.otherUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _myUid = FirebaseAuth.instance.currentUser!.uid;
  bool _showEmojis = false;

  static const _quickEmojis = [
    '😊', '❤️', '😂', '👍', '🔥', '😍', '🥰', '😎',
    '👋', '🙏', '💯', '✨', '😄', '🤔', '😅', '💪',
  ];

  @override
  void initState() {
    super.initState();
    // Mark messages as seen when screen opens
    _chatService.markSeen(widget.otherUser.uid);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() => _showEmojis = false);
    await _chatService.sendMessage(widget.otherUser.uid, text);
    _scrollToBottom();
  }

  void _onLongPressMessage(MessageModel msg) {
    if (msg.senderId != _myUid) return; // can only delete own messages
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Copy
            ListTile(
              leading: const Icon(Icons.copy_outlined,
                  color: AppColors.textDark),
              title: const Text('Copy Message'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: msg.text));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
            // Delete
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Delete Message',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(context);
                await _chatService.deleteMessage(
                    widget.otherUser.uid, msg.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF0F3),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ─────────────────────────────────────────
            _buildAppBar(),

            // ── Messages ─────────────────────────────────────────
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                stream: _chatService.getMessages(widget.otherUser.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryPink));
                  }

                  final messages = snapshot.data ?? [];

                  // Mark seen whenever new messages arrive
                  if (messages.isNotEmpty) {
                    _chatService.markSeen(widget.otherUser.uid);
                    _scrollToBottom();
                  }

                  if (messages.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == _myUid;
                      final showDate = index == 0 ||
                          _isDifferentDay(
                              messages[index - 1].timestamp,
                              msg.timestamp);
                      return Column(
                        children: [
                          if (showDate) _buildDateDivider(msg.timestamp),
                          _buildMessageBubble(msg, isMe),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // ── Emoji Picker ──────────────────────────────────────
            if (_showEmojis) _buildEmojiRow(),

            // ── Input Bar ─────────────────────────────────────────
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textDark, size: 20),
          ),
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
                AvatarUtils.getAvatarUrl(widget.otherUser.name)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUser.name,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: widget.otherUser.isOnline
                            ? Colors.greenAccent
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.otherUser.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                          fontSize: 12,
                          color: widget.otherUser.isOnline
                              ? Colors.green
                              : AppColors.textGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Audio call button
          IconButton(
            onPressed: () => _startCall(isVideo: false),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryPink.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone,
                  color: AppColors.primaryPink, size: 20),
            ),
          ),
          // Video call button
          IconButton(
            onPressed: () => _startCall(isVideo: true),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primaryPink, AppColors.secondaryPink]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.videocam,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── Message Bubble ────────────────────────────────────────────────

  Widget _buildMessageBubble(MessageModel msg, bool isMe) {
    return GestureDetector(
      onLongPress: () => _onLongPressMessage(msg),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(
                    AvatarUtils.getAvatarUrl(widget.otherUser.name)),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.68,
                    ),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? const LinearGradient(
                              colors: [
                                AppColors.primaryPink,
                                AppColors.secondaryPink
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isMe ? null : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: isMe ? Colors.white : AppColors.textDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.timeLabel,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textGrey),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          msg.seen ? Icons.done_all : Icons.done,
                          size: 13,
                          color: msg.seen
                              ? AppColors.primaryPink
                              : AppColors.textGrey,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isMe) const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  // ── Date Divider ──────────────────────────────────────────────────

  Widget _buildDateDivider(DateTime? date) {
    if (date == null) return const SizedBox.shrink();
    final now = DateTime.now();
    String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textGrey)),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  bool _isDifferentDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  // ── Empty State ───────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: NetworkImage(
                AvatarUtils.getAvatarUrl(widget.otherUser.name)),
          ),
          const SizedBox(height: 16),
          Text(
            widget.otherUser.name,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryPink.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '👋 Say hello!',
              style:
                  TextStyle(color: AppColors.primaryPink, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ── Emoji Row ─────────────────────────────────────────────────────

  Widget _buildEmojiRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: _quickEmojis.map((emoji) {
          return GestureDetector(
            onTap: () {
              _controller.text += emoji;
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Input Bar ─────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji toggle
          GestureDetector(
            onTap: () {
              setState(() => _showEmojis = !_showEmojis);
              FocusScope.of(context).unfocus();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                _showEmojis ? '⌨️' : '😊',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                onTap: () => setState(() => _showEmojis = false),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle:
                      TextStyle(color: AppColors.textGrey, fontSize: 14),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppColors.primaryPink, AppColors.secondaryPink]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── Start Call ────────────────────────────────────────────────────

  void _startCall({required bool isVideo}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          otherUser: widget.otherUser,
          isVideo: isVideo,
          isOutgoing: true,
        ),
      ),
    );
  }
}
