import 'package:flutter/material.dart';

class AppShadows {
  static const soft = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8.0,
      offset: Offset(0, 2),
    )
  ];

  static const medium = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16.0,
      offset: Offset(0, 4),
    )
  ];

  static const strong = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 24.0,
      offset: Offset(0, 8),
    )
  ];
}
