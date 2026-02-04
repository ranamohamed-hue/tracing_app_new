import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracing_app_new/feature/auth/data/models/user_model.dart';
import 'package:tracing_app_new/feature/auth/cubit/child_tracing_cubit.dart'; // استيراد الكيوبت
import 'package:tracing_app_new/feature/parent/screens/child_tracing_page.dart'; // استيراد الصفحة
import 'package:tracing_app_new/feature/auth/data/repo/auth_repo.dart';

class HomePage extends StatelessWidget {
  final List<UserModel> children;

  const HomePage({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد أبناء مرتبطون حالياً.\nقم بإضافة طفل باستخدام كود الدعوة.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.child_care, color: Colors.blue),
            title: Text(child.username),
            subtitle: Text('نوع المستخدم: ${child.userType}'),
            trailing: const Icon(Icons.location_on, color: Colors.green),
            onTap: () {
              // *** التعديل الرئيسي: إضافة التنقل إلى صفحة التتبع ***
              Navigator.of(context).push(
                MaterialPageRoute(
                  // توفير ChildTrackingCubit لهذه الصفحة فقط
                  builder: (context) => BlocProvider(
                    create: (context) => ChildTrackingCubit(context.read<AuthRepo>()),
                    child: ChildTracingPage(child: child),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}