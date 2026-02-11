import 'package:dartz/dartz.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

enum MeetingStatus { idle, connecting, joined, terminated }

abstract class CallRepo {
  Future<Either<String, void>> joinMeeting({
    required JitsiMeetConferenceOptions options, 
  });

  Future<Either<String, void>> leaveMeeting();
  
  Stream<MeetingStatus> get meetingStatusStream;
  Stream<Map<String, String>> get participantJoinedStream;
  Stream<String> get participantLeftStream;

  Future<Either<String, void>> toggleAudio(bool muted);
  Future<Either<String, void>> toggleVideo(bool muted);

  void dispose();
}