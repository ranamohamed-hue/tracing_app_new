import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class IncomingCallOverlay extends StatefulWidget {
  final String callerName;
  final String roomName;
  final bool isVideo;
  final String? parentUid; 
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingCallOverlay({
    super.key,
    required this.callerName,
    required this.roomName,
    required this.isVideo,
    this.parentUid,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<IncomingCallOverlay> createState() => _IncomingCallOverlayState();
}

class _IncomingCallOverlayState extends State<IncomingCallOverlay> {
  late AudioPlayer _audioPlayer;
  Timer? _missedCallTimer;
  StreamSubscription? _callStreamSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playRingtone();
    _listenToCallStatus();

    // مهلة الرد (45 ثانية)
    _missedCallTimer = Timer(const Duration(seconds: 45), () async {
      await _logMissedCallToBoth();
      if (mounted) {
        _stopAll();
        widget.onDecline();
      }
    });
  }

  void _listenToCallStatus() {
    final String? myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid != null) {
      _callStreamSubscription = FirebaseFirestore.instance
          .collection('calls').doc(myUid).snapshots().listen((snapshot) {
        if ((!snapshot.exists || snapshot.data()?['status'] == 'cancelled') && mounted) {
          _stopAll();
          Navigator.of(context).pop(); 
        }
      });
    }
  }

  Future<void> _updateCallStatus(String status) async {
    final String? myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid != null) {
      await FirebaseFirestore.instance.collection('calls').doc(myUid).update({'status': status});
    }
  }

  void _stopAll() {
    _audioPlayer.stop();
    _missedCallTimer?.cancel();
    _callStreamSubscription?.cancel();
  }Future<void> _logMissedCallToBoth() async {
    try {
      final String? studentId = FirebaseAuth.instance.currentUser?.uid;
      final batch = FirebaseFirestore.instance.batch();

      if (studentId != null) {
        final stRef = FirebaseFirestore.instance.collection('notifications').doc();
        batch.set(stRef, {
          'receiverId': studentId,
          'title': 'مكالمة فائتة',
          'body': 'لديك مكالمة فائتة من ${widget.callerName}',
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'call',
        });
      }

      if (widget.parentUid != null) {
        final paRef = FirebaseFirestore.instance.collection('notifications').doc();
        batch.set(paRef, {
          'receiverId': widget.parentUid,
          'title': 'لم يتم الرد',
          'body': 'الابن لم يرد على مكالمتك',
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'call',
        });
      }
      await batch.commit();
    } catch (e) { debugPrint("خطأ في تسجيل المكالمة: $e"); }
  }

  Future<void> _playRingtone() async {
    try {
      await _audioPlayer.setSource(AssetSource('ring.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.resume();
    } catch (e) { debugPrint("Audio Error: $e"); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.black],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            CircleAvatar(radius: 60, backgroundColor: Colors.white10, child: Icon(Icons.person, size: 80, color: Colors.white)),
            const SizedBox(height: 30),
            Text(widget.callerName, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            Text(widget.isVideo ? "مكالمة فيديو واردة..." : "مكالمة صوتية واردة...", style: const TextStyle(color: Colors.greenAccent, fontSize: 18)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCallButton(Icons.call_end, Colors.red, "رفض", () async {
                  _stopAll();
                  await _updateCallStatus('declined');
                  widget.onDecline();
                }),
                _buildCallButton(widget.isVideo ? Icons.videocam : Icons.call, Colors.green, "رد", () async {
                  _stopAll();
                  await _updateCallStatus('accepted');
                  widget.onAccept();
                }),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton(IconData icon, Color color, String label, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 75, width: 75,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 20)]),
            child: Icon(icon, color: Colors.white, size: 35),
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}