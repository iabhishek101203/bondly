// lib/screens/add_token.dart

import 'package:bondly/utils/colors.dart';
import 'package:bondly/widgets/token_package.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/token_package.dart';
import '../widgets/token_card.dart';
import 'payment_page.dart';

class AddTokenScreen extends StatefulWidget {
  final int currentBalance;
  final String userName;
  final String? avatarUrl;

  const AddTokenScreen({
    super.key,
    this.currentBalance = 0,
    this.userName = 'User',
    this.avatarUrl,
  });

  @override
  State<AddTokenScreen> createState() => _AddTokenScreenState();
}

class _AddTokenScreenState extends State<AddTokenScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedPackageId;
  late AnimationController _headerAnimController;
  late Animation<double> _headerFadeAnim;

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFadeAnim = CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOut,
    );
    _headerAnimController.forward();
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    super.dispose();
  }

  void _onPackageTapped(TokenPackage package) {
    setState(() => _selectedPackageId = package.id);

    // Small delay so user sees the selected state before navigating
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              PaymentPage(package: package),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(begin: const Offset(0, 1), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tokenBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.tokenBgGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App Bar ─────────────────────────────────────────
              SliverToBoxAdapter(child: _buildAppBar()),

              // ── Wallet Header Card ───────────────────────────────
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerFadeAnim,
                  child: _buildWalletHeader(),
                ),
              ),

              // ── Section Title ────────────────────────────────────
              SliverToBoxAdapter(child: _buildSectionTitle()),

              // ── Token Packages Grid ──────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final package = TokenPackage.packages[index];
                      return TokenCard(
                        package: package,
                        isSelected: _selectedPackageId == package.id,
                        onTap: () => _onPackageTapped(package),
                      );
                    },
                    childCount: TokenPackage.packages.length,
                  ),
                ),
              ),

              // ── Benefits Section ─────────────────────────────────
              SliverToBoxAdapter(child: _buildBenefitsSection()),

              // ── Secure Payment Badge ─────────────────────────────
              SliverToBoxAdapter(child: _buildSecureBadge()),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: AppColors.lavenderDeep,
          ),
          const Text(
            'Add Tokens',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          // Token balance pill
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _coinIcon(size: 16),
                const SizedBox(width: 5),
                Text(
                  '${widget.currentBalance}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Wallet Header ─────────────────────────────────────────────────
  Widget _buildWalletHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.lavenderDeep.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.roseSoft,
              backgroundImage: widget.avatarUrl != null
                  ? NetworkImage(widget.avatarUrl!)
                  : null,
              child: widget.avatarUrl == null
                  ? Text(
                      widget.userName.isNotEmpty
                          ? widget.userName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 16),

          // Name + balance
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'My Wallet',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Balance box
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Current Balance',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _coinIcon(size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.currentBalance}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section Title ─────────────────────────────────────────────────
  Widget _buildSectionTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Text(
            'Choose a Package',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          Spacer(),
          Text(
            '6 options',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  // ── Benefits Section ──────────────────────────────────────────────
  Widget _buildBenefitsSection() {
    final benefits = [
      {'icon': Icons.videocam_rounded, 'title': 'Video Calls', 'desc': 'Connect face to face'},
      {'icon': Icons.mic_rounded, 'title': 'Audio Calls', 'desc': 'Voice conversations'},
      {'icon': Icons.card_giftcard_rounded, 'title': 'Send Gifts', 'desc': 'Surprise someone'},
      {'icon': Icons.star_rounded, 'title': 'Premium', 'desc': 'Unlock exclusives'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What you can do with Tokens',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.6,
            ),
            itemCount: benefits.length,
            itemBuilder: (context, index) {
              final b = benefits[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.lavenderSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        b['icon'] as IconData,
                        size: 16,
                        color: AppColors.lavenderDeep,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            b['title'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            b['desc'] as String,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Secure Badge ──────────────────────────────────────────────────
  Widget _buildSecureBadge() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_rounded, size: 14, color: AppColors.success),
          const SizedBox(width: 6),
          const Text(
            '100% Secure Payments  ·  Instant Token Credit  ·  24/7 Support',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Coin Icon Helper ──────────────────────────────────────────────
  Widget _coinIcon({double size = 20}) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.goldShimmer, AppColors.goldMid, AppColors.goldDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldMid.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '₹',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}