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

    // مراقبة حالة المكالمة: إذا قام المتصل بإغلاق الخط قبل الرد
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
          .collection('calls')
          .doc(myUid)
          .snapshots()
          .listen((snapshot) {
        // إذا حُذف المستند أو تغيرت الحالة لـ "cancelled"
        if ((!snapshot.exists || snapshot.data()?['status'] == 'cancelled') && mounted) {
          debugPrint("المتصل أنهى المحاولة، إغلاق الشاشة...");
          _stopAll();
          Navigator.of(context).pop(); 
        }
      });
    }
  }

  void _stopAll() {
    _audioPlayer.stop();
    _missedCallTimer?.cancel();
    _callStreamSubscription?.cancel();
  }

  Future<void> _logMissedCallToBoth() async {
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
    } catch (e) {
      debugPrint("خطأ في تسجيل المكالمة الفائتة: $e");
    }
  }

  Future<void> _playRingtone() async {
    try {
      // تأكد من وجود الملف في assets/ring.mp3
      await _audioPlayer.setSource(AssetSource('ring.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint("Error playing ringtone: $e");
    }
  }

  @override
  void dispose() {
    _stopAll();
    _audioPlayer.dispose();
    super.dispose();
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
            // أيقونة المستخدم مع تأثير بسيط (يمكنك استبدالها بصورة المتصل)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: const Icon(Icons.person, size: 100, color: Colors.white),
            ),
            const SizedBox(height: 30),
            Text(
              widget.callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.isVideo ? "مكالمة فيديو واردة..." : "مكالمة صوتية واردة...",
              style: const TextStyle(color: Colors.greenAccent, fontSize: 18, letterSpacing: 1.2),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // زر الرفض
                  _buildCallButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    label: "رفض",
                    onTap: () {
                      _stopAll();
                      widget.onDecline();
                    },
                  ),
                  // زر القبول
                  _buildCallButton(
                    icon: widget.isVideo ? Icons.videocam : Icons.call,
                    color: Colors.green,
                    label: "رد",
                    onTap: () {
                      _stopAll();
                      widget.onAccept();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 75,
            width: 75,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 35),
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }
}