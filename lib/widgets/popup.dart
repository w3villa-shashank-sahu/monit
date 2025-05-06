import 'package:flutter/material.dart';

class MyAlert extends StatelessWidget {
  final String msg;
  final bool iserror;
  const MyAlert({super.key, required this.msg, this.iserror = true});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Center(
        child: iserror
            ? const Icon(Icons.error_outline, color: Colors.red, size: 50)
            : const Icon(Icons.check_circle_outline, color: Colors.green, size: 50),
      ),
      content: Text(msg, softWrap: true),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'))
      ],
    );
  }
}
