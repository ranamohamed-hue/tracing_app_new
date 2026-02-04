import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OptField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChange;
  const OptField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChange,
  });

  @override
  State<OptField> createState() => _OptFieldState();
}

class _OptFieldState extends State<OptField> {
  bool isFocused = false;
  @override
  void initState() {
    super.initState();
    // نستمع للتغيير في حالة التركيز
    widget.focusNode.addListener(() {
      setState(() {
        isFocused = widget.focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: isFocused ? Colors.white : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        boxShadow:
            isFocused
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ]
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),

      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,

        onChanged: widget.onChange,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        validator: (value) {
          return null;
        
          
        },
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: "",
          hintText: "0",
          hintStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }
}
