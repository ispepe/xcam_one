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

class CameraState extends ChangeNotifier {
  BatteryStatus _batteryStatus = BatteryStatus.batteryFull;

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

  /// 免费空间
  String _freeSpace = '1KB';

  /// 总空间
  String _diskSpace = '1KB';

  int _freeSpaceData = 1;

  int _diskSpaceData = 1;

  String get freeSpace => _freeSpace;

  /// 获取可用空间
  Future<void> _diskFreeSpaceCheck() async {
    await DioUtils.instance.requestNetwork<DiskFreeSpaceEntity>(
        Method.get, HttpApi.getDiskFreeSpace, onSuccess: (data) {
      _freeSpaceData = data?.function?.space ?? 0;
      double size = _freeSpaceData.toDouble();

      int i = 0;
      while (size > 1024) {
        size = size / 1024;
        i++;
        if (i == 4) break;
      }

      _freeSpace = size.toStringAsFixed(2);
      switch (i) {
        case 0:
          _freeSpace += 'B';
          break;
        case 1:
          _freeSpace += 'KB';
          break;
        case 2:
          _freeSpace += 'M';
          break;
        case 3:
          _freeSpace += 'GB';
          break;
        case 4:
          _freeSpace += 'TB';
          break;
      }

      notifyListeners();
    }, onError: (code, message) {
      debugPrint('code: $code, message: $message');
    });
  }

  /// 获取空间检测
  Future<void> diskSpaceCheck() async {
    await DioUtils.instance.requestNetwork<DiskFreeSpaceEntity>(
        Method.get, HttpApi.getDiskSpace, onSuccess: (data) {
      _diskSpaceData = data?.function?.space ?? 0;
      double size = _diskSpaceData.toDouble();

      int i = 0;
      while (size > 1024) {
        size = size / 1024;
        i++;
        if (i == 4) break;
      }

      _diskSpace = size.toStringAsFixed(2);
      switch (i) {
        case 0:
          _diskSpace += 'B';
          break;
        case 1:
          _diskSpace += 'KB';
          break;
        case 2:
          _diskSpace += 'M';
          break;
        case 3:
          _diskSpace += 'GB';
          break;
        case 4:
          _diskSpace += 'TB';
          break;
      }
      _diskFreeSpaceCheck();
    }, onError: (code, message) {
      debugPrint('code: $code, message: $message');
    });
  }

  String get diskSpace => _diskSpace;

  int get freeSpaceData => _freeSpaceData;

  int get diskSpaceData => _diskSpaceData;

  void initSpaceData() {
    /// 免费空间
    _freeSpace = '1KB';

    /// 总空间
    _diskSpace = '1KB';

    _freeSpaceData = 1;

    _diskSpaceData = 1;
    notifyListeners();
  }
}
