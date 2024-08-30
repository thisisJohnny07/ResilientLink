import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTab;
  final String label;

  const Button({
    super.key,
    required this.onTab,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTab,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                icon,
                color: const Color(0xFF015490),
                size: 50,
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 16, color: Color(0xFF015490)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
