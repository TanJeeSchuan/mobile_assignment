import 'dart:ui';
import 'package:flutter/material.dart';

class AppColors {
  static const backgroundColor = Color(0xFFFFFFFF);
  static const accentColor = Color(0xFF03A9F4);

  static final borderColour = Colors.grey.shade300;
  static final shadowColor = Colors.black.withValues(alpha: 0.08);

  static final regularText = Colors.black;
  static final subText = Colors.grey;

  static const verifiedColor = Color(0xFFDFF7E4);
  static const unverifiedColor = Color(0xFFF9D6D6);

  static const defaultColor  = Color(0xFF000000);
  static const Color stepCompleted = Color(0xFFe8dcfc);
  static const Color stepActive   = Color(0xFF8edb8c);   // green
  static const Color stepPending = Color(0xFFb0b0b0);   // grey
  static const Color packing = Color(0xFFFF84FD);  // Packing
  static const Color ready   = Color(0xFF84DAFF);  // Ready
  static const Color transit = Color(0xFFFFA76C);  // Transit
  static const Color arrived = Color(0xFFA4FF88);  // Arrived
}

// extension CustomColors on ColorScheme {
//   Color get packing => const Color(0xFFFF84FD);
//   Color get ready => const Color(0xFF84DAFF);
//   Color get transit => const Color(0xFFFFA76C);
//   Color get arrived => const Color(0xFFA4FF88);
// }
