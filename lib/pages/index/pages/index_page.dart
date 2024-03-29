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
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:connectivity_plus/connectivity_plus.dart'
    show Connectivity, ConnectivityResult;
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:native_lib/native_lib.dart' as native_lib;
import 'package:oktoast/oktoast.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:ffi/ffi.dart';
import 'package:xcam_one/global/constants.dart';

import 'package:xcam_one/global/global_store.dart';
import 'package:xcam_one/models/capture_entity.dart';
import 'package:xcam_one/models/cmd_status_entity.dart';
import 'package:xcam_one/models/hearbeat_entity.dart';
import 'package:xcam_one/models/notify_status_entity.dart';
import 'package:xcam_one/models/ssid_pass_entity.dart';
import 'package:xcam_one/models/version_entity.dart';
import 'package:xcam_one/models/wifi_app_mode_entity.dart';
import 'package:xcam_one/net/net.dart';
import 'package:xcam_one/notifiers/camera_state.dart';

import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/notifiers/photo_state.dart';
import 'package:xcam_one/pages/camera/pages/camera_page.dart';
import 'package:xcam_one/pages/photo/pages/photo_page.dart';
import 'package:xcam_one/pages/setting/pages/setting_page.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';
import 'package:xcam_one/utils/dialog_utils.dart';
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
      label: '相册',
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
      label: '设置',
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
      label: '相册',
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
      label: '设置',
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
      label: '相册',
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
      label: '设置',
    ),
  ];

  int _currentIndex = 0;

  final _pages = [PhotoPage(), CameraPage(), SettingPage()];

  final Connectivity _connectivity = Connectivity();

  // final WifiInfo _wifiInfo = WifiInfo();

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  late Timer _timer;

  late Timer _batteryCheckTimer;

  late GlobalState _globalState;
  late CameraState _cameraState;

  PageController pageController = PageController();

  late BuildContext _context;

  late native_lib.NativeLibrary nativeLib;
  // late native_lib.StitchLibrary stitchLib;

  void onError(error, StackTrace trace) {
    switchConnect(false, msg: '连接已断开');
  }

  /// 监听相机状态
  void onCameraStatus(jsonData) {
    debugPrint(jsonData.toString());
    final map = parseData(jsonData);
    if (map != null) {
      final notifyStatusEntity = NotifyStatusEntity().fromJson(map);
      switch (notifyStatusEntity.function?.status) {
        case 0:
          // showToast('执行成功');
          break;
        case 1:
          showToast('录制开始');
          break;
        case 2:
          showToast('录制已停止');
          break;
        case 3:
          showToast('正在断开Wi-Fi连接');
          break;
        case 4:
          showToast('已打开麦克风');
          break;
        case 5:
          showToast('已关闭麦克风');
          break;
        case 6:
          showToast('设备正在关机');
          break;
        case 7:
          showToast('新用户正在连接设备，即将断开连接');
          break;
        case -1:
          showToast('没有文件');
          break;
        case -2:
          showToast('文件EXIF错误');
          break;
        case -3:
          showToast('没有缓冲区');
          break;
        case -4:
          showToast('文件为只读');
          break;
        case -5:
          showToast('文件删除错误');
          break;
        case -6:
          showToast('删除失败');
          break;
        case -7:
          showToast('录制存储空间已满');
          break;
        case -8:
          showToast('录制文件写入存储器错误');
          break;
        case -9:
          showToast('Slow card while recording');
          break;
        case -10:
          showToast('电量不足');
          break;
        case -11:
          showToast('存储空间已满');
          break;
        case -12:
          showToast('文件夹已满');
          break;
        case -13:
          showToast('执行错误');
          break;
        case -14:
          showToast('固件校验失败');
          break;
        case -15:
          showToast('固件写入检测失败');
          break;
        case -16:
          showToast('固件写入NAND错误');
          break;
        case -17:
          showToast('读取固件校验失败');
          break;
        case -18:
          showToast('固件不存在或读取错误');
          break;
        case -19:
          showToast('无效的存储源');
          break;
        case -20:
          showToast('固件更新错误代码偏移量');
          break;
        case -21:
          showToast('命令参数错误');
          break;
        case -256:
          showToast('找不到相关命令');
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    nativeLib = native_lib.NativeLibrary();
    // stitchLib = native_lib.StitchLibrary();

    initVlcPlayer();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      initConnectivity();
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

      _timer = Timer.periodic(Duration(seconds: 5), (timer) {
        /// NOTE: 4/9/21 待注意 由于IOS没有Wi-Fi检测的方式方法，则定时检测操作
        if (!kIsWeb && !_globalState.isCapture && mounted) {
          _updateConnectionStatus(ConnectivityResult.none);
        }
      });

      /// 拍照检测一次、进入拍照界面检测一次、每60s检测一次电量
      _batteryCheckTimer = Timer.periodic(Duration(seconds: 60), (timer) {
        if (_globalState.isConnect && !_globalState.isCapture && mounted) {
          _cameraState.batteryLevelCheck();
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
    SocketUtils().dispose();

    await GlobalStore.videoPlayerController?.stopRendererScanning();
    await GlobalStore.videoPlayerController?.dispose();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    /// 判断如果没有连接才进行心跳检测
    if (ConnectivityResult.wifi == result ||
        ConnectivityResult.none == result) {
      if (GlobalStore.startHeartbeat) {
        GlobalStore.startHeartbeat = false;
        await DioUtils.instance.requestNetwork<HearbeatEntity>(
            Method.get, HttpApi.heartbeat, onSuccess: (data) async {
          if (data?.function?.status == '0') {
            if (!_globalState.isConnect) {
              /// 检测固件版本
              if (await _updateFW()) {
                /// 开启第二个定时器，用来检测是否升级成功，直接进入下一步操作
                Timer.periodic(Duration(seconds: 5), (timer) async {
                  /// NOTE: 4/9/21 待注意 由于IOS没有Wi-Fi检测的方式方法，则定时检测操作
                  if (!kIsWeb && !_globalState.isCapture && mounted) {
                    await DioUtils.instance.requestNetwork<HearbeatEntity>(
                        Method.get, HttpApi.heartbeat,
                        onError: (int? code, String? msg) {
                      print('开启心跳检测');
                      GlobalStore.startHeartbeat = true;
                      timer.cancel();
                    });
                  }
                });
                return;
              }

              /// NOTE: 2021/7/13 待注意 获取标定压缩文件，并解压缩至SSID同名目录
              /// 初始化Maps
              await _initMapFiles(onDeon: () {
                _globalState.initType = InitType.init;
                _globalState.isConnect = true;

                /// NOTE: 4/21/21 待注意 模式必须要重置一次，并且不能进行任何切换操作
                showCupertinoLoading(_context);

                /// NOTE: 4/22/21 待注意 添加Socket 初始化操作
                SocketUtils()
                    .initSocket(host: '192.168.1.254', port: 3333)
                    .then((value) {
                  /// 重新添加监听
                  SocketUtils().listen(
                    onCameraStatus,
                    onError,
                  );
                });

                /// NOTE: 4/21/21 待注意 判断当前所在页面：相册页面重置为wifiAppModePlayback，相机为wifiAppModePhoto
                DioUtils.instance.asyncRequestNetwork<WifiAppModeEntity>(
                    Method.get,
                    HttpApi.appModeChange +
                        WifiAppMode.wifiAppModePhoto.index.toString(),
                    onSuccess: (modeEntity) {
                  GlobalStore.wifiAppMode = WifiAppMode.wifiAppModePhoto;

                  /// NOTE: 4/22/21 待注意 断开后，又连接，必须要进行一次初始化操作
                  initVlcPlayer();
                  _cameraState.isShowVLCPlayer = true;

                  /// 计算空间
                  _cameraState.diskSpaceCheck();

                  /// NOTE: 4/21/21 【重置日期】
                  final now = DateTime.now();
                  DioUtils.instance.asyncRequestNetwork<CmdStatusEntity>(
                      Method.get,
                      '${HttpApi.setDate}${now.year}-${now.month}-${now.day}',
                      onSuccess: (dateCmdStatus) {
                    if (dateCmdStatus?.function?.status != 0) {
                      NavigatorUtils.goBack(_context);
                      showToast('初始化日期失败');
                    }
                  }, onError: (code, msg) {
                    NavigatorUtils.goBack(_context);
                    showToast('初始化日期请求失败');
                  });

                  /// NOTE: 4/21/21 【重置时间】
                  DioUtils.instance.asyncRequestNetwork<CmdStatusEntity>(
                      Method.get,
                      '${HttpApi.setTime}${now.hour}:${now.minute}:${now.second}',
                      onSuccess: (timeCmdStatus) {
                    NavigatorUtils.goBack(_context);
                    if (timeCmdStatus?.function?.status != 0) {
                      showToast('初始化时间失败');
                    }
                  }, onError: (code, msg) {
                    NavigatorUtils.goBack(_context);
                    showToast('初始化时间请求失败');
                  });
                }, onError: (code, msg) {
                  /// NOTE: 4/22/21 切换失败实际上依然是处于连接状态，只是播放预览画面出不来
                  _globalState.isConnect = true;
                  _cameraState.diskSpaceCheck();
                  NavigatorUtils.goBack(_context);
                  showToast('切换相机模式失败');
                  _cameraState.isShowVLCPlayer = false;
                });

                GlobalStore.startHeartbeat = true;
              });
            } else {
              GlobalStore.startHeartbeat = true;
            }
          } else {
            await switchConnect(false, msg: '检测连接失败，请检查Wi-Fi是否正确连接');
            GlobalStore.startHeartbeat = true;
          }
        }, onError: (e, m) async {
          if (_globalState.isConnect) {
            /// TODO: 4/22/21 待处理 确认为掉线
            await Future.delayed(Duration(seconds: 1), () async {
              await DioUtils.instance.requestNetwork<HearbeatEntity>(
                  Method.get, HttpApi.heartbeat, onError: (e, m) async {
                await switchConnect(false, msg: '设备掉线，请重新连接');
              });
            });
          }
          GlobalStore.startHeartbeat = true;
        });
      }
    } else {
      /// NOTE: 2021/7/13 待注意 wifi链接不稳定，会导致突然断开链接，进行两次检测
      if (_globalState.isConnect) {
        await Future.delayed(Duration(seconds: 1), () async {
          await DioUtils.instance.requestNetwork<HearbeatEntity>(
              Method.get, HttpApi.heartbeat, onError: (e, m) async {
            await switchConnect(false, msg: 'wifi连接中断');
          });
        });
      } else {
        await switchConnect(false, msg: 'wifi连接中断');
      }
    }
  }

  Future<void> _initMapFiles({required Function() onDeon}) async {
    _globalState.initType = InitType.checkMaps;

    /// NOTE: 2021/7/13 待注意 获取标定压缩文件，并解压缩至SSID同名目录
    return DioUtils.instance.requestNetwork<SsidPassEntity>(
        Method.get, HttpApi.getSSIDAndPassphrase, onSuccess: (ssidPassEntity) {
      if (_globalState.currentSSID != ssidPassEntity?.xLIST?.sSID) {
        _globalState.currentSSID = ssidPassEntity?.xLIST?.sSID ?? 'xCam_one';
      }

      final savePath =
          '${GlobalStore.applicationPath}/${_globalState.currentSSID}/';
      final saveZipPath =
          '${GlobalStore.applicationPath}/${_globalState.currentSSID}/Maps.zip';
      if (!File('${savePath}Maps/maps_size').existsSync()) {
        _globalState.initType = InitType.downMaps;
        final url = '${GlobalStore.config[EConfig.baseUrl]}Maps.zip';
        final Dio dio = Dio();
        dio
            .download(url, '$saveZipPath',
                onReceiveProgress: true
                    ? null
                    : (received, total) {
                        if (total != -1) {
                          ///当前下载的百分比例
                          print((received / total * 100).toStringAsFixed(0) +
                              '%');
                        }
                      })
            .then((value) {
          _globalState.initType = InitType.zipDecoderMaps;
          final file = File('$saveZipPath');
          final fileBytes = file.readAsBytesSync();
          final archive = ZipDecoder().decodeBytes(fileBytes);
          for (final file in archive) {
            final filename = file.name;
            if (file.isFile) {
              final data = file.content as List<int>;
              File('$savePath' + filename)
                ..createSync(recursive: true)
                ..writeAsBytesSync(data);
            } else {
              Directory('$savePath' + filename).createSync(recursive: true);
            }
          }
          onDeon();
        });
      } else {
        onDeon();
      }
    });
  }

  /// 更新固件，返回是否有更新
  Future<bool> _updateFW() async {
    /// NOTE: 2021/8/1 待注意 更新成功或者更新失败都返回false
    bool retValue = true;

    /// 1.检测固件版本
    await DioUtils.instance
        .requestNetwork<VersionEntity>(Method.get, HttpApi.queryVersion,
            onSuccess: (VersionEntity? value) async {
      if (value?.function?.status == 0) {
        final String version = value!.function!.version!;
        // 解析版本号 xCam_0729_005
        final List<String> versionValues = version.split(r'_');
        final List<String> myVersionValue = Constant.FWString.split(r'_');
        if (versionValues[0] != myVersionValue[0]) {
          showToast('固件厂商不匹配，固件更新失败');
        } else {
          // 检测固件是否需要升级
          final int date = int.parse(versionValues[1]);
          final int myDate = int.parse(myVersionValue[1]);
          bool isUpdate = false;
          if (myDate > date) {
            isUpdate = true;
          } else if (date == myDate) {
            final int versionNum = int.parse(versionValues[2]);
            final int myVersionNum = int.parse(myVersionValue[2]);
            if (myVersionNum > versionNum) {
              isUpdate = true;
            }
          }

          if (isUpdate) {
            _globalState.initType = InitType.updateFW;

            /// 2.上传固件
            final Map<String, dynamic> map = {};

            final Dio dio = Dio();

            final ByteData byteData =
                await rootBundle.load('assets/FW/FW96660A.bin');

            map['file'] = MultipartFile.fromBytes(byteData.buffer.asUint8List(),
                filename: 'FW96660A.bin');

            ///通过FormData
            final FormData formData = FormData.fromMap(map);

            // netUploadUrl
            await dio.post(
              'http://192.168.1.254',
              data: formData,
              // onSendProgress: (int progress, int total) {
              //   print('当前进度是 $progress 总进度是 $total');
              // },
            );

            /// 3.固件升级
            await DioUtils.instance.requestNetwork<CmdStatusEntity>(
                Method.get, HttpApi.firmwareUpdate,
                onSuccess: (CmdStatusEntity? statusEntity) {
              if (statusEntity?.function?.status != 0) {
                showToast('固件更新失败');
              } else {
                showToast('固件更新成功');
              }
            });
            _globalState.initType = InitType.reconnect;
          } else {
            retValue = false;
          }
        }
      }
    });

    return Future.value(retValue);
  }

  Future switchConnect(bool isConnect, {String? msg}) async {
    if (_globalState.isConnect != isConnect) {
      if (msg != null) showToast(msg);

      _globalState.isConnect = false;
      _globalState.initType = InitType.connect;
      _cameraState.clearSpaceData();
      try {
        final bool? isPlay =
            await GlobalStore.videoPlayerController?.isPlaying();
        if (isPlay ?? false) {
          await GlobalStore.videoPlayerController?.stop();
        }
      } catch (e) {
        e.toString();
      }

      // 关闭socket
      SocketUtils().dispose();
      _cameraState.isShowVLCPlayer = false;
    }
  }

  @override
  void didUpdateWidget(IndexPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      try {
        /// 防止热加载丢画面
        GlobalStore.videoPlayerController?.stop().then((value) {
          GlobalStore.videoPlayerController?.play();
        });
      } catch (e) {
        debugPrint(e.toString());
      }
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
    _globalState = context.read<GlobalState>();
    _cameraState = context.read<CameraState>();

    _context = context;
    final watchGlobalState = context.watch<GlobalState>();
    final watchPhotoState = context.watch<PhotoState>();

    return Scaffold(
      /// NOTE: 4/19/21 待注意 此处不加背景，会导致拍摄时底部bar有灰色边框
      backgroundColor: watchGlobalState.isConnect && _currentIndex == 1
          ? Colors.black
          : Colors.white,
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
      bottomNavigationBar: watchPhotoState.isMultipleSelect
          ? null
          : BottomNavigationBar(
              backgroundColor: watchGlobalState.isConnect && _currentIndex == 1
                  ? Colors.black
                  : Colors.white,
              items: watchGlobalState.isConnect && _currentIndex == 1
                  ? watchGlobalState.isCapture
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
    if (_globalState.isCapture) {
      showToast('拍摄中，请稍等');
      return;
    }

    if (index != _currentIndex) {
      /// TODO: 4/17/21 快速点击拍摄存在异常，不止是从相册界面切换回来
      if (index == 1 && _globalState.isConnect) {
        /// 立即进行一次电量检测
        _cameraState.batteryLevelCheck();

        /// NOTE: 4/21/21 待注意 按理说每次拍照结束后都需要进行一次检测,但是可以通过异常状态检测获取是否空间够用
        _cameraState.diskSpaceCheck();

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
      // 1 表示已进入相机界面，二次点击开始拍照
    } else if (index == 1 && _globalState.isConnect) {
      try {
        /// NOTE: 4/21/21 待注意 如果画面还在加载中，应该返回
        GlobalStore.videoPlayerController?.isPlaying().then((isPlaying) {
          if (isPlaying != null && !isPlaying) {
            showToast('画面正在加载中，请稍后进行拍摄');
          } else {
            // globalState.batteryStatus == BatteryStatus.batteryLow
            // if (cameraState.batteryStatus == BatteryStatus.batteryEmpty ||
            //     cameraState.batteryStatus == BatteryStatus.batteryExhausted) {
            //   showToast('低电量，拍摄失败');
            // } else
            if (_cameraState.countdown != CountdownEnum.close) {
              showCupertinoDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return Center(
                      child: IgnorePointer(
                        child: Material(
                          color: Colors.transparent,
                          child: Center(
                            child: CircularCountDownTimer(
                              duration: _cameraState.countdown.value,
                              initialDuration: 0,
                              controller: CountDownController(),
                              width: 64,
                              height: 64,
                              ringColor: Colors.grey,
                              ringGradient: null,
                              fillColor: Theme.of(context).primaryColor,
                              fillGradient: null,
                              backgroundColor: Colors.black45,
                              backgroundGradient: null,
                              strokeWidth: 20.0,
                              strokeCap: StrokeCap.round,
                              textStyle: TextStyle(
                                  fontSize: 33.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textFormat: CountdownTextFormat.S,
                              isReverse: false,
                              isReverseAnimation: false,
                              isTimerTextShown: true,
                              autoStart: true,
                              onStart: () {
                                print('Countdown Started');
                              },
                              onComplete: () {
                                NavigatorUtils.goBack(context);
                                _capture();
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  });
            } else {
              _capture();
            }
          }
        });
      } catch (e) {
        showToast('播放器正在初始化，请稍后拍摄');
        e.toString();
      }
    }
  }

  void _capture() {
    // 1 表示已进入相机界面，二次点击开始拍照
    _cameraState.captureType = '拍摄中';
    _globalState.isCapture = true;
    GlobalStore.videoPlayerController?.stop().then((value) {
      DioUtils.instance.asyncRequestNetwork<CaptureEntity>(
        Method.get,
        HttpApi.capture,
        onSuccess: (data) {
          final status = data?.function?.status ?? '';
          switch (int.parse(status)) {
            case 0:
              _saveImage(data!.function!.file, () {
                _globalState.isCapture = false;
                try {
                  GlobalStore.videoPlayerController?.play();
                } catch (e) {
                  debugPrint(e.toString());
                }
              });
              return;
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

          _globalState.isCapture = false;
          try {
            GlobalStore.videoPlayerController?.play();
          } catch (e) {
            debugPrint(e.toString());
          }
        },
        onError: (code, msg) {
          _globalState.isCapture = false;
          try {
            GlobalStore.videoPlayerController?.play();
          } catch (e) {
            debugPrint(e.toString());
          }
        },
      );
    });
  }

  Future<void> _saveImage(List<CaptureFunctionFile>? files, onDone) async {
    if (files != null) {
      final List<String> destFiles = [];
      final savePath =
          '${GlobalStore.applicationPath}/${_globalState.currentSSID}/';
      files.forEach((element) async {
        String filePath = element.fPATH ?? '';
        filePath = filePath.substring(3, filePath.length);
        filePath = filePath.replaceAll('\\', '/');
        final url = '${GlobalStore.config[EConfig.baseUrl]}$filePath';

        _cameraState.captureType = '下载中';
        final Dio dio = Dio();
        await dio
            .download(url, '$savePath${element.nAME}'
                /** onReceiveProgress: (received, total) {
              if (total != -1) {
              ///当前下载的百分比例
              print(element.nAME! +
              (received / total * 100).toStringAsFixed(0) +
              '%');
              }
              } **/
                )
            .then((value) async {
          destFiles.add('$savePath${element.nAME}');
          if (destFiles.length == 2) {
            _cameraState.captureType = '缝合中';
            final mapPath =
                '${GlobalStore.applicationPath}/${_globalState.currentSSID}/Maps/';

            /// NOTE: 2021/8/1 待注意 AB面缝合图片必须要有次序
            final bool isSwap = destFiles[1].toLowerCase().endsWith('a.jpg');

            /// 2.进行缝合
            final int result = nativeLib.fuse(
                isSwap
                    ? destFiles[1].toNativeUtf8().cast<ffi.Int8>()
                    : destFiles[0].toNativeUtf8().cast<ffi.Int8>(),
                isSwap
                    ? destFiles[0].toNativeUtf8().cast<ffi.Int8>()
                    : destFiles[1].toNativeUtf8().cast<ffi.Int8>(),
                mapPath.toNativeUtf8().cast<ffi.Int8>(),
                ('${mapPath}vignet.txt').toNativeUtf8().cast<ffi.Int8>(),
                ('${savePath}fuse.jpg').toNativeUtf8().cast<ffi.Int8>());
            print('返回状态:$result');
            if (result != 1) {
              showToast('保存失败');
              if (onDone != null) {
                onDone();
              }
            } else {
              /// 3.回传图片至全景相机
              destFiles[0].toLowerCase();

              final filename = element.nAME!
                  .replaceRange(element.nAME!.length - 5, null, '.jpg');

              final Map<String, dynamic> map = {};
              map['image'] = await MultipartFile.fromFile('${savePath}fuse.jpg',
                  filename: filename);

              ///通过FormData
              final FormData formData = FormData.fromMap(map);
              // netUploadUrl
              await dio.post(
                'http://192.168.1.254/NOVATEK/PHOTO/',
                data: formData,
                // onSendProgress: (int progress, int total) {
                //   print('当前进度是 $progress 总进度是 $total');
                // },
              );

              /// 4.保存图片至相册
              await PhotoManager.editor
                  .saveImageWithPath('${savePath}fuse.jpg')
                  .then((asset) {
                if (asset != null) {
                  // showToast('保存成功');
                  showToast('拍摄成功,请在相册中查看');
                } else {
                  showToast('保存失败');
                }

                if (onDone != null) {
                  onDone();
                }
              });
            }
          }
        });
      });
    }
  }
}
