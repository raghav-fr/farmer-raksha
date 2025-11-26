import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class Iconcustomtextbox extends StatelessWidget {
  final TextEditingController? textEditingController;
  final double height;
  final Icon icon;
  final String? hint;
  const Iconcustomtextbox({
    super.key,
    required this.textEditingController,
    required this.height,
    required this.icon,
    this.hint
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(30), // 👈 Rounded edges
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 12),
          icon,
          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 25,
            color: Colors.grey.shade400, // 👈 Vertical divider
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              cursorColor: Color.fromRGBO(83, 40, 225, 1),
              cursorRadius: Radius.circular(10),
              cursorWidth: 1.5,
              controller: textEditingController,
              style: GoogleFonts.poppins(fontSize: 15.sp),
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 3,
                ),
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hint ,
                hintStyle: TextStyle(color: Colors.grey)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
