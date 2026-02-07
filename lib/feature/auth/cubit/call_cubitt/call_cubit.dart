import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/call_state.dart';
import 'package:tracing_app_new/feature/auth/data/repo/call_repo_impl.dart'; // تأكدي من صحة المسار

class CallCubit extends Cubit<CallState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final CallRepoImpl _callRepo; // تم الربط مع المستودع بنجاح

  Timer? _callTimer;
  StreamSubscription<DocumentSnapshot>? _callStreamSubscription; 

  // مفتاح FCM - يفضل لاحقاً نقله لملف إعدادات آمن
  final String _fcmServerKey = "YOUR_SERVER_KEY_HERE";

  // المنشئ الوحيد والمطلوب
  CallCubit(this._callRepo) : super(const CallState());

  // === 1. دالة بدء المكالمة ===
  Future<void> startMeeting({
    required UserModel currentUser, 
    required bool isVideoCall,
    required String calleeId, 
  }) async {
    emit(state.copyWith(status: MeetingStatus.connecting));

    _playCallingTone();

    // اسم الغرفة الموحد بناءً على معرف الطالب
    String roomName = "room_$calleeId";

    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(calleeId).get();
      String? studentToken = userDoc.data()?['fcmToken'];

      await FirebaseFirestore.instance.collection('calls').doc(calleeId).set({
        'callerName': currentUser.username,
        'callerId': currentUser.uid,
        'roomName': roomName,
        'status': 'ringing',
        'type': isVideoCall ? 'video' : 'voice',
        'isVideo': isVideoCall,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _listenToCallStatus(calleeId);

      if (studentToken != null) {
        await _sendNotificationToStudent(
          token: studentToken,
          callerName: currentUser.username,
          roomName: roomName,
          callerId: currentUser.uid,
        );
      }

      await _joinJitsiRoom(roomName, currentUser.username, currentUser.email, isVideoCall, calleeId);
      emit(state.copyWith(status: MeetingStatus.success));
      
    } catch (e) {
      _cleanup(calleeId);
      emit(state.copyWith(status: MeetingStatus.error));
    }
  }

  // === 2. دالة الانضمام لمكالمة واردة ===
  Future<void> joinIncomingCall({
    required String roomName,
    required String userName,
    String? email,
  }) async {
    _stopCallingTone();
    emit(state.copyWith(status: MeetingStatus.connecting));
    
    try {
      await _joinJitsiRoom(roomName, userName, email ?? "", true, null);
      emit(state.copyWith(status: MeetingStatus.success));
    } catch (e) {
      emit(state.copyWith(status: MeetingStatus.error));
    }
  }

  // === دالة إعداد Jitsi ===
  Future<void> _joinJitsiRoom(String room, String name, String email, bool isVideo, String? calleeId) async {
    final options = JitsiMeetConferenceOptions(
      serverURL: "https://meet.ffmuc.net",
      room: room,
      configOverrides: {
        "prejoinPageEnabled": false,
        "lobbyModeEnabled": false,
        "startWithVideoMuted": !isVideo,
        "startWithAudioMuted": false,
      },
      featureFlags: {
        FeatureFlags.welcomePageEnabled: false,
        FeatureFlags.pipEnabled: true,
        FeatureFlags.callIntegrationEnabled: true,
      },
      userInfo: JitsiMeetUserInfo(displayName: name, email: email),
    );

    var listener = JitsiMeetEventListener(
      conferenceJoined: (url) {
        _stopCallingTone();
        if (calleeId != null) _startTimer(calleeId);
      },
      conferenceTerminated: (url, error) {
        if (calleeId != null) _cleanup(calleeId);
      },
    );

    await JitsiMeet().join(options, listener);
  }

  void _listenToCallStatus(String calleeId) {
    _callStreamSubscription?.cancel();
    _callStreamSubscription = FirebaseFirestore.instance
        .collection('calls')
        .doc(calleeId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final status = snapshot.data()?['status'];
        if (status == 'accepted') {
          _stopCallingTone();
        } else if (status == 'declined') {
          _stopCallingTone();
          JitsiMeet().hangUp();
          _cleanup(calleeId);
        }
      }
    });
  }

  Future<void> _sendNotificationToStudent({
    required String token,
    required String callerName,
    required String roomName,
    required String callerId,
  }) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_fcmServerKey',
        },
        body: jsonEncode({
          'priority': 'high',
          'data': {
            'type': 'incoming_call',
            'callerName': callerName,
            'roomName': roomName,
            'callerId': callerId,
            'status': 'ringing',
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
          'to': token,
        }),
      );
    } catch (e) { print("FCM Error: $e"); }
  }

  void _playCallingTone() async {
    try {
      await _audioPlayer.setSource(AssetSource('audio/phone_calling.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.resume();
    } catch (e) { print("Audio Error: $e"); }
  }

  void _stopCallingTone() => _audioPlayer.stop();

  void _startTimer(String calleeId) {
    _callTimer?.cancel();
    _callTimer = Timer(const Duration(minutes: 15), () {
      JitsiMeet().hangUp();
      _cleanup(calleeId);
    });
  }

  void _cleanup(String calleeId) {
    _callTimer?.cancel();
    _callStreamSubscription?.cancel(); 
    _stopCallingTone();
    endCall(calleeId);
  }

  Future<void> endCall(String calleeId) async {
    try {
      await FirebaseFirestore.instance.collection('calls').doc(calleeId).delete();
      emit(state.copyWith(status: MeetingStatus.idle));
    } catch (e) { print("Error ending call: $e"); }
  }

  @override
  Future<void> close() {
    _callTimer?.cancel();
    _callStreamSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}