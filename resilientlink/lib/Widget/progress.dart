import 'package:flutter/material.dart';

class Progress extends StatelessWidget {
  final int status;
  const Progress({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Table(
      children: [
        TableRow(
          children: [
            Text(
              'Placed',
              style: TextStyle(
                color: Color(0xFF157759),
              ),
            ),
            Text(
              'Received',
              style: TextStyle(
                color: status >= 1 ? Color(0xFF157759) : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'Delivered',
              style: TextStyle(
                color: status >= 2 ? Color(0xFF157759) : Colors.black54,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
        TableRow(
          children: [
            Row(
              children: [
                Icon(
                  Icons.fiber_manual_record,
                  color: Color(0xFF157759),
                  size: 10,
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: status >= 1 ? Color(0xFF157759) : Colors.black54,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 2,
                    color: status >= 1 ? Color(0xFF157759) : Colors.black54,
                  ),
                ),
                Icon(
                  Icons.fiber_manual_record,
                  color: status >= 1 ? Color(0xFF157759) : Colors.black54,
                  size: 10,
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: status >= 2 ? Color(0xFF157759) : Colors.black54,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 2,
                    color: status >= 2 ? Color(0xFF157759) : Colors.black54,
                  ),
                ),
                Icon(
                  Icons.fiber_manual_record,
                  color: status >= 2 ? Color(0xFF157759) : Colors.black54,
                  size: 10,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
