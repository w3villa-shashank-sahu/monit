import 'package:flutter/material.dart';

class MytextField extends StatefulWidget {
  final String hintText;
  final bool isPasswordField;
  final String curveType;
  final TextEditingController? controller;
  final int minline;

  static const String topCurve = "Top curve";
  static const String noCurve = "No curve";
  static const String bottomCurve = "Bottom curve";

  const MytextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPasswordField = false,
    this.curveType = noCurve,
    this.minline = 1,
  });

  @override
  State<MytextField> createState() => _MytextFieldState();
}

class _MytextFieldState extends State<MytextField> {
  bool _isObscured = true;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  // Define colors that were previously in Styles class
  static const Color colorblue5 = Color(0xFF006EFF);
  static const Color colorgrey1 = Color(0xFF9E9E9E);
  static const Color black = Colors.black;

  @override
  void initState() {
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 370),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
        padding: EdgeInsets.only(left: 15, right: widget.isPasswordField ? 5 : 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(widget.curveType == MytextField.topCurve ? 15 : 0),
            topRight: Radius.circular(widget.curveType == MytextField.topCurve ? 15 : 0),
            bottomLeft: Radius.circular(widget.curveType == MytextField.bottomCurve ? 15 : 0),
            bottomRight: Radius.circular(widget.curveType == MytextField.bottomCurve ? 15 : 0),
          ),
          border: Border.all(color: _isFocused ? colorblue5 : colorgrey1),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                minLines: widget.minline,
                maxLines: widget.minline,
                controller: widget.controller,
                obscureText: widget.isPasswordField && _isObscured,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: black,
                ),
                decoration: InputDecoration(
                  labelText: widget.hintText,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 13,
                    color: colorgrey1,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (widget.isPasswordField)
              IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
