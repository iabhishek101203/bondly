// lib/screens/listener/dumb_charades_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../models/user_model.dart';
import '../../models/room_model.dart';

class DumbCharadesScreen extends StatefulWidget {
  final RoomModel room;
  final UserModel currentUser;

  const DumbCharadesScreen({super.key, required this.room, required this.currentUser});

  @override
  State<DumbCharadesScreen> createState() => _DumbCharadesScreenState();
}

class _DumbCharadesScreenState extends State<DumbCharadesScreen>
    with TickerProviderStateMixin {

  // Game state
  String _currentWord = '';
  String _currentCategory = '';
  int _score = 0;
  int _timeLeft = 60;
  bool _gameStarted = false;
  bool _gameOver = false;
  bool _wordRevealed = false;
  Timer? _timer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final Map<String, List<String>> _categories = {
    '🎬 Movies': [
      'Dilwale Dulhania Le Jayenge', 'Sholay', '3 Idiots', 'Dangal',
      'Kabir Singh', 'Uri', 'Bahubali', 'KGF', 'RRR', 'Chennai Express',
      'PK', 'Dil Chahta Hai', 'Lagaan', 'Zindagi Na Milegi Dobara',
    ],
    '📺 TV Shows': [
      'Mirzapur', 'Sacred Games', 'Panchayat', 'Scam 1992', 'Aspirants',
      'Broken But Beautiful', 'Breathe', 'Delhi Crime', 'Four More Shots',
    ],
    '🎵 Songs': [
      'Tum Hi Ho', 'Channa Mereya', 'Kal Ho Na Ho', 'Dil Dhadakne Do',
      'Kesariya', 'Raataan Lambiyan', 'Pasoori', 'Dynamite', 'Shape of You',
    ],
    '🌟 Celebrities': [
      'Shah Rukh Khan', 'Virat Kohli', 'Priyanka Chopra', 'Ranveer Singh',
      'Deepika Padukone', 'Akshay Kumar', 'Alia Bhatt', 'Ranbir Kapoor',
      'MS Dhoni', 'Sachin Tendulkar', 'Rohit Sharma',
    ],
    '📚 Proverbs': [
      'All that glitters is not gold', 'Actions speak louder than words',
      'A stitch in time saves nine', 'Better late than never',
      'Every cloud has a silver lining', 'Honesty is the best policy',
    ],
  };

  String _selectedCategory = '🎬 Movies';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _gameOver = false;
      _score = 0;
      _timeLeft = 60;
      _wordRevealed = false;
    });
    _pickNewWord();
    _startTimer();
  }

  void _pickNewWord() {
    final words = _categories[_selectedCategory]!;
    final random = Random();
    setState(() {
      _currentWord = words[random.nextInt(words.length)];
      _currentCategory = _selectedCategory;
      _wordRevealed = false;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 0) {
        timer.cancel();
        setState(() => _gameOver = true);
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _correct() {
    setState(() { _score++; });
    _pickNewWord();
  }

  void _skip() => _pickNewWord();

  void _revealWord() => setState(() => _wordRevealed = true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _gameOver
                  ? _buildGameOver()
                  : !_gameStarted
                      ? _buildSetup()
                      : _buildGamePlay(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () { _timer?.cancel(); Navigator.pop(context); },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Text('🎭 Dumb Charades',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (_gameStarted && !_gameOver)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _timeLeft <= 10 ? Colors.red.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _timeLeft <= 10 ? Colors.red : Colors.white24,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer, color: _timeLeft <= 10 ? Colors.red : Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text('$_timeLeft s',
                      style: TextStyle(
                        color: _timeLeft <= 10 ? Colors.red : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Setup Screen ─────────────────────────────────────────────────
  Widget _buildSetup() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // How to play
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('How to Play 🎯',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...[
                  '🎭  One person acts it out — NO speaking!',
                  '👀  Others watch and guess the word',
                  '✅  Tap "Correct" when someone guesses right',
                  '⏭️  Tap "Skip" to move to next word',
                  '⏱️  60 seconds per round',
                ].map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(step, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Category picker
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Choose Category',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _categories.keys.map((cat) {
              final selected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryPink : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.primaryPink : Colors.white24,
                    ),
                  ),
                  child: Text(cat,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      )),
                ),
              );
            }).toList(),
          ),
          const Spacer(),

          // Start button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 8,
                shadowColor: AppColors.primaryPink.withValues(alpha: 0.4),
              ),
              child: const Text('Start Game 🎬',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Gameplay Screen ──────────────────────────────────────────────
  Widget _buildGamePlay() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Score + category
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Text('✅ ', style: TextStyle(fontSize: 14)),
                    Text('Score: $_score',
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_currentCategory,
                    style: const TextStyle(color: Colors.purple, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Word card
          Expanded(
            child: ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryPink.withValues(alpha: 0.3),
                      Colors.purple.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.primaryPink.withValues(alpha: 0.4), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('ACT THIS OUT! 🎭',
                        style: TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 2)),
                    const SizedBox(height: 20),
                    if (_wordRevealed)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _currentWord,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _revealWord,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Text('TAP TO REVEAL WORD',
                              style: TextStyle(color: Colors.white70, fontSize: 16,
                                  fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              // Skip
              Expanded(
                child: GestureDetector(
                  onTap: _skip,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('⏭️', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Text('Skip', style: TextStyle(color: Colors.white70,
                            fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Correct
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _correct,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          blurRadius: 12, offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('✅', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Text('Correct!', style: TextStyle(color: Colors.white,
                            fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Game Over Screen ─────────────────────────────────────────────
  Widget _buildGameOver() {
    String medal = _score >= 10 ? '🥇' : _score >= 5 ? '🥈' : '🥉';
    String message = _score >= 10
        ? 'Amazing! You\'re on fire!'
        : _score >= 5
            ? 'Great job! Keep it up!'
            : 'Good try! Play again!';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(medal, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            const Text('Time\'s Up!',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('Final Score', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('$_score', style: const TextStyle(
                      color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold)),
                  const Text('words guessed', style: TextStyle(color: Colors.white54, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Exit', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Play Again', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
