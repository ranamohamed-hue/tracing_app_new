
import 'package:flutter/material.dart';

class LinkChildDialog extends StatelessWidget {
  // دالة رد النداء (Callback) التي سيتم استدعاؤها عند إرسال الكود
  final Function(String) onLinkSubmitted;

  const LinkChildDialog({
    super.key,
    required this.onLinkSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

    return AlertDialog(
      title: const Text('ربط طفل جديد'),
      content: TextField(
        controller: codeController,
        decoration: const InputDecoration(
          hintText: 'أدخل كود الدعوة',
          border: OutlineInputBorder(),
        ),
        textAlign: TextAlign.center,
        autofocus: true, // تلقائياً يضع المؤشر في حقل النص عند فتح الـ Dialog
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            final code = codeController.text.trim();
            if (code.isNotEmpty) {
              // استدعاء دالة رد النداء وتمرير الكود المدخل
              onLinkSubmitted(code);
              Navigator.pop(context); // إغلاق الـ Dialog
            }
          },
          child: const Text('ربط'),
        ),
      ],
    );
  }
}