import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // ستحتاجين لإضافة intl في pubspec.yaml لتنسيق الوقت
import 'package:tracing_app_new/core/theming/app_styles.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // لإظهار الـ AppBar بشكل شفاف فوق التدرج اللوني
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("التنبيهات", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: AppStyles.primaryGradientDecoration,
        child: StreamBuilder<QuerySnapshot>(
          // جلب التنبيهات الموجهة لهذا المستخدم فقط
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .where('receiverId', isEqualTo: currentUserId)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "لا توجد تنبيهات حالياً",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            final notifications = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.only(top: 100, left: 15, right: 15),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final data = notifications[index].data() as Map<String, dynamic>;
                
                return _buildNotificationItem(data, notifications[index].id);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> data, String docId) {
    // تنسيق الوقت
    String time = "";
    if (data['timestamp'] != null) {
      time = DateFormat('hh:mm a').format((data['timestamp'] as Timestamp).toDate());
    }

    return Dismissible(
      key: Key(docId),
      onDismissed: (direction) {
        FirebaseFirestore.instance.collection('notifications').doc(docId).delete();
      },
      background: Container(
        color: Colors.red.withOpacity(0.3),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        color: Colors.white.withOpacity(0.15), // كرت شفاف يتماشى مع التدرج
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getIconColor(data['type']),
            child: Icon(_getIcon(data['type']), color: Colors.white),
          ),
          title: Text(
            data['title'] ?? "تنبيه جديد",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            data['body'] ?? "",
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: Text(
            time,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'call': return Icons.call_missed;
      case 'location': return Icons.location_on;
      case 'battery': return Icons.battery_alert;
      default: return Icons.notifications;
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case 'call': return Colors.redAccent;
      case 'location': return Colors.orangeAccent;
      case 'battery': return Colors.amber;
      default: return Colors.blueAccent;
    }
  }
}