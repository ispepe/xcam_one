/*
 * Copyright (c) 2021 Jing Pei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 * https://jingpei.tech
 * https://jin.dev
 *
 * Created by Angus
 */

import 'package:flutter/cupertino.dart';

/// 全局状态，设置会自动检测刷新
class GlobalState extends ChangeNotifier {
  /// 默认没有连接全景相机
  bool _isConnect = false;

  String? currentSSID;

  bool get isConnect => _isConnect;

  set isConnect(bool value) {
    _isConnect = value;
    notifyListeners();
  }

  /// 是否正在捕获
  bool _isCapture = false;

  bool get isCapture => _isCapture;

  set isCapture(bool value) {
    _isCapture = value;
    notifyListeners();
  }

  /// 是否正在初始化中
  bool _isInitApp = false;

  bool get isInit => _isInitApp;

  set isInit(bool value) {
    _isInitApp = value;
    notifyListeners();
  }
}
