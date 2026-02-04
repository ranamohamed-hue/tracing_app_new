import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracing_app_new/core/theming/app_styles.dart';
import 'package:tracing_app_new/feature/parent/screens/parent_page.dart';
import 'package:tracing_app_new/feature/student/screens/student_page.dart';

enum UserType { student, parent }

class UserTypeSelectionPage extends StatefulWidget {
  const UserTypeSelectionPage({super.key});

  @override
  State<UserTypeSelectionPage> createState() => _UserTypeSelectionPageState();
}

class _UserTypeSelectionPageState extends State<UserTypeSelectionPage> {
  UserType? selectedType;
  @override
  void dispose() {
    super.dispose();
  }

  void _selectType(UserType type) {
    setState(() {
      selectedType = type;
    });
  }

  void _navigateToSelectedPage() {
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك قم باختيار نوع المستخدم')),
      );
      return;
    }

    if (selectedType == UserType.parent) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ParentPage()),
      );
    } else if (selectedType == UserType.student) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StudentPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: AppStyles.primaryGradientDecoration,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                "قم بالاختيار للمتابعة في التطبيق",
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.textTheme.headlineSmall?.color,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              //ولي الامر
              _buildSelectionCard(
                icon: Icons.family_restroom,
                label: "ولي أمر",
                value: UserType.parent,
              ),
              const SizedBox(height: 20),

              //  الطالب
              _buildSelectionCard(
                icon: Icons.school_outlined,
                label: "طالب",
                value: UserType.student,
              ),

              const SizedBox(height: 50),

              ElevatedButton(
                onPressed: _navigateToSelectedPage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "متابعة",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 7.   بطاقة الاختيار
  Widget _buildSelectionCard({
    required IconData icon,
    required String label,
    required UserType value,
  }) {
    final theme = Theme.of(context);
    final isSelected = (selectedType == value);

    return Card(
      color:
          isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.cardTheme.color,
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isSelected
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _selectType(value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Radio<UserType>(
                value: value,
                groupValue: selectedType,
                onChanged: (val) {
                  if (val != null) _selectType(val);
                },
                //  لون الراديو
                fillColor: WidgetStateProperty.resolveWith(
                  (states) =>
                      states.contains(WidgetState.selected)
                          ? theme.colorScheme.primary
                          : theme.unselectedWidgetColor,
                ),
              ),
              const SizedBox(width: 20),
              Text(
                label,
                style: theme.textTheme.titleLarge?.copyWith(
                  color:
                      isSelected
                          ? theme.colorScheme.primary
                          : theme.textTheme.titleLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(icon, size: 50, color: theme.iconTheme.color),
            ],
          ),
        ),
      ),
    );
  }
}
