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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:connectivity_plus/connectivity_plus.dart'
    show Connectivity, ConnectivityResult;
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:oktoast/oktoast.dart';

import 'package:provider/provider.dart';
import 'package:xcam_one/global/global_store.dart';
import 'package:xcam_one/models/battery_level_entity.dart';
import 'package:xcam_one/models/capture_entity.dart';
import 'package:xcam_one/models/hearbeat_entity.dart';
import 'package:xcam_one/models/wifi_app_mode_entity.dart';
import 'package:xcam_one/net/net.dart';
import 'package:xcam_one/notifiers/camera_state.dart';

import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/pages/camera/pages/camera_page.dart';
import 'package:xcam_one/pages/photo/pages/photo_page.dart';
import 'package:xcam_one/pages/setting/pages/setting_page.dart';
import 'package:xcam_one/utils/socket_utils.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
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

  /// TODO: 4/14/21 待优化底部导航图标
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
  late CameraState cameraState;

  SocketUtils? _cameraSocket;

  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    initVlcPlayer();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initConnectivity();
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

      /// 定时心跳检测
      _timer = Timer.periodic(Duration(seconds: 5), (timer) {
        /// NOTE: 4/9/21 待注意 由于IOS没有Wi-Fi检测的方式方法，则定时检测操作
        /// TODO: 4/16/21 待处理 增加常连接，不需要定时检测
        if (!kIsWeb && !_isTimerRequest && !globalState.isCapture && mounted) {
          _updateConnectionStatus(ConnectivityResult.none);
        }
      });

      /// 拍照检测一次、进入拍照界面检测一次、每20s检测一次电量
      _batteryCheckTimer = Timer.periodic(Duration(seconds: 20), (timer) {
        if (globalState.isConnect && !globalState.isCapture && mounted) {
          cameraState.batteryLevelCheck();
        }
      });
    });
  }

  @override
  void dispose() async {
    super.dispose();

    await _connectivitySubscription.cancel();
    _timer.cancel();
    _batteryCheckTimer.cancel();
    _cameraSocket?.dispose();

    await GlobalStore.videoPlayerController?.stopRendererScanning();
    await GlobalStore.videoPlayerController?.dispose();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    debugPrint('网络连接：${result.toString()}');

    /// 阻止定时请求进入
    _isTimerRequest = true;

    if (ConnectivityResult.wifi == result ||
        ConnectivityResult.none == result) {
      /// 拍照检测一次、进入拍照界面检测一次、每1分钟检测一下
      DioUtils.instance.asyncRequestNetwork<HearbeatEntity>(
          Method.get, HttpApi.heartbeat, onSuccess: (data) async {
        if (data?.function?.status == '0') {
          if (!globalState.isConnect) {
            ///  切换至Photo模式
            DioUtils.instance.asyncRequestNetwork<WifiAppModeEntity>(
                Method.get,
                HttpApi.appModeChange +
                    WifiAppMode.wifiAppModePhoto.index.toString(),
                onSuccess: (modeEntity) {
              GlobalStore.wifiAppMode = WifiAppMode.wifiAppModePhoto;
              initVlcPlayer();
              globalState.isConnect = true;
              cameraState.diskSpaceCheck();
            }, onError: (code, msg) {
              /// TODO: 4/17/21 待处理 切换不成功，应该如何处理？
              showToast('进入相机模式失败');
              globalState.isConnect = true;
              cameraState.diskSpaceCheck();
            });
          }
        } else if (globalState.isConnect) {
          showToast('相机连接中断');
          globalState.isConnect = false;
          cameraState.initSpaceData();
          try {
            final bool? isPlay =
                await GlobalStore.videoPlayerController?.isPlaying();
            if (isPlay ?? false) {
              await GlobalStore.videoPlayerController?.stop();
            }
          } catch (e) {
            e.toString();
          }

          _cameraSocket?.dispose();
        }
        _isTimerRequest = false;
      }, onError: (e, m) async {
        if (globalState.isConnect) {
          showToast('相机异常连接中断');
          globalState.isConnect = false;
          cameraState.initSpaceData();
          try {
            final bool? isPlay =
                await GlobalStore.videoPlayerController?.isPlaying();
            if (isPlay ?? false) {
              await GlobalStore.videoPlayerController?.stop();
            }
          } catch (e) {
            e.toString();
          }
          _cameraSocket?.dispose();
        }
        _isTimerRequest = false;
      });
    } else {
      showToast('wifi连接中断');

      if (globalState.isConnect) {
        globalState.isConnect = false;
        cameraState.initSpaceData();
        try {
          final bool? isPlay =
              await GlobalStore.videoPlayerController?.isPlaying();
          if (isPlay ?? false) {
            await GlobalStore.videoPlayerController?.stop();
          }
        } catch (e) {
          e.toString();
        }
      }
      _isTimerRequest = true;
    }
  }

  void initVlcPlayer() {
    GlobalStore.videoPlayerController = VlcPlayerController.network(
      HttpApi.streamingUrl,
      hwAcc: HwAcc.AUTO,
      autoPlay: true,
      autoInitialize: true,
      onInit: () async {
        await GlobalStore.videoPlayerController?.startRendererScanning();
        // await GlobalStore.videoPlayerController?.play();
      },
      options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.clockJitter(0),
            VlcAdvancedOptions.clockSynchronization(0),
            // VlcAdvancedOptions.fileCaching(0),
            VlcAdvancedOptions.networkCaching(2000),
            // VlcAdvancedOptions.liveCaching(0)
          ]),
          extras: [
            '--network-caching=3000',
            '--live-caching=3000',
            '--udp-caching=1000',
            '--tcp-caching=1000',
            '--realrtsp-caching=1000',
          ]
          // video: VlcVideoOptions([
          //   VlcVideoOptions.dropLateFrames(true),
          //   VlcVideoOptions.skipFrames(true)
          // ]),
          ),
    );
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
    globalState = context.read<GlobalState>();
    cameraState = context.read<CameraState>();

    final _watchGlobalState = context.watch<GlobalState>();

    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        controller: pageController,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _watchGlobalState.isConnect && _currentIndex == 1
            ? Colors.black
            : Colors.white,
        items: _watchGlobalState.isConnect && _currentIndex == 1
            ? _watchGlobalState.isCapture
                ? disableCameraBottomNavItems
                : cameraBottomNavItems
            : bottomNavItems,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) => _changePage(index),
      ),
    );
  }

  void _changePage(int index) {
    if (globalState.isCapture) {
      showToast('拍摄中，请稍等');
      return;
    }

    if (index != _currentIndex) {
      /// TODO: 4/17/21 快速点击拍摄存在异常，不止是从相册界面切换回来
      if (index == 1 && globalState.isConnect) {
        /// 立即进行一次电量检测
        cameraState.batteryLevelCheck();

        /// TODO 进行容量检测
        // _diskFreeSpaceCheck

        if (GlobalStore.wifiAppMode != WifiAppMode.wifiAppModePhoto) {
          /// 切换相机模式，并且进行播放
          DioUtils.instance.requestNetwork<WifiAppModeEntity>(
              Method.get,
              HttpApi.appModeChange +
                  WifiAppMode.wifiAppModePhoto.index.toString(),
              onSuccess: (modeEntity) {
            GlobalStore.wifiAppMode = WifiAppMode.wifiAppModePhoto;

            /// 必须要通知过去
            try {
              GlobalStore.videoPlayerController?.play();
            } catch (e) {
              debugPrint(e.toString());
            }
          }, onError: (code, msg) {
            // GlobalStore.videoPlayerController?.stop();
            /// TODO: 4/16/21 待处理 存在请求不成功的问题（通过刷新全景相机相册，快速进入拍摄界面）
            try {
              GlobalStore.videoPlayerController?.play();
            } catch (e) {
              debugPrint(e.toString());
            }
          });
        } else {
          try {
            GlobalStore.videoPlayerController?.play();
          } catch (e) {
            debugPrint(e.toString());
          }
        }
      }

      pageController.jumpToPage(index);
    } else if (index == 1 && globalState.isConnect) {
      cameraState.batteryLevelCheck();

      // globalState.batteryStatus == BatteryStatus.batteryLow
      if (cameraState.batteryStatus == BatteryStatus.batteryEmpty ||
          cameraState.batteryStatus == BatteryStatus.batteryExhausted) {
        showToast('低电量，拍摄失败');
        return;
      }

      // 1 表示已进入相机界面，二次点击开始拍照
      globalState.isCapture = true;
      GlobalStore.videoPlayerController?.stop().then((value) {
        DioUtils.instance.asyncRequestNetwork<CaptureEntity>(
          Method.get,
          HttpApi.capture,
          onSuccess: (data) {
            final status = data?.function?.status ?? '';

            switch (int.parse(status)) {
              case 0:
                showToast('拍摄成功,请在相机相册查看');
                break;
              case -5:
                showToast('文件错误，拍摄失败');
                break;
              case -11:
                showToast('没有存储空间，拍摄失败');
                break;
              case -12:
                showToast('没有文件空间，拍摄失败');
                break;
              default:
                showToast('拍摄异常');
                break;
            }

            globalState.isCapture = false;
            try {
              GlobalStore.videoPlayerController?.play();
            } catch (e) {
              debugPrint(e.toString());
            }
          },
          onError: (code, msg) {
            globalState.isCapture = false;
            try {
              GlobalStore.videoPlayerController?.play();
            } catch (e) {
              debugPrint(e.toString());
            }
          },
        );
      });
    }
  }
}
