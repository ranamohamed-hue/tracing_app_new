
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/feature/parent/logic/chat_state.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitialize());

  Future<void> launchChatGpt() async {
    final url = Uri.parse('https://chat.openai.com');
    emit(ChatLoading()); 

    try {
      if (await launchUrl(url)) {
        emit(ChatSuccess());
      } else {
        emit(const ChatError('لا يمكن فتح الرابط')); 
      }
    } catch (e) {
      emit(ChatError('حدث خطأ غير متوقع: ${e.toString()}')); 
    }
  }
}
