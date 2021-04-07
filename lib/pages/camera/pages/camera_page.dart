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

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:xcam_one/global/global_store.dart';
import 'package:xcam_one/models/battery_level_entity.dart';

import 'package:xcam_one/models/version_entity.dart';
import 'package:xcam_one/models/wifi_app_mode_entity.dart';
import 'package:xcam_one/net/net.dart';
import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/pages/camera_connect/pages/camera_connect_page.dart';
import 'package:xcam_one/res/styles.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();

    GlobalStore.videoPlayerController = VlcPlayerController.network(
      HttpApi.rtsp,
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

    // if (!GlobalStore.videoPlayerController!.value.isInitialized) {
    //   GlobalStore.videoPlayerController?.initialize();
    // }
  }

  @override
  void dispose() async {
    super.dispose();

    await GlobalStore.videoPlayerController?.stopRendererScanning();
    await GlobalStore.videoPlayerController?.dispose();
    GlobalStore.videoPlayerController = null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: Consumer<GlobalState>(
          builder: (BuildContext context, globalState, Widget? child) {
            return globalState.isConnect
                ? Scaffold(
                    backgroundColor: Colors.black,
                    appBar: AppBar(
                      backgroundColor: Colors.black,
                      title: Text('xCam One',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                      centerTitle: true,
                    ),
                    body: Column(children: [
                      _buildCamera(context),
                      _buildCameraStatus(context)
                    ]))
                : child!;
          },
          child: CameraConnectPage()),
    );
  }

  Container _buildCameraStatus(BuildContext context) {
    final globalState = context.watch<GlobalState>();
    final width = MediaQuery.of(context).size.width * 0.9;

    final textStyle = TextStyles.textSize12.copyWith(color: Color(0xFF999999));

    return Container(
      padding: const EdgeInsets.only(top: 8),
      width: width,
      child: Column(
        children: [
          Row(
            children: [
              Image.asset('assets/images/wifi.png', width: 32, height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: globalState.isConnect
                    ? Text(
                        '已连接',
                        style: textStyle,
                      )
                    : Text(
                        '未连接',
                        style: textStyle,
                      ),
              ),
              Expanded(
                child: SizedBox(),
              ),
              _buildBatteryStatus(context)
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Container(
              width: width,
              height: 4,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  color: Color(0x33787880),
                  borderRadius: BorderRadius.all(Radius.circular(3))),
              child: Container(
                width: width * 0.5,
                decoration: BoxDecoration(
                    color: Color(0xFF00BBD4),
                    borderRadius: BorderRadius.all(Radius.circular(3))),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Text(
                  '可用存储空间',
                  style: textStyle,
                ),
                Expanded(
                  child: SizedBox(),
                ),
                RichText(
                  text: TextSpan(text: '28GB', style: textStyle, children: [
                    TextSpan(
                        text: '/128GB',
                        style: textStyle.copyWith(
                          fontSize: 8,
                        ))
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _buildBatteryStatus(BuildContext context) {
    double batteryWidth = 0;
    final _batteryStatus = context.read<GlobalState>().batteryStatus;
    switch (_batteryStatus) {
      case BatteryStatus.batteryMed:
        batteryWidth = 22 * 0.5;
        break;
      case BatteryStatus.batteryFull:
        batteryWidth = 22;
        break;
      case BatteryStatus.batteryLow:
        batteryWidth = 22 * 0.2;
        break;
      case BatteryStatus.batteryEmpty:
        batteryWidth = 22 * 0.1;
        break;
      case BatteryStatus.batteryExhausted:
      case BatteryStatus.batteryCharge:
      case BatteryStatus.batteryStatusTotalNum:
        batteryWidth = 0;
        break;
    }

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(top: 11, bottom: 12, left: 4, right: 6),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: _batteryStatus == BatteryStatus.batteryMed ||
                      _batteryStatus == BatteryStatus.batteryFull
                  ? AssetImage('assets/images/battery.png')
                  : (_batteryStatus == BatteryStatus.batteryCharge
                      ? AssetImage('assets/images/battery_charge.png')
                      : AssetImage('assets/images/battery_low.png')),
              fit: BoxFit.fill)),
      child: Container(
        width: batteryWidth,
        decoration: BoxDecoration(
            color: _batteryStatus == BatteryStatus.batteryMed ||
                    _batteryStatus == BatteryStatus.batteryFull
                ? Colors.white
                : Colors.red,
            borderRadius: BorderRadius.all(Radius.circular(1.33))),
      ),
    );
  }

  Container _buildCamera(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: Color(0xFF686868),
      height: size.width / 2,
      width: size.width,
      child: (GlobalStore.videoPlayerController != null
          ? Stack(
              children: [
                VlcPlayer(
                  aspectRatio: 2 / 1,
                  controller: GlobalStore.videoPlayerController!,
                  placeholder: Center(child: CircularProgressIndicator()),
                ),
                Provider.of<GlobalState>(context).isCapture
                    ? _buildCaptureInfo()
                    : SizedBox()
              ],
            )
          : SizedBox()),
    );
  }

  Center _buildCaptureInfo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '拍摄中',
                style: TextStyles.textBold20.copyWith(
                  color: Colors.white,
                ),
              ),
              SpinKitThreeBounce(
                color: Colors.white,
                size: 24,
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1.尽量把相机放置在拍摄环境的中央位置',
                style: TextStyles.textSize12.copyWith(color: Colors.white),
              ),
              Text(
                '2.请拍摄人员不要在拍摄画面内',
                style: TextStyles.textSize12.copyWith(color: Colors.white),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
