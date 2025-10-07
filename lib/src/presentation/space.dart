import 'package:flutter/material.dart';

class Aspace {
  Aspace._();

  static Widget spaceVertical(double height) {
    return SizedBox(height: height);
  }

  static Widget spaceHorizontal(double width) {
    return SizedBox(width: width);
  }
}