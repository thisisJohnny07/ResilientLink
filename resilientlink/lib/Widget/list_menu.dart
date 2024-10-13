import 'package:flutter/material.dart';

class ListMenu extends StatelessWidget {
  const ListMenu(
      {super.key,
      required this.title,
      required this.icon,
      required this.onpress,
      this.textColor,
      this.value});

  final String title;
  final IconData icon;
  final VoidCallback onpress;
  final Color? textColor;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onpress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: const Color(0xFF015490).withOpacity(0.1),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF015490),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16).apply(color: textColor),
          ),
          if (value != null && value!.isNotEmpty)
            Text(
              value!,
              style: const TextStyle(fontSize: 14, color: Colors.black38),
            ),
        ],
      ),
      trailing: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 18,
        ),
      ),
    );
  }
}
