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

class _CameraPageState extends State<CameraPage>
    with AutomaticKeepAliveClientMixin {
  StreamSubscription<ConnectivityResult>? subscription;

  @override
  void initState() {
    super.initState();

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      debugPrint('result = ${result.toString()}');
      if (ConnectivityResult.wifi == result) {
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
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      child: Consumer<GlobalState>(
          builder: (BuildContext context, globalState, Widget? child) {
            return globalState.isConnect
                ? Container(
                    color: Colors.red,
                  )
                : child!;
          },
          child: CameraConnectPage()),
    );
  }

  @override
  void didUpdateWidget(covariant CameraPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    debugPrint('didUpdateWidget');
  }

  @override
  bool get wantKeepAlive => true;
}
