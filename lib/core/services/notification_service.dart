import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/call_cubit.dart';
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/incoming_call_overlay.dart';
import 'package:tracing_app_new/main.dart'; 

class NotificationService {
  
  // 1. تهيئة المكتبة مع إعدادات الرنين العالية
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/res_app_icon', // تأكدي من وجود أيقونة بهذا الاسم في android/app/src/main/res/drawable
      [
        NotificationChannel(
          channelKey: 'call_channel',
          channelName: 'المكالمات الواردة',
          channelDescription: 'قناة مخصصة لتنبيهات المكالمات المرئية والصوتية',
          defaultColor: const Color(0xFF9D50BB),
          ledColor: Colors.white,
          importance: NotificationImportance.Max, // أعلى أهمية لإيقاظ الجهاز
          channelShowBadge: true,
          locked: true, // يمنع المسح اليدوي للإشعار أثناء الرنين
          defaultRingtoneType: DefaultRingtoneType.Ringtone, // تشغيل رنة الهاتف الافتراضية
          criticalAlerts: true,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        )
      ],
      debug: true,
    );

    // التحقق من الأذونات المطلوبة للرنين في الخلفية
    await _checkPermissions();

    // إعداد المستمعين للأزرار (رد / رفض)
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  static Future<void> _checkPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  // 2. معالجة الضغط على الأزرار (حتى والتطبيق مغلق تماماً)
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    final String? roomName = receivedAction.payload?['roomName'];
    final String? callerName = receivedAction.payload?['callerName'];

    if (receivedAction.buttonKeyInput == 'ACCEPT') {
      if (roomName != null) {
        // ننتظر قليلاً لضمان بناء الـ Context إذا كان التطبيق يفتح من الصفر
        Future.delayed(const Duration(milliseconds: 500), () {
          navigatorKey.currentContext?.read<CallCubit>().joinIncomingCall(
            roomName: roomName,
            userName: "StudentDevice", 
          );
          
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/callScreen',
            (route) => route.isFirst,
            arguments: {
              'roomName': roomName,
              'callerName': callerName ?? 'متصل',
            },
          );
        });
      }
    } else if (receivedAction.buttonKeyInput == 'REJECT') {
      final String? callerId = receivedAction.payload?['callerId'];
      if (callerId != null) {
        FirebaseFirestore.instance.collection('calls').doc(callerId).update({'status': 'declined'});
      }
    }
  }

  // 3. مستمعي FCM
  static void initializeFcmListeners() {
    // في الواجهة (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == 'incoming_call') {
        showCallNotification(message);
      }
    });

    // عند النقر على الإشعار من الخلفية
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['type'] == 'incoming_call') {
        _handleNavigation(message.data);
      }
    });
  }

  // 4. إظهار إشعار المكالمة الذي يفتح الشاشة تلقائياً
  static Future<void> showCallNotification(RemoteMessage message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'call_channel',
        title: 'مكالمة من ${message.data['callerName']}',
        body: 'لديك مكالمة فيديو واردة...',
        category: NotificationCategory.Call, // يحول الإشعار لنظام مكالمة
        fullScreenIntent: true, // هنا مكانه الصحيح! ✅
        wakeUpScreen: true, // يضيء الشاشة
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
          actionType: ActionType.Default,
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

  // 5. مراقبة Firestore للمكالمات (عندما يكون التطبيق مفتوحاً)
  static void listenForIncomingCalls(String myUid) {
    FirebaseFirestore.instance.collection('calls').doc(myUid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['status'] == 'ringing') {
          // إذا كان التطبيق مفتوحاً، نظهر الـ Overlay الداخلي
          _showIncomingCallDialog(data, myUid);
        }
      }
    });
  }

  static void _showIncomingCallDialog(Map<String, dynamic> data, String myUid) {
    // التحقق من عدم وجود Dialog مفتوح بالفعل
    if (navigatorKey.currentContext == null) return;

    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) => IncomingCallOverlay(
        callerName: data['callerName'] ?? "متصل",
        roomName: data['roomName'] ?? "",
        isVideo: data['isVideo'] ?? true,
        parentUid: data['callerId'],
        onAccept: () async {
          Navigator.pop(context);
          await FirebaseFirestore.instance.collection('calls').doc(myUid).update({'status': 'accepted'});
          _handleNavigation(data);
        },
        onDecline: () async {
          Navigator.pop(context);
          await FirebaseFirestore.instance.collection('calls').doc(myUid).update({'status': 'declined'});
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
}