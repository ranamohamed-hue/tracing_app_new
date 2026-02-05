import 'package:equatable/equatable.dart';
import 'package:tracing_app_new/feature/auth/data/repo/call_repo.dart';

class CallState extends Equatable {
  final MeetingStatus status;
  final String? errorMessage;
  final List<Map<String, String>> participants; // قائمة المشاركين الحاليين

  const CallState({
    this.status = MeetingStatus.idle,
    this.errorMessage,
    this.participants = const [],
  });

  // دالة لإنشاء نسخة جديدة من الحالة مع تغيير قيم معينة
  CallState copyWith({
    MeetingStatus? status,
    String? errorMessage,
    List<Map<String, String>>? participants,
  }) {
    return CallState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      participants: participants ?? this.participants,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, participants];
}