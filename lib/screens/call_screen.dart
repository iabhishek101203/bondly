// lib/screens/call_screen.dart
// Requires: agora_rtc_engine: ^6.3.2, permission_handler: ^11.3.1
// Replace 'YOUR_AGORA_APP_ID' with your App ID from console.agora.io

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/colors.dart';
import '../utils/avatar_utils.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

const String _agoraAppId = 'YOUR_AGORA_APP_ID';

class CallScreen extends StatefulWidget {
  final UserModel otherUser;
  final bool isVideo;
  final bool isOutgoing;
  const CallScreen({super.key, required this.otherUser, required this.isVideo, required this.isOutgoing});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late RtcEngine _engine;
  final FirestoreService _fs = FirestoreService();
  final String _myUid = FirebaseAuth.instance.currentUser!.uid;

  bool _localJoined = false;
  bool _remoteJoined = false;
  int? _remoteUid;
  bool _muted = false;
  bool _videoOff = false;
  bool _speakerOn = true;
  bool _frontCam = true;
  bool _ended = false;

  int _secs = 0;
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

  Future<void> _initAgora() async {
    await [Permission.microphone, Permission.camera].request();
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: _agoraAppId));
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (_, __) { setState(() => _localJoined = true); _startTimer(); },
      onUserJoined: (_, uid, __) => setState(() { _remoteUid = uid; _remoteJoined = true; }),
      onUserOffline: (_, __, ___) { setState(() { _remoteUid = null; _remoteJoined = false; }); _endCall(); },
    ));
    if (widget.isVideo) { await _engine.enableVideo(); await _engine.startPreview(); }
    else { await _engine.disableVideo(); }
    await _engine.setEnableSpeakerphone(_speakerOn);
    final sorted = [_myUid, widget.otherUser.uid]..sort();
    final channel = sorted.join('_');
    await _engine.joinChannel(
      token: '',
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _secs++);
    });
  }

  String get _timerLabel {
    final m = (_secs ~/ 60).toString().padLeft(2, '0');
    final s = (_secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _endCall() async {
    if (_ended) return;
    _ended = true;
    _timer?.cancel();
    await _fs.logCall(
      otherUserUid: widget.otherUser.uid,
      otherUserName: widget.otherUser.name,
      isVideo: widget.isVideo,
      durationSeconds: _secs,
      isMissed: _secs < 3,
    );
    await _engine.leaveChannel();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildRemoteView(),
          if (widget.isVideo && _localJoined) _buildLocalPreview(),
          _buildTopInfo(),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildControls()),
        ],
      ),
    );
  }

  Widget _buildRemoteView() {
    if (!widget.isVideo) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xFF1A0A0F), Color(0xFF2D0A1A)]),
        ),
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircleAvatar(radius: 70, backgroundImage: NetworkImage(AvatarUtils.getAvatarUrl(widget.otherUser.name))),
          const SizedBox(height: 20),
          Text(widget.otherUser.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          _statusLabel(),
        ])),
      );
    }
    if (_remoteJoined && _remoteUid != null) {
      final sorted = [_myUid, widget.otherUser.uid]..sort();
      return SizedBox.expand(
        child: AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: _remoteUid),
            connection: RtcConnection(channelId: sorted.join('_')),
          ),
        ),
      );
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A0F), Color(0xFF2D0A1A)]),
      ),
      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircleAvatar(radius: 60, backgroundImage: NetworkImage(AvatarUtils.getAvatarUrl(widget.otherUser.name))),
        const SizedBox(height: 20),
        Text(widget.otherUser.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        _statusLabel(),
      ])),
    );
  }

  Widget _statusLabel() {
    if (_remoteJoined) return Text(_timerLabel, style: const TextStyle(fontSize: 18, color: Colors.white70, letterSpacing: 1));
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54)),
      const SizedBox(width: 10),
      Text(widget.isOutgoing ? 'Calling…' : 'Connecting…', style: const TextStyle(fontSize: 16, color: Colors.white70)),
    ]);
  }

  Widget _buildLocalPreview() {
    return Positioned(
      top: 80, right: 16,
      child: Container(
        width: 110, height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white30, width: 1.5),
        ),
        clipBehavior: Clip.hardEdge,
        child: _videoOff
            ? Container(color: Colors.grey.shade900,
                child: const Center(child: Icon(Icons.videocam_off, color: Colors.white54, size: 28)))
            : AgoraVideoView(controller: VideoViewController(
                rtcEngine: _engine, canvas: const VideoCanvas(uid: 0))),
      ),
    );
  }

  Widget _buildTopInfo() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent]),
        ),
        child: Row(children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          ),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(widget.otherUser.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            if (_remoteJoined) Text(_timerLabel, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ])),
          const SizedBox(width: 48),
        ]),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).padding.bottom + 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.85), Colors.transparent]),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _ctrlBtn(icon: _muted ? Icons.mic_off : Icons.mic, label: _muted ? 'Unmute' : 'Mute',
              active: _muted, onTap: () async { _muted = !_muted; await _engine.muteLocalAudioStream(_muted); setState(() {}); }),
          if (widget.isVideo)
            _ctrlBtn(icon: _videoOff ? Icons.videocam_off : Icons.videocam, label: _videoOff ? 'Start Video' : 'Stop Video',
                active: _videoOff, onTap: () async { _videoOff = !_videoOff; await _engine.muteLocalVideoStream(_videoOff); setState(() {}); }),
          _ctrlBtn(icon: _speakerOn ? Icons.volume_up : Icons.volume_off, label: _speakerOn ? 'Speaker' : 'Earpiece',
              active: !_speakerOn, onTap: () async { _speakerOn = !_speakerOn; await _engine.setEnableSpeakerphone(_speakerOn); setState(() {}); }),
          if (widget.isVideo)
            _ctrlBtn(icon: Icons.flip_camera_ios, label: 'Flip', active: false,
                onTap: () async { _frontCam = !_frontCam; await _engine.switchCamera(); setState(() {}); }),
        ]),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: _endCall,
          child: Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: Colors.redAccent, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.red, blurRadius: 16, spreadRadius: 2)],
            ),
            child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 32),
          ),
        ),
      ]),
    );
  }

  Widget _ctrlBtn({required IconData icon, required String label, required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: active ? AppColors.primaryPink : Colors.white, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ]),
    );
  }
}
