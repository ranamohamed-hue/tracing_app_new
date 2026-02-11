import 'package:equatable/equatable.dart';

enum MeetingStatus { 
  idle,       // الحالة الابتدائية
  connecting, // جاري الاتصال
  success,    // نجاح الاتصال
  error       // حالة الخطأ (هذه هي التي كانت ناقصة وتسبب اللون الأحمر)
}

class CallState extends Equatable {
  final MeetingStatus status;
  final String? errorMessage;
  final List<Map<String, String>> participants; 

  const CallState({
    this.status = MeetingStatus.idle,
    this.errorMessage,
    this.participants = const [],
  });

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