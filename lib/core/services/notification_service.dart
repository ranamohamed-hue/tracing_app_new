import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/incoming_call_overlay.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_call_channel',
      'Incoming Calls',
      description: 'This channel is used for incoming call notifications.',
      importance: Importance.max, // رفع الأهمية للقصوى
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const InitializationSettings initSettings = InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {},
    );
  }

  // === دالة مراقبة المكالمات وتفعيل شاشة الاستقبال ===
  static void listenForIncomingCalls(BuildContext context, String myUid) {
    FirebaseFirestore.instance
        .collection('calls')
        .doc(myUid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        
        // التحقق من حالة الرنين
        if (data != null && data['status'] == 'ringing') {
          
          // استخدام Navigator من خلال الـ context بحذر
          showDialog(
            context: context,
            barrierDismissible: false, 
            builder: (dialogContext) => IncomingCallOverlay(
              callerName: data['callerName'] ?? "متصل غير معروف",
              isVideo: data['isVideo'] ?? true,
              onAccept: () {
                // 1. استخراج البيانات قبل إغلاق الديالوج
                final String? roomName = data['roomName'];
                final String? caller = data['callerName'];

                // 2. إغلاق شاشة التنبيه باستخدام الـ dialogContext
                Navigator.of(dialogContext).pop(); 
                
                // 3. تحديث الحالة في Firestore
                FirebaseFirestore.instance.collection('calls').doc(myUid).update({
                  'status': 'accepted',
                });

                // 4. الانتقال لصفحة Jitsi Meet المبرمجة في Routes بالـ main
                if (roomName != null) {
                  Navigator.pushNamed(context, '/callScreen', arguments: {
                    'roomName': roomName,
                    'callerName': caller,
                  });
                }
              },
              onDecline: () {
                Navigator.of(dialogContext).pop(); 
                
                // حفظ مكالمة فائتة
                _saveMissedCallNotification(myUid, data['callerName'] ?? "متصل");

                // حذف السجل لإنهاء الاتصال
                FirebaseFirestore.instance.collection('calls').doc(myUid).delete();
              },
            ),
          );
        }
      }
    });
  }

  static void _saveMissedCallNotification(String myUid, String callerName) {
    FirebaseFirestore.instance.collection('notifications').add({
      'receiverId': myUid,
      'title': 'مكالمة فائتة',
      'body': 'لديك مكالمة فائتة من $callerName',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'call',
    });
  }
}