import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ✅ استيراد المكتبة
import 'package:intl/intl.dart'; 
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
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: Text(
          "مركز التنبيهات", 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: 20.sp, // ✅ حجم خط العنوان مرن
          )
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white, size: 24.r), // ✅ حجم الأيقونة مرن
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: AppStyles.primaryGradientDecoration,
        child: StreamBuilder<QuerySnapshot>(
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
              return _buildEmptyState();
            }

            final notifications = snapshot.data!.docs;

            return ListView.builder(
              // ✅ تعديل الـ padding ليكون متوافقاً مع أحجام الشاشات المختلفة
              padding: EdgeInsets.only(
                top: 100.h, 
                left: 15.w, 
                right: 15.w, 
                bottom: 20.h
              ),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final doc = notifications[index];
                final data = doc.data() as Map<String, dynamic>;
                return _buildNotificationItem(data, doc.id);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined, size: 80.r, color: Colors.white54), // ✅ حجم مرن
          SizedBox(height: 15.h),
          Text(
            "صندوق التنبيهات فارغ حالياً",
            style: TextStyle(color: Colors.white70, fontSize: 18.sp), // ✅ نص مرن
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> data, String docId) {
    String time = "";
    if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
      time = DateFormat('hh:mm a').format((data['timestamp'] as Timestamp).toDate());
    } else {
      time = "الآن";
    }

    return Dismissible(
      key: Key(docId),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        FirebaseFirestore.instance.collection('notifications').doc(docId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("تم حذف التنبيه", style: TextStyle(fontSize: 14.sp)), 
            duration: const Duration(seconds: 1)
          ),
        );
      },
      background: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.7),
          borderRadius: BorderRadius.circular(15.r), // ✅ راديوس مرن
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 25.w),
        child: Icon(Icons.delete_sweep, color: Colors.white, size: 30.r),
      ),
      child: Card(
        color: Colors.white.withOpacity(0.12),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        margin: EdgeInsets.only(bottom: 12.h), // ✅ مسافة بين الكروت مرنة
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          leading: CircleAvatar(
            radius: 25.r, // ✅ حجم دائرة الأيقونة مرن
            backgroundColor: _getIconColor(data['type']).withOpacity(0.2),
            child: Icon(
              _getIcon(data['type']), 
              color: _getIconColor(data['type']), 
              size: 26.r // ✅ حجم الأيقونة مرن
            ),
          ),
          title: Text(
            data['title'] ?? "تنبيه جديد",
            style: TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold, 
              fontSize: 15.sp // ✅ عنوان الإشعار مرن
            ),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              data['body'] ?? "",
              style: TextStyle(color: Colors.white70, fontSize: 13.sp), // ✅ محتوى الإشعار مرن
            ),
          ),
          trailing: Text(
            time,
            style: TextStyle(color: Colors.white38, fontSize: 10.sp), // ✅ وقت الإشعار مرن
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'call': return Icons.phone_missed_rounded;
      case 'location': return Icons.location_on_rounded;
      case 'battery': return Icons.battery_alert_rounded;
      default: return Icons.notifications_active_rounded;
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case 'call': return Colors.redAccent;
      case 'location': return Colors.lightBlueAccent;
      case 'battery': return Colors.orangeAccent;
      default: return Colors.white;
    }
  }
}