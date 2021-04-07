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
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:xcam_one/models/battery_level_entity.dart';
import 'package:xcam_one/net/http_api.dart';

/// 全局状态，设置会自动检测刷新
class GlobalState extends ChangeNotifier {
  /// 默认没有连接全景相机
  bool _isConnect = false;

  bool get isConnect => _isConnect;

  set isConnect(bool value) {
    _isConnect = value;
    notifyListeners();
  }

  BatteryStatus _batteryStatus = BatteryStatus.batteryFull;

  BatteryStatus get batteryStatus => _batteryStatus;

  set batteryStatus(BatteryStatus value) {
    _batteryStatus = value;
    notifyListeners();
  }

  /// 是否正在捕获
  bool _isCapture = false;

  bool get isCapture => _isCapture;

  set isCapture(bool value) {
    _isCapture = value;
    notifyListeners();
  }
}
