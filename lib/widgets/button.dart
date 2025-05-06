import 'package:flutter/material.dart';

class Mybutton extends StatefulWidget {
  final Future Function() onPressed;
  final String text;
  final bool isActive;
  final bool isOutline;

  const Mybutton(
      {super.key, required this.onPressed, required this.text, this.isActive = true, this.isOutline = false});

  @override
  State<Mybutton> createState() => MybuttonState();
}

class MybuttonState extends State<Mybutton> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final Color buttonBlue = Colors.blue.shade700;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: widget.isOutline
          ? OutlinedButton(
              onPressed: (widget.isActive && !isLoading) ? handleOnPress : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                foregroundColor: buttonBlue,
                side: BorderSide(color: buttonBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: _buildButtonContent(),
            )
          : ElevatedButton(
              onPressed: (widget.isActive && !isLoading) ? handleOnPress : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 2,
                backgroundColor: buttonBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: _buildButtonContent(),
            ),
    );
  }

  Widget _buildButtonContent() {
    final Color loadingColor = widget.isOutline ? Colors.blue.shade700 : Colors.white;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isLoading
          ? Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
                ),
              ),
            )
          : Text(
              widget.text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
    );
  }

  Future<void> handleOnPress() async {
    setState(() {
      isLoading = true;
    });
    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
