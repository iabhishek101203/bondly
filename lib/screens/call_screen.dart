// lib/screens/call_screen.dart
//
// SETUP REQUIRED:
// 1. Add to pubspec.yaml:
//      agora_rtc_engine: ^6.3.2
//      permission_handler: ^11.3.1
//
// 2. Replace 'YOUR_AGORA_APP_ID' below with your App ID from console.agora.io
//
// 3. Android — android/app/src/main/AndroidManifest.xml (inside <manifest>):
//      <uses-permission android:name="android.permission.RECORD_AUDIO"/>
//      <uses-permission android:name="android.permission.CAMERA"/>
//      <uses-permission android:name="android.permission.INTERNET"/>
//
// 4. iOS — ios/Runner/Info.plist:
//      <key>NSMicrophoneUsageDescription</key>
//      <string>Bondly needs microphone for calls</string>
//      <key>NSCameraUsageDescription</key>
//      <string>Bondly needs camera for video calls</string>

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/colors.dart';
import '../utils/avatar_utils.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

const String _agoraAppId = 'YOUR_AGORA_APP_ID'; // ← replace this

class CallScreen extends StatefulWidget {
  final UserModel otherUser;
  final bool isVideo;
  final bool isOutgoing;

  const CallScreen({
    super.key,
    required this.otherUser,
    required this.isVideo,
    required this.isOutgoing,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late RtcEngine _engine;
  final FirestoreService _firestoreService = FirestoreService();
  final String _myUid = FirebaseAuth.instance.currentUser!.uid;

  bool _localUserJoined = false;
  bool _remoteUserJoined = false;
  int? _remoteUid;

  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isSpeakerOn = true;
  bool _isFrontCamera = true;
  bool _isCallEnded = false;

  // Call timer
  int _secondsElapsed = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  // ── Agora Init ────────────────────────────────────────────────────

  Future<void> _initAgora() async {
    // Request permissions
    await [Permission.microphone, Permission.camera].request();

    // Create engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: _agoraAppId));

    // Register event handlers
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          setState(() => _localUserJoined = true);
          _startTimer();
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() {
            _remoteUid = remoteUid;
            _remoteUserJoined = true;
          });
        },
        onUserOffline: (connection, remoteUid, reason) {
          setState(() {
            _remoteUid = null;
            _remoteUserJoined = false;
          });
          _endCall();
        },
        onLeaveChannel: (connection, stats) {
          setState(() => _localUserJoined = false);
        },
        onError: (err, msg) {
          debugPrint('Agora error: $err — $msg');
        },
      ),
    );

    // Video setup
    if (widget.isVideo) {
      await _engine.enableVideo();
      await _engine.startPreview();
    } else {
      await _engine.disableVideo();
    }

    // Audio setup
    await _engine.setEnableSpeakerphone(_isSpeakerOn);

    // Channel name: sorted UIDs to be consistent on both ends
    final sorted = [_myUid, widget.otherUser.uid]..sort();
    final channelName = '${sorted[0]}_${sorted[1]}';

    // Join channel — token is null for testing; use a token server in production
    await _engine.joinChannel(
      token: '',            // TODO: generate token from your backend in production
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  // ── Timer ─────────────────────────────────────────────────────────

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _secondsElapsed++);
    });
  }

  String get _timerLabel {
    final m = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Controls ──────────────────────────────────────────────────────

  Future<void> _toggleMute() async {
    _isMuted = !_isMuted;
    await _engine.muteLocalAudioStream(_isMuted);
    setState(() {});
  }

  Future<void> _toggleVideo() async {
    _isVideoOff = !_isVideoOff;
    await _engine.muteLocalVideoStream(_isVideoOff);
    setState(() {});
  }

  Future<void> _flipCamera() async {
    _isFrontCamera = !_isFrontCamera;
    await _engine.switchCamera();
    setState(() {});
  }

  Future<void> _toggleSpeaker() async {
    _isSpeakerOn = !_isSpeakerOn;
    await _engine.setEnableSpeakerphone(_isSpeakerOn);
    setState(() {});
  }

  Future<void> _endCall() async {
    if (_isCallEnded) return;
    _isCallEnded = true;
    _timer?.cancel();

    // Log the call in Firestore
    await _firestoreService.logCall(
      otherUserUid: widget.otherUser.uid,
      otherUserName: widget.otherUser.name,
      isVideo: widget.isVideo,
      durationSeconds: _secondsElapsed,
      isMissed: _secondsElapsed < 3,
    );

    await _engine.leaveChannel();
    if (mounted) Navigator.pop(context);
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Background / Remote Video ────────────────────────
          _buildRemoteView(),

          // ── Local preview (video calls only) ────────────────
          if (widget.isVideo && _localUserJoined) _buildLocalPreview(),

          // ── Top Info ─────────────────────────────────────────
          _buildTopInfo(),

          // ── Bottom Controls ───────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildControls(),
          ),
        ],
      ),
    );
  }

  // ── Remote View ───────────────────────────────────────────────────

  Widget _buildRemoteView() {
    if (!widget.isVideo) {
      // Audio call background
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A0F), Color(0xFF2D0A1A)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(
                    AvatarUtils.getAvatarUrl(widget.otherUser.name)),
              ),
              const SizedBox(height: 24),
              Text(
                widget.otherUser.name,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 12),
              _buildStatusLabel(),
            ],
          ),
        ),
      );
    }

    if (_remoteUserJoined && _remoteUid != null) {
      return SizedBox.expand(
        child: AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: _remoteUid),
            connection: RtcConnection(
              channelId: '${([_myUid, widget.otherUser.uid]..sort()).join('_')}',
            ),
          ),
        ),
      );
    }

    // Waiting for other user
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A0A0F), Color(0xFF2D0A1A)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                  AvatarUtils.getAvatarUrl(widget.otherUser.name)),
            ),
            const SizedBox(height: 20),
            Text(
              widget.otherUser.name,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 12),
            _buildStatusLabel(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLabel() {
    if (_remoteUserJoined) {
      return Text(
        _timerLabel,
        style: const TextStyle(
            fontSize: 18,
            color: Colors.white70,
            letterSpacing: 1),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white54),
        ),
        const SizedBox(width: 10),
        Text(
          widget.isOutgoing ? 'Calling…' : 'Connecting…',
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }

  // ── Local Preview (PiP) ───────────────────────────────────────────

  Widget _buildLocalPreview() {
    return Positioned(
      top: 80,
      right: 16,
      child: Container(
        width: 110,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white30, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12)
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: _isVideoOff
            ? Container(
                color: Colors.grey.shade900,
                child: const Center(
                  child: Icon(Icons.videocam_off,
                      color: Colors.white54, size: 28),
                ),
              )
            : AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
      ),
    );
  }

  // ── Top Info ──────────────────────────────────────────────────────

  Widget _buildTopInfo() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.otherUser.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  if (_remoteUserJoined)
                    Text(
                      _timerLabel,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  // ── Controls ──────────────────────────────────────────────────────

  Widget _buildControls() {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 32,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.85),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _controlButton(
                icon: _isMuted ? Icons.mic_off : Icons.mic,
                label: _isMuted ? 'Unmute' : 'Mute',
                isActive: _isMuted,
                onTap: _toggleMute,
              ),
              if (widget.isVideo)
                _controlButton(
                  icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                  label: _isVideoOff ? 'Start Video' : 'Stop Video',
                  isActive: _isVideoOff,
                  onTap: _toggleVideo,
                ),
              _controlButton(
                icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                label: _isSpeakerOn ? 'Speaker' : 'Earpiece',
                isActive: !_isSpeakerOn,
                onTap: _toggleSpeaker,
              ),
              if (widget.isVideo)
                _controlButton(
                  icon: Icons.flip_camera_ios,
                  label: 'Flip',
                  isActive: false,
                  onTap: _flipCamera,
                ),
            ],
          ),
          const SizedBox(height: 28),

          // End call button
          GestureDetector(
            onTap: _endCall,
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red,
                    blurRadius: 16,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: const Icon(Icons.call_end_rounded,
                  color: Colors.white, size: 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.primaryPink : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
