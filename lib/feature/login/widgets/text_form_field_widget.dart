import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatelessWidget {
  final String title;
  final String hinttext;
  final TextInputType keyboardtype;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?)? validatorr;
  final bool obscureText;

  const TextFormFieldWidget({
    super.key,
    required this.title,
    required this.hinttext,
    required this.keyboardtype,
    required this.controller,
    required this.icon,
    required this.validatorr,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, 
      
      obscureText: obscureText,
      keyboardType: keyboardtype,
      validator: validatorr,
      decoration: InputDecoration(
        labelText: title,
        hintText: hinttext,
       
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        
      ),
    );
  }
}