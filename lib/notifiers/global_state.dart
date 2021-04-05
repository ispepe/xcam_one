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

  bool get isConnect => _isConnect;

  set isConnect(bool value) {
    _isConnect = value;
    notifyListeners();
  }

  /// 固件版本
  String _cameraVersion = '';

  String get cameraVersion => _cameraVersion;

  set cameraVersion(String value) {
    _cameraVersion = value;
    notifyListeners();
  }
}
