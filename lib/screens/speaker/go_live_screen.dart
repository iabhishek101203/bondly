// lib/screens/speaker/go_live_screen.dart

import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/avatar_utils.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

class GoLiveScreen extends StatefulWidget {
  final UserModel currentUser;
  const GoLiveScreen({super.key, required this.currentUser});

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  final _titleController = TextEditingController();
  String _selectedCategory = 'chat';
  bool _isStarting = false;
  final FirestoreService _fs = FirestoreService();

  final List<Map<String, String>> _categories = [
    {'id': 'chat',    'label': 'Chat',    'emoji': '💬', 'desc': 'Just talk and connect'},
    {'id': 'fun',     'label': 'Fun',     'emoji': '😂', 'desc': 'Jokes, memes, laughs'},
    {'id': 'singing', 'label': 'Singing', 'emoji': '🎵', 'desc': 'Sing for your fans'},
    {'id': 'games',   'label': 'Games',   'emoji': '🎮', 'desc': 'Play games together'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _startLive() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title for your live session'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _isStarting = true);
    try {
      await _fs.createRoom(
        title: _titleController.text.trim(),
        category: _selectedCategory,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are now LIVE! 🔴'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(height: 24),

              const Text('Start Live Session 🔴',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Your followers will be notified',
                  style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 32),

              // Preview card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade900, Colors.black],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(AvatarUtils.getAvatarUrl(widget.currentUser.name)),
                    ),
                    const SizedBox(height: 10),
                    Text(widget.currentUser.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 8),
                          SizedBox(width: 5),
                          Text('LIVE PREVIEW', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Title input
              const Text('Session Title', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                maxLength: 60,
                decoration: InputDecoration(
                  hintText: 'e.g. "Let\'s chat and vibe 😊"',
                  hintStyle: const TextStyle(color: Colors.white38),
                  counterStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primaryPink),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category picker
              const Text('Category', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.5,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final selected = _selectedCategory == cat['id'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat['id']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryPink.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? AppColors.primaryPink : Colors.white12,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(cat['emoji']!, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(cat['label']!,
                                    style: TextStyle(
                                      color: selected ? AppColors.primaryPink : Colors.white,
                                      fontWeight: FontWeight.bold, fontSize: 13,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Go live button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isStarting ? null : _startLive,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor: Colors.red.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 8,
                    shadowColor: Colors.red.withValues(alpha: 0.4),
                  ),
                  child: _isStarting
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.live_tv, color: Colors.white, size: 22),
                            SizedBox(width: 10),
                            Text('Go Live Now!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
