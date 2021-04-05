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

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:xcam_one/models/version_entity.dart';
import 'package:xcam_one/net/net.dart';

import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/pages/camera_connect/pages/camera_connect_page.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  StreamSubscription<ConnectivityResult>? subscription;

  VlcPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      debugPrint('网络连接：${result.toString()}');
      if (ConnectivityResult.wifi == result) {
        _videoPlayerController = VlcPlayerController.network(
          'rtsp://192.168.1.254/xxxx.mp4',
          hwAcc: HwAcc.FULL,
          autoPlay: true,
          options: VlcPlayerOptions(),
        );

        DioUtils.instance.requestNetwork<VersionEntity>(
          Method.get,
          HttpApi.queryVersion,
          onSuccess: (data) {
            Provider.of<GlobalState>(context, listen: false).cameraVersion =
                data?.function?.version ?? '';

            Provider.of<GlobalState>(context, listen: false).isConnect = true;
          },
        );
      } else {
        Provider.of<GlobalState>(context, listen: false).isConnect = false;
      }
    });
  }

  @override
  void dispose() async {
    super.dispose();

    await subscription?.cancel();
    await _videoPlayerController?.stopRendererScanning();
    await _videoPlayerController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Consumer<GlobalState>(
          builder: (BuildContext context, globalState, Widget? child) {
            return globalState.isConnect ? _buildCamera() : child!;
          },
          child: CameraConnectPage()),
    );
  }

  Container _buildCamera() {
    return Container(
      color: Colors.red,
      child: _videoPlayerController == null
          ? SizedBox()
          : VlcPlayer(
              aspectRatio: 2 / 1,
              controller: _videoPlayerController!,
              placeholder: Center(child: CircularProgressIndicator()),
            ),
    );
  }

  @override
  void didUpdateWidget(covariant CameraPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('didUpdateWidget');
  }
}
