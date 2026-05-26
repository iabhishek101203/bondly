// lib/screens/listener/gift_panel.dart

import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../models/user_model.dart';
import '../../models/gift_model.dart';
import '../../services/firestore_service.dart';

class GiftPanel extends StatefulWidget {
  final UserModel currentUser;
  final String speakerUid;
  final String roomId;
  final void Function(GiftItem gift) onGiftSent;

  const GiftPanel({
    super.key,
    required this.currentUser,
    required this.speakerUid,
    required this.roomId,
    required this.onGiftSent,
  });

  @override
  State<GiftPanel> createState() => _GiftPanelState();
}

class _GiftPanelState extends State<GiftPanel> with SingleTickerProviderStateMixin {
  final FirestoreService _fs = FirestoreService();
  late TabController _tabController;
  GiftItem? _selectedGift;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _sendGift() async {
    if (_selectedGift == null) return;
    if (widget.currentUser.tokens < _selectedGift!.tokens) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Not enough tokens! Buy more to send gifts.'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    setState(() => _isSending = true);
    try {
      await _fs.sendGift(
        toUid: widget.speakerUid,
        roomId: widget.roomId,
        gift: _selectedGift!,
        senderName: widget.currentUser.name,
      );
      if (!mounted) return;
      widget.onGiftSent(_selectedGift!);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24, borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Send a Gift 🎁',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFAB00).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text('${widget.currentUser.tokens}',
                          style: const TextStyle(
                              color: Color(0xFFFFAB00), fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tab bar
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryPink,
            labelColor: AppColors.primaryPink,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: 'Basic'),
              Tab(text: 'Premium'),
              Tab(text: 'Luxury'),
            ],
          ),

          // Gift grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: ['basic', 'premium', 'luxury'].map((cat) {
                final gifts = GiftItem.byCategory(cat);
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: gifts.length,
                  itemBuilder: (context, i) => _buildGiftItem(gifts[i]),
                );
              }).toList(),
            ),
          ),

          // Send button
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 12),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_selectedGift == null || _isSending) ? null : _sendGift,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  disabledBackgroundColor: Colors.white12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: _isSending
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text(
                        _selectedGift == null
                            ? 'Select a gift'
                            : 'Send ${_selectedGift!.emoji} for ${_selectedGift!.tokens} tokens',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftItem(GiftItem gift) {
    final selected = _selectedGift?.id == gift.id;
    final canAfford = widget.currentUser.tokens >= gift.tokens;

    return GestureDetector(
      onTap: canAfford ? () => setState(() => _selectedGift = gift) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryPink.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryPink : Colors.transparent,
            width: selected ? 2 : 0,
          ),
        ),
        child: Opacity(
          opacity: canAfford ? 1.0 : 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(gift.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 4),
              Text(gift.name,
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 9)),
                  Text('${gift.tokens}',
                      style: const TextStyle(
                          color: Color(0xFFFFAB00), fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
