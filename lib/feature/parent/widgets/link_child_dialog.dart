import 'package:flutter/material.dart';

class LinkChildDialog extends StatefulWidget {
  final Function(String) onLinkSubmitted;

  const LinkChildDialog({super.key, required this.onLinkSubmitted});

  @override
  State<LinkChildDialog> createState() => _LinkChildDialogState();
}

class _LinkChildDialogState extends State<LinkChildDialog> {
  // 1. قم بتعريف الـ Controller هنا كمتغير في الـ State
  final TextEditingController codeController = TextEditingController();

  // 2. قم بتنظيف الـ Controller عند إغلاق الـ Dialog لتجنب تسرب الذاكرة
  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // لا تنشئ الـ Controller هنا مرة أخرى
    return AlertDialog(
      title: const Text('ربط طفل جديد'),
      content: TextField(
        controller: codeController, // استخدم الـ Controller الذي عرفته أعلاه
        decoration: const InputDecoration(
          hintText: 'أدخل كود الدعوة',
          border: OutlineInputBorder(),
        ),
        textAlign: TextAlign.center,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            final code = codeController.text.trim();
            if (code.isNotEmpty) {
              widget.onLinkSubmitted(code);
              Navigator.pop(context);
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('ربط'),
        ),
      ],
    );
  }
}