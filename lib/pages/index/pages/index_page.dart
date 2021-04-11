/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:connectivity_plus/connectivity_plus.dart'
    show Connectivity, ConnectivityResult;
import 'package:oktoast/oktoast.dart';

import 'package:provider/provider.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:xcam_one/global/global_store.dart';
import 'package:xcam_one/models/battery_level_entity.dart';
import 'package:xcam_one/models/capture_entity.dart';
import 'package:xcam_one/models/hearbeat_entity.dart';
import 'package:xcam_one/models/wifi_app_mode_entity.dart';
import 'package:xcam_one/net/net.dart';

import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/pages/camera/pages/camera_page.dart';
import 'package:xcam_one/pages/photo/pages/photo_page.dart';
import 'package:xcam_one/pages/setting/pages/setting_page.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage>
    with AutomaticKeepAliveClientMixin {
  final List<BottomNavigationBarItem> bottomNavItems = [
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/photo.png',
        width: 32,
        height: 32,
      ),
      activeIcon: Image.asset(
        'assets/images/select_photo.png',
        width: 32,
        height: 32,
      ),
      label: "相册",
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/camera.png',
        width: 40,
        height: 40,
      ),
      activeIcon: Image.asset(
        'assets/images/select_camera.png',
        width: 70,
        height: 70,
      ),
      label: '拍照',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/setting.png',
        width: 32,
        height: 32,
      ),
      activeIcon: Image.asset(
        'assets/images/select_setting.png',
        width: 32,
        height: 32,
      ),
      label: "设置",
    ),
  ];

  final List<BottomNavigationBarItem> cameraBottomNavItems = [
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/camera_photo.png',
        width: 32,
        height: 32,
      ),
      activeIcon: Image.asset(
        'assets/images/select_photo.png',
        width: 32,
        height: 32,
      ),
      label: "相册",
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/camera.png',
        width: 40,
        height: 40,
      ),
      activeIcon: Image.asset(
        'assets/images/select_camera.png',
        width: 70,
        height: 70,
      ),
      label: '拍照',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/camera_setting.png',
        width: 32,
        height: 32,
      ),
      activeIcon: Image.asset(
        'assets/images/select_setting.png',
        width: 32,
        height: 32,
      ),
      label: "设置",
    ),
  ];

  final List<BottomNavigationBarItem> disableCameraBottomNavItems = [
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/camera_photo_disable.png',
        width: 32,
        height: 32,
      ),
      activeIcon: Image.asset(
        'assets/images/select_photo.png',
        width: 32,
        height: 32,
      ),
      label: "相册",
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/camera_disable.png',
        width: 60,
        height: 60,
      ),
      label: '拍照',
    ),
    BottomNavigationBarItem(
      icon: Image.asset(
        'assets/images/camera_setting_disable.png',
        width: 32,
        height: 32,
      ),
      activeIcon: Image.asset(
        'assets/images/select_setting.png',
        width: 32,
        height: 32,
      ),
      label: "设置",
    ),
  ];

  int _currentIndex = 0;

  final _pages = [PhotoPage(), CameraPage(), SettingPage()];

  final Connectivity _connectivity = Connectivity();

  // final WifiInfo _wifiInfo = WifiInfo();

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  late Timer _timer;

  bool _isTimerRequest = false;

  late Timer _batteryCheckTimer;

  late GlobalState globalState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initConnectivity();
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

      /// 定时检测相机电源
      _timer = Timer.periodic(Duration(seconds: 2), (timer) {
        /// NOTE: 4/9/21 待注意 由于IOS没有Wi-Fi检测的方式方法，则定时检测操作
        if (!kIsWeb && !_isTimerRequest && !globalState.isCapture && mounted) {
          _updateConnectionStatus(ConnectivityResult.none);
        }
      });

      /// 拍照检测一次、进入拍照界面检测一次、每1分钟检测一下
      _batteryCheckTimer = Timer.periodic(Duration(seconds: 20), (timer) {
        if (globalState.isConnect && !globalState.isCapture && mounted) {
          _batteryLevelCheck();
        }
      });
    });
  }

  Future<void> _batteryLevelCheck() async {
    await DioUtils.instance.requestNetwork<BatteryLevelEntity>(
        Method.get, HttpApi.getBatteryLevel, onSuccess: (data) {
      final int index = data?.function?.batteryStatus ?? 0;
      globalState.batteryStatus = BatteryStatus.values[index];
    }, onError: (code, message) {
      debugPrint('code: $code, message: $message');
    });
  }

  @override
  void dispose() async {
    super.dispose();

    await _connectivitySubscription.cancel();
    _timer.cancel();
    _batteryCheckTimer.cancel();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    debugPrint('网络连接：${result.toString()}');
    if (ConnectivityResult.wifi == result ||
        ConnectivityResult.none == result) {
      _isTimerRequest = true;

      /// 拍照检测一次、进入拍照界面检测一次、每1分钟检测一下
      DioUtils.instance.asyncRequestNetwork<HearbeatEntity>(
          Method.get, HttpApi.heartbeat, onSuccess: (data) {
        if (data?.function?.status == '0') {
          globalState.isConnect = true;
        } else {
          globalState.isConnect = false;
        }

        _isTimerRequest = false;
      }, onError: (e, m) {
        _isTimerRequest = false;
        globalState.isConnect = false;
      });
    } else {
      globalState.isConnect = false;
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    globalState = context.watch<GlobalState>();

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: globalState.isConnect && _currentIndex == 1
            ? Colors.black
            : Colors.white,
        items: globalState.isConnect && _currentIndex == 1
            ? globalState.isCapture
                ? disableCameraBottomNavItems
                : cameraBottomNavItems
            : bottomNavItems,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          _changePage(index);
        },
      ),
    );
  }

  Future<void> _changePage(int index) async {
    if (globalState.isCapture) {
      showToast('拍摄中，请稍等');
      return;
    }

    if (index != _currentIndex) {
      if (index == 1) {
        /// 立即进行一次电量检测
        await _batteryLevelCheck();
      }
      setState(() {
        _currentIndex = index;
      });
    } else if (index == 1 && globalState.isConnect) {
      await _batteryLevelCheck();
      if (globalState.batteryStatus == BatteryStatus.batteryLow ||
          globalState.batteryStatus == BatteryStatus.batteryEmpty ||
          globalState.batteryStatus == BatteryStatus.batteryExhausted) {
        showToast('低电量，拍摄失败');
        return;
      }

      // 1 表示已进入相机界面，二次点击开始拍照
      await GlobalStore.videoPlayerController?.stop();
      globalState.isCapture = true;
      await DioUtils.instance.requestNetwork<WifiAppModeEntity>(
        Method.get,
        HttpApi.appModeChange + WifiAppMode.wifiAppModePhoto.index.toString(),
        onSuccess: (mode) {
          DioUtils.instance.requestNetwork<CaptureEntity>(
            Method.get,
            HttpApi.capture,
            onSuccess: (data) {
              debugPrint(data.toString());

              /// NOTE: 4/7/21 待注意 此处必须要停留1秒，否则会卡死相机
              Future.delayed(Duration(seconds: 1), () {
                DioUtils.instance.requestNetwork<WifiAppModeEntity>(
                    Method.get,
                    HttpApi.appModeChange +
                        WifiAppMode.wifiAppModeMovie.index.toString(),
                    onSuccess: (modeEntity) {
                  GlobalStore.videoPlayerController?.play();
                  globalState.isCapture = false;
                }, onError: (code, msg) {
                  debugPrint(msg.toString());
                  globalState.isCapture = false;
                });
              });
            },
            onError: (code, msg) {
              debugPrint(msg.toString());
              globalState.isCapture = false;
            },
          );
        },
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
