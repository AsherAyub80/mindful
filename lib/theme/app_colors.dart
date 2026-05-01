import 'package:flutter/material.dart';

class AppColors {
  static const Color primary   = Color(0xFF4FACB8);
  static const Color secondary = Color(0xFF6DBF9E);
  static const Color accent    = Color(0xFFA8D8EA);
  static const Color deep      = Color(0xFF2D7D8E);
  static const Color emerald   = Color(0xFF3DAA7A);
  static const Color mint      = Color(0xFFB8EDD6);
  static const Color coral     = Color(0xFFFF8B6B);
  static const Color gold      = Color(0xFFF7C59F);

  static const Color bgDark    = Color(0xFF080F18);
  static const Color bgMid     = Color(0xFF0F2A35);

  static const Color white10   = Color(0x1AFFFFFF);
  static const Color white15   = Color(0x26FFFFFF);
  static const Color white20   = Color(0x33FFFFFF);
  static const Color white50   = Color(0x80FFFFFF);
  static const Color white70   = Color(0xB3FFFFFF);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF050E14), Color(0xFF0A1F14), Color(0xFF050E14)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [primary, deep],
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [primary, emerald],
  );
}
