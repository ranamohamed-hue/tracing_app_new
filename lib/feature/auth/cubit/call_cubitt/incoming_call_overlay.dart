import 'package:flutter/material.dart';

class IncomingCallOverlay extends StatelessWidget {
  final String callerName;
  final String roomName; // ✅ تمت إضافة اسم الغرفة هنا
  final bool isVideo;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingCallOverlay({
    super.key,
    required this.callerName,
    required this.roomName, // ✅ استلام اسم الغرفة في الـ Constructor
    required this.isVideo,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // قسم هوية المتصل
            Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blueGrey.shade800,
                  child: Icon(
                    isVideo ? Icons.video_camera_back : Icons.person,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isVideo ? "مكالمة فيديو واردة..." : "مكالمة صوتية واردة...",
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 18),
                ),
                // اختياري: إظهار اسم الغرفة للتأكد أثناء البرمجة (يمكنك حذفه لاحقاً)
                const SizedBox(height: 5),
                Text(
                  "Room ID: $roomName",
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ],
            ),

            // أزرار التحكم
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // زر الرفض
                _buildCallButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  label: "رفض",
                  onTap: onDecline,
                ),
                // زر الرد
                _buildCallButton(
                  icon: isVideo ? Icons.videocam : Icons.call,
                  color: Colors.green,
                  label: "رد",
                  onTap: onAccept, // سينفذ الكود الموجود في الـ routes في main.dart
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 35),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }
}