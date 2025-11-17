import 'package:flutter/material.dart';

// Placeholder color extension while AppFlowy dependencies are decoupled

extension PublishColorExtension on Color {
  String toHexString() {
    return '#${value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}