import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:tracing_app_new/feature/auth/data/repo/call_repo.dart';

class CallRepoImpl implements CallRepo {
  final JitsiMeet _jitsiMeet = JitsiMeet();

  final _meetingStatusController = StreamController<MeetingStatus>.broadcast();
  final _participantJoinedController = StreamController<Map<String, String>>.broadcast();
  final _participantLeftController = StreamController<String>.broadcast();

  @override
  Stream<MeetingStatus> get meetingStatusStream => _meetingStatusController.stream;
  
  @override
  Stream<Map<String, String>> get participantJoinedStream => _participantJoinedController.stream;

  @override
  Stream<String> get participantLeftStream => _participantLeftController.stream;

  @override
  Future<Either<String, void>> joinMeeting({
    required JitsiMeetConferenceOptions options,
  }) async {
    try {
      await _jitsiMeet.join(
        options,
        JitsiMeetEventListener(
          conferenceJoined: (url) {
            _meetingStatusController.add(MeetingStatus.joined);
          },
          conferenceTerminated: (url, error) {
            _meetingStatusController.add(MeetingStatus.terminated);
          },
          conferenceWillJoin: (url) {
            _meetingStatusController.add(MeetingStatus.connecting);
          },
          participantJoined: (email, name, role, participantId) {
            _participantJoinedController.add({
              'email': email ?? '',
              'name': name ?? '',
              'id': participantId ?? ''
            });
          },
          participantLeft: (participantId) {
            _participantLeftController.add(participantId ?? '');
          },
        ),
      );
      return const Right(null);
    } catch (e) {
      _meetingStatusController.add(MeetingStatus.terminated);
      return Left("Error: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, void>> leaveMeeting() async {
    try {
      await _jitsiMeet.hangUp(); 
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> toggleAudio(bool muted) async {
    await _jitsiMeet.setAudioMuted(muted);
    return const Right(null);
  }
  
  @override
  Future<Either<String, void>> toggleVideo(bool muted) async {
    await _jitsiMeet.setVideoMuted(muted);
    return const Right(null);
  }

  @override
  void dispose() {
    _meetingStatusController.close();
    _participantJoinedController.close();
    _participantLeftController.close();
  }
}