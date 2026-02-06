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

    // ✅ توحيد منطق اسم الغرفة (ثابت ومستقر)
    String roomName = (currentUser.userType.contains('ولي') || currentUser.userType.contains('parent')) 
        ? "room_${currentUser.uid}" 
        : "room_${currentUser.parentUid}";

    try {
      // 1. تحديث بيانات المكالمة في فايربيس للطرف الآخر
      await FirebaseFirestore.instance.collection('calls').doc(calleeId).set({
        'callerName': currentUser.username,
        'callerId': currentUser.uid,
        'roomName': roomName,
        'status': 'ringing',
        'type': isVideoCall ? 'video' : 'voice',
        'isVideo': isVideoCall,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. إعداد خيارات Jitsi (بنفس إعدادات الـ main لضمان التطابق)
      final options = JitsiMeetConferenceOptions(
        serverURL:"https://meet.ffmuc.net",
        room: roomName,
        configOverrides: {
          "prejoinPageEnabled": false,
          "lobbyModeEnabled": false,
          "disableDeepLinking": true, // ✅ يمنع فتح المتصفح عند المتصل
          "startWithVideoMuted": !isVideoCall,
          "startWithAudioMuted": false,
        },
        featureFlags: {
          FeatureFlags.welcomePageEnabled: false,
          FeatureFlags.preJoinPageEnabled: false,
          FeatureFlags.unsafeRoomWarningEnabled: false, 
          FeatureFlags.resolution: FeatureFlagVideoResolutions.resolution360p,
          FeatureFlags.pipEnabled: true,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: currentUser.username,
          email: currentUser.email,
        ),
      );

      // 3. إضافة المستمع (السر اللي بيخليها Native)
      var jitsiMeet = JitsiMeet();
      var listener = JitsiMeetEventListener(
        conferenceJoined: (url) => print("بدأت المكالمة كـ مرسل: $url"),
        conferenceTerminated: (url, error) {
           print("انتهت المكالمة: $error");
           endCall(calleeId); // تنظيف الداتابيز لما يقفل
        },
      );

      await jitsiMeet.join(options, listener);
      
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