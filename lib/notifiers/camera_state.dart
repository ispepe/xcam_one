/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'package:flutter/cupertino.dart';
import 'package:xcam_one/models/battery_level_entity.dart';
import 'package:xcam_one/models/disk_free_space_entity.dart';
import 'package:xcam_one/net/net.dart';

/// 延迟拍摄时间
enum CountdownEnum {
  close,
  five,
  ten,
  twenty,
}

extension CountdownEnumEx on CountdownEnum {
  String get text => ['关', '5s', '10s', '20s'][index];

  int get value => [0, 5, 10, 20][index];
}

class CameraState extends ChangeNotifier {
  BatteryStatus _batteryStatus = BatteryStatus.batteryFull;

  CountdownEnum _countdown = CountdownEnum.close;

  /// /// FIXME: 4/22/21 解决连接成功后应该先初始化成功后才能显示player的问题
  bool _isShowVLCPlayer = false;
  bool get isShowVLCPlayer => _isShowVLCPlayer;

  set isShowVLCPlayer(bool value) {
    _isShowVLCPlayer = value;
    notifyListeners();
  }

  CountdownEnum get countdown => _countdown;

  set countdown(CountdownEnum value) {
    _countdown = value;
    notifyListeners();
  }

  int _currentCountdownValue = 0;

  int get currentCountdownValue => _currentCountdownValue;

  set currentCountdownValue(int value) {
    _currentCountdownValue = value;
    notifyListeners();
  }

  BatteryStatus get batteryStatus => _batteryStatus;

  set batteryStatus(BatteryStatus value) {
    _batteryStatus = value;
    notifyListeners();
  }

  Future<void> batteryLevelCheck() async {
    await DioUtils.instance.requestNetwork<BatteryLevelEntity>(
        Method.get, HttpApi.getBatteryLevel, onSuccess: (data) {
      final int index = data?.function?.batteryStatus ?? 0;
      batteryStatus = BatteryStatus.values[index];
    }, onError: (code, message) {
      debugPrint('code: $code, message: $message');
    });
  }

  /// 剩余空间
  String _freeSpace = '0KB';

  /// 总空间
  String _diskSpace = '0KB';

  /// 使用空间
  String _useSpace = '0KB';

  String get useSpace => _useSpace;

  int _freeSpaceData = 1;

  int _diskSpaceData = 1;

  String get freeSpace => _freeSpace;

  /// 获取可用空间
  Future<void> _diskFreeSpaceCheck() async {
    await DioUtils.instance.requestNetwork<DiskFreeSpaceEntity>(
        Method.get, HttpApi.getDiskFreeSpace, onSuccess: (data) {
      _freeSpaceData = data?.function?.space ?? 0;
      final double size = _freeSpaceData.toDouble();
      _freeSpace = calcSpace(size);

      _useSpace = calcSpace((_diskSpaceData - _freeSpaceData).toDouble());
      notifyListeners();
    }, onError: (code, message) {
      debugPrint('code: $code, message: $message');
    });
  }

  String calcSpace(double size) {
    int i = 0;
    while (size > 1024) {
      size = size / 1024;
      i++;
      if (i == 4) break;
    }

    var spaceStr = size.toStringAsFixed(2);
    switch (i) {
      case 0:
        spaceStr += 'B';
        break;
      case 1:
        spaceStr += 'KB';
        break;
      case 2:
        spaceStr += 'M';
        break;
      case 3:
        spaceStr += 'GB';
        break;
      case 4:
        spaceStr += 'TB';
        break;
    }

    return spaceStr;
  }

  /// 获取空间检测
  Future<void> diskSpaceCheck() async {
    await DioUtils.instance.requestNetwork<DiskFreeSpaceEntity>(
        Method.get, HttpApi.getDiskSpace, onSuccess: (data) {
      _diskSpaceData = data?.function?.space ?? 0;
      final double size = _diskSpaceData.toDouble();
      _diskSpace = calcSpace(size);

      _diskFreeSpaceCheck();
    }, onError: (code, message) {
      debugPrint('code: $code, message: $message');
    });
  }

  String get diskSpace => _diskSpace;

  int get freeSpaceData => _freeSpaceData;

  int get diskSpaceData => _diskSpaceData;

  void clearSpaceData() {
    /// 免费空间
    _freeSpace = '1KB';

    /// 总空间
    _diskSpace = '1KB';

    _freeSpaceData = 1;

    _diskSpaceData = 1;
    notifyListeners();
  }
}
