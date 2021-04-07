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

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:xcam_one/global/global_store.dart';
import 'package:xcam_one/models/battery_level_entity.dart';
import 'package:xcam_one/models/capture_entity.dart';
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

  StreamSubscription<ConnectivityResult>? subscription;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      subscription = Connectivity()
          .onConnectivityChanged
          .listen((ConnectivityResult result) {
        debugPrint('网络连接：${result.toString()}');
        if (ConnectivityResult.wifi == result) {
          /// 进行一次心跳检测/电源检测
          DioUtils.instance.asyncRequestNetwork<BatteryLevelEntity>(
            Method.get,
            HttpApi.getBatteryLevel,
            onSuccess: (data) {
              final int index = data?.function?.batteryStatus ?? 0;
              Provider.of<GlobalState>(context, listen: false).batteryStatus =
                  BatteryStatus.values[index];

              Provider.of<GlobalState>(context, listen: false).isConnect = true;
            },
          );
        } else {
          Provider.of<GlobalState>(context, listen: false).isConnect = false;
        }
      });

      /// 定时检测相机电源
      _timer = Timer.periodic(Duration(seconds: 60), (timer) {
        final globalState = context.read<GlobalState>();
        if (globalState.isConnect && !globalState.isCapture && mounted) {
          DioUtils.instance.requestNetwork<BatteryLevelEntity>(
            Method.get,
            HttpApi.getBatteryLevel,
            onSuccess: (data) {
              final int index = data?.function?.batteryStatus ?? 0;
              globalState.batteryStatus = BatteryStatus.values[index];
            },
          );
        }
      });
    });
  }

  @override
  void dispose() async {
    super.dispose();

    await subscription?.cancel();
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final globalState = context.watch<GlobalState>();

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

  void _changePage(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    } else if (index == 1) {
      // 1 表示已进入相机界面，二次点击开始拍照
      GlobalStore.videoPlayerController?.stop();

      Provider.of<GlobalState>(context, listen: false).isCapture = true;
      DioUtils.instance.requestNetwork<WifiAppModeEntity>(
        Method.get,
        HttpApi.appModeChange + WifiAppMode.wifiAppModePhoto.index.toString(),
        onSuccess: (mode) {
          DioUtils.instance.requestNetwork<CaptureEntity>(
            Method.get,
            HttpApi.capture,
            onSuccess: (data) {
              debugPrint(data.toString());

              Future.delayed(Duration(seconds: 1), () {
                DioUtils.instance.requestNetwork<WifiAppModeEntity>(
                    Method.get,
                    HttpApi.appModeChange +
                        WifiAppMode.wifiAppModeMovie.index.toString(),
                    onSuccess: (modeEntity) {
                  GlobalStore.videoPlayerController?.play();
                  Provider.of<GlobalState>(context, listen: false).isCapture =
                      false;
                }, onError: (code, msg) {
                  debugPrint(msg.toString());
                  Provider.of<GlobalState>(context, listen: false).isCapture =
                      false;
                });
              });
            },
            onError: (code, msg) {
              debugPrint(msg.toString());
              Provider.of<GlobalState>(context, listen: false).isCapture =
                  false;
            },
          );
        },
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
