
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/feature/parent/logic/chat_state.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitialize());

  Future<void> launchChatGpt() async {
    final url = Uri.parse('https://chat.openai.com');
    emit(ChatLoading()); // 1. حالة التحميل

    try {
      if (await launchUrl(url)) {
        emit(ChatSuccess()); // 2. حالة النجاح
      } else {
        emit(const ChatError('لا يمكن فتح الرابط')); // 2. حالة الخطأ
      }
    } catch (e) {
      emit(ChatError('حدث خطأ غير متوقع: ${e.toString()}')); // 2. حالة الخطأ
    }
  }
}
