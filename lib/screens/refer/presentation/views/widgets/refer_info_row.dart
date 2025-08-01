import 'package:flutter/material.dart';

class ReferInfoRow extends StatelessWidget {
  final String text;
  final int? flex;

  const ReferInfoRow({super.key, required this.text, this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex ?? 1,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
