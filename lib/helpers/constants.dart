import 'package:flutter/material.dart';

class AppID {
  static final AppID _appId = AppID._interval();

  factory AppID() {
    return _appId;
  }

  AppID._interval();

  static const String HOME = "/home";
  static const String ACCESS = "/access";
}

class AppColors {
  static final AppColors _appColors = AppColors._interval();

  factory AppColors() {
    return _appColors;
  }

  AppColors._interval();
}
