import 'dart:ui';

import 'package:flutter/material.dart';

enum StatusBarOrderType{
  packing,
  ready,
  transit,
  arrived,
}

enum OrderStageStatus {
  pending,
  active,
  completed,
}

class OrderStrings {
  static const String awaiting = "Awaiting";
  static const String packing = "Packing";
  static const String ready   = "Ready";
  static const String transit = "Transit";
  static const String arrived = "Arrived";
}

class FontPresents {
  static final TextStyle tableHeader = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static final TextStyle tableCell = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  );
}