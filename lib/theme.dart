import 'package:flutter/material.dart';
import 'package:youtube_to_mp3/constant.dart';

InputDecoration textFieldInputDecoration(
  String labelText,
  String hintText, {
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? errortext,
}) {
  return InputDecoration(
    //errorMaxLines: isError? 0 : 1,
    suffixIcon: suffixIcon,
    filled: true,
    contentPadding: EdgeInsets.symmetric(vertical: 12.5, horizontal: 10),
    isDense: true,
    prefixIcon: prefixIcon,
    hintText: hintText,
    hintStyle: TextStyle(
      color: kPrimaryColor.withOpacity(0.33),
      fontSize: 13,
    ),
    labelText: labelText,
    labelStyle: TextStyle(
      color: kPrimaryColor.withOpacity(0.33),
      fontSize: 12,
    ),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    fillColor: Colors.white,
    focusedBorder: OutlineInputBorder(
      gapPadding: 1,
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: kPrimaryColor, width: 1.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      gapPadding: 1,
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(
        width: 1.0,
        color: kPrimaryColor,
      ),
    ),
    errorBorder: OutlineInputBorder(
      gapPadding: 1,
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        width: 1.0,
        color: Colors.red.withOpacity(0.33),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      gapPadding: 1,
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        width: 1.0,
        color: kPrimaryColor.withOpacity(0.13),
      ),
    ),
  );
}
