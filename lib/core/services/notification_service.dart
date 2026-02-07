import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/call_cubit.dart'; // تأكد من المسار
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/incoming_call_overlay.dart';
import 'package:tracing_app_new/main.dart'; 

class NotificationService {
  
  // 1. تهيئة المكتبات
  static Future<void> initialize() async {
    // تهيئة Awesome Notifications
    await AwesomeNotifications().initialize(
      null, // يمكنك وضع مسار أيقونة التطبيق هنا
      [
        NotificationChannel(
          channelKey: 'call_channel',
          channelName: 'المكالمات الواردة',
          channelDescription: 'قناة مخصصة لتنبيهات المكالمات المرئية والصوتية',
          defaultColor: const Color(0xFF9D50BB),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          locked: true, // يمنع مسح الإشعار أثناء الرنين
          defaultRingtoneType: DefaultRingtoneType.Ringtone,
          criticalAlerts: true,
        )
      ],
      debug: true,
    );

    // طلب الإذن للإشعارات
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // إعداد المستمعين للأحداث (الضغط على الأزرار)
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  // 2. معالجة الضغط على أزرار الإشعار (رد / رفض)
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    final Map<String, String?>? payload = receivedAction.payload;
    final String? roomName = payload?['roomName'];
    final String? callerName = payload?['callerName'];
    final String? callerId = payload?['callerId'];

    if (receivedAction.buttonKeyInput == 'ACCEPT') {
      if (roomName != null) {
        // تحديث الـ Cubit فوراً لضمان الاتساق
        navigatorKey.currentContext?.read<CallCubit>().joinIncomingCall(
          roomName: roomName,
          userName: "User", // يفضل جلب الاسم الفعلي
        );
        
        // الانتقال لصفحة المكالمة
        navigatorKey.currentState?.pushNamed('/callScreen', arguments: {
          'roomName': roomName,
          'callerName': callerName ?? 'متصل',
        });
      }
    } else if (receivedAction.buttonKeyInput == 'REJECT') {
       // منطق الرفض وتحديث Firestore (سنحتاج الـ ID هنا)
       if (callerId != null) {
         FirebaseFirestore.instance.collection('calls').doc(callerId).update({'status': 'declined'});
       }
    }
  }

  // 3. مستمعي FCM (للخلفية والواجهة)
  static void initializeFcmListeners() {
    // عند استقبال رسالة والتطبيق في الواجهة
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == 'incoming_call') {
        showCallNotification(message);
      }
    });

    // عند الضغط على الإشعار والتطبيق في الخلفية
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['type'] == 'incoming_call') {
        _handleNavigation(message.data);
      }
    });
  }

  // 4. إظهار إشعار المكالمة الاحترافي
  static Future<void> showCallNotification(RemoteMessage message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'call_channel',
        title: 'مكالمة من ${message.data['callerName']}',
        body: 'لديك مكالمة مرئية واردة...',
        category: NotificationCategory.Call,
        wakeUpScreen: true,
        fullScreenIntent: true,
        autoDismissible: false,
        backgroundColor: Colors.white,
        payload: {
          'roomName': message.data['roomName'],
          'callerName': message.data['callerName'],
          'callerId': message.data['callerId'],
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'ACCEPT',
          label: 'رد',
          color: Colors.green,
          autoDismissible: true,
        ),
        NotificationActionButton(
          key: 'REJECT',
          label: 'رفض',
          color: Colors.red,
          autoDismissible: true,
          actionType: ActionType.DismissAction,
        ),
      ],
    );
  }

  // 5. دالة مراقبة Firestore (لإظهار الـ Overlay إذا كان التطبيق مفتوحاً)
  static void listenForIncomingCalls(String myUid) {
    FirebaseFirestore.instance.collection('calls').doc(myUid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['status'] == 'ringing') {
          _showIncomingCallDialog(data, myUid);
        }
      }
    });
  }

  static void _showIncomingCallDialog(Map<String, dynamic> data, String myUid) {
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (dialogContext) => IncomingCallOverlay(
        callerName: data['callerName'] ?? "متصل غير معروف",
        roomName: data['roomName'] ?? "",
        isVideo: data['isVideo'] ?? true,
        parentUid: data['callerId'],
        onAccept: () async {
          Navigator.of(dialogContext).pop();
          await FirebaseFirestore.instance.collection('calls').doc(myUid).update({'status': 'accepted'});
          
          // تأكيد اتساق اسم الغرفة في الـ Cubit
          navigatorKey.currentContext!.read<CallCubit>().joinIncomingCall(
            roomName: data['roomName'],
            userName: "User",
          );

          _handleNavigation(data);
        },
        onDecline: () async {
          Navigator.of(dialogContext).pop();
          await FirebaseFirestore.instance.collection('calls').doc(myUid).update({'status': 'declined'});
          _saveMissedCallNotification(myUid, data['callerName'] ?? "متصل");
        },
      ),
    );
  }

  static void _handleNavigation(Map<String, dynamic> data) {
    navigatorKey.currentState?.pushNamed(
      '/callScreen',
      arguments: {'roomName': data['roomName'], 'callerName': data['callerName']},
    );
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