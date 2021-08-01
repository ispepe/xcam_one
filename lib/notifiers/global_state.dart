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

enum InitType {
  init, // 初始化中
  // checkFW, // 固件检测中
  updateFW, // 更新固件中
  checkMaps, // 检测标定文件
  downMaps, // 下载标定文件
  zipDecoderMaps, // 解压标定文件
  connect, // 去连接
  reconnect, // 重新连接
}

extension InitTypeExt on InitType {
  String get value => [
        '初始化中',
        // '检测固件',
        '固件升级中',
        '检测标定文件',
        '下载标定文件',
        '解压标定文件',
        '去连接',
        '重新连接'
      ][index];
}

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

  InitType _initType = InitType.connect;

  InitType get initType => _initType;

  set initType(InitType value) {
    _initType = value;
    notifyListeners();
  }
}
