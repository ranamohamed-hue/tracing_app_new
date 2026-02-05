import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:tracing_app_new/feature/auth/cubit/call_cubitt/call_state.dart'; // تأكد من المسار
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';
import 'package:tracing_app_new/feature/auth/data/repo/call_repo.dart';

class CallCubit extends Cubit<CallState> {
  final CallRepo _callRepo;
  
  // نحتفظ بالاشتراكات في الـ Streams هنا لنتمكن من إلغائها لاحقًا
  StreamSubscription? _statusSubscription;
  StreamSubscription? _participantJoinedSubscription;
  StreamSubscription? _participantLeftSubscription;

  CallCubit(this._callRepo) : super(const CallState()) {
    // عند إنشاء الـ Cubit، نبدأ في الاستماع للأحداث
    _subscribeToCallEvents();
  }

  void _subscribeToCallEvents() {
    // 1. الاستماع لحالة المكالمة (يتصل، انضم، انتهت)
    _statusSubscription = _callRepo.meetingStatusStream.listen((status) {
      emit(state.copyWith(status: status));
    });

    // 2. الاستلام لانضمام مشاركين جدد
    _participantJoinedSubscription = _callRepo.participantJoinedStream.listen((participant) {
      final updatedParticipants = List<Map<String, String>>.from(state.participants)
        ..add(participant);
      emit(state.copyWith(participants: updatedParticipants));
    });

    // 3. الاستماع لمغادرة المشاركين
    _participantLeftSubscription = _callRepo.participantLeftStream.listen((participantId) {
      final updatedParticipants = List<Map<String, String>>.from(state.participants);
      // نبحث عن المشارك باستخدام الـ ID الفريد ونزيله من القائمة
      updatedParticipants.removeWhere((participant) => participant['id'] == participantId);
      emit(state.copyWith(participants: updatedParticipants));
    });
  }

  // دالة لبدء مكالمة جديدة
 Future<void> startMeeting({
    required UserModel currentUser, 
    required bool isVideoCall, // === الإضافة الجديدة ===
  }) async {
    emit(state.copyWith(status: MeetingStatus.connecting, errorMessage: null));

    String roomName = (currentUser.userType == 'ولي أمر') 
        ? "family_${currentUser.uid}" 
        : "family_${currentUser.parentUid}";

    final options = JitsiMeetConferenceOptions(
      serverURL: "https://meet.jit.si",
      room: roomName,
      configOverrides: {
        "startWithAudioMuted": false,
        // === التعديل هنا ===
        // لو المكالمة صوتية، نبدأ والفيديو مغلق. لو فيديو، نبدأ والفيديو مفتوح.
        "startWithVideoMuted": !isVideoCall, 
        // ====================
        "subject": isVideoCall ? "مكالمة فيديو أمان العائلة" : "مكالمة صوتية أمان العائلة",
      },
      featureFlags: {
        "unwelcome_page_enabled": false,
        "prejoinPageEnabled": false,
        "isPipEnabled": true,
      },
      userInfo: JitsiMeetUserInfo(
        displayName: currentUser.username,
        email: currentUser.email,
      ),
    );

    final result = await _callRepo.joinMeeting(options: options);
    
    result.fold(
      (error) => emit(state.copyWith(
        errorMessage: error, 
        status: MeetingStatus.terminated
      )),
      (_) => null,
    );
  }

  // ... باقي الكود ...


  // دالة لإنهاء المكالمة
  Future<void> endCall() async {
    await _callRepo.leaveMeeting();
  }

  // دالة حيوية جدًا لتنظيف الموارد عند إغلاق الـ Cubit
  @override
  Future<void> close() {
    // إلغاء جميع الاشتراكات في الـ Streams
    _statusSubscription?.cancel();
    _participantJoinedSubscription?.cancel();
    _participantLeftSubscription?.cancel();
    
    // تنظيف الـ Repo وإزالة الـ Listeners نهائيًا
    _callRepo.dispose();
    
    return super.close();
  }
}