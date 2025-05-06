import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  final bool active;
  final Function() func;
  const ToggleButton({super.key, required this.active, required this.func});

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  late bool toggleval = widget.active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            toggleval = !toggleval;
            widget.func();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 25,
          width: 50,
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(20), color: toggleval ? Colors.green : Colors.red),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: AnimatedAlign(
                  alignment: toggleval ? Alignment.centerRight : Alignment.centerLeft,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black38,
                              offset: toggleval ? const Offset(-1, 0) : const Offset(1, 0),
                              blurRadius: 3)
                        ],
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
