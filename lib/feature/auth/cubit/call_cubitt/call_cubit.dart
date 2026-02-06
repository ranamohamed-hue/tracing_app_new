import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';
import 'package:tracing_app_new/feature/auth/data/repo/call_repo.dart' hide MeetingStatus; 
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/call_state.dart';

class CallCubit extends Cubit<CallState> {
  final CallRepo _callRepo;
  
  CallCubit(this._callRepo) : super(const CallState());

  Future<void> startMeeting({
    required UserModel currentUser, 
    required bool isVideoCall,
    required String calleeId, 
  }) async {
    emit(state.copyWith(status: MeetingStatus.connecting));

    String roomName = (currentUser.userType.contains('ولي') || currentUser.userType.contains('parent')) 
        ? "room_${currentUser.uid}" 
        : "room_${currentUser.parentUid}";

    try {
      await FirebaseFirestore.instance.collection('calls').doc(calleeId).set({
        'callerName': currentUser.username,
        'callerId': currentUser.uid,
        'roomName': roomName,
        'status': 'ringing',
        'type': isVideoCall ? 'video' : 'voice',
        'isVideo': isVideoCall,
        'timestamp': FieldValue.serverTimestamp(),
      });

      final options = JitsiMeetConferenceOptions(
        serverURL: "https://meet.jit.si",
        room: roomName,
        configOverrides: {
          "prejoinPageEnabled": false,
          "lobbyModeEnabled": false,
          "startWithVideoMuted": !isVideoCall,
          "startWithAudioMuted": false,
        },
        featureFlags: {
          // ✅ السطور التالية تمنع التحويل لمتجر التطبيقات أو المتصفح
          "welcomePage.enabled": false,        // منع صفحة الترحيب
          "prejoinPageEnabled": false,        // منع شاشة ما قبل الانضمام
          "isWebviewEnabled": true,           // إجبار التشغيل كـ WebView داخلي
          "nativeWelcomePage.enabled": false,  // تعطيل صفحة الترحيب الأصلية لـ Jitsi
          "conference.enabled": true,
          "unwelcome.enabled": false,
          "resolution": 360,
          "pip.enabled": true,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: currentUser.username,
          email: currentUser.email,
        ),
      );

      var jitsiMeet = JitsiMeet();
      await jitsiMeet.join(options);
      
      emit(state.copyWith(status: MeetingStatus.success));
      
    } catch (e) {
      emit(state.copyWith(status: MeetingStatus.error));
      print("Error starting meeting: $e");
    }
  }

  Future<void> endCall(String calleeId) async {
    try {
      await FirebaseFirestore.instance.collection('calls').doc(calleeId).delete();
      emit(state.copyWith(status: MeetingStatus.idle));
    } catch (e) {
      print("Error ending call: $e");
    }
  }
}