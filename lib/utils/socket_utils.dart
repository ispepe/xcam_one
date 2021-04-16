/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'dart:io';
import 'dart:async';

import 'package:xcam_one/utils/log_utils.dart';

class SocketUtils {
  SocketUtils._(this._host, this._port);

  factory SocketUtils(host, port) {
    _singleton ??= SocketUtils._(host, port);
    return _singleton!;
  }

  static SocketUtils? _singleton;

  final String _host;

  final int _port;

  late Socket clientSocket;
  late Stream<List<int>> socketStream;

  Future<void> initSocket() async {
    await Socket.connect(_host, _port).then((Socket socket) {
      clientSocket = socket;
      socketStream =
          clientSocket.asBroadcastStream(); //多次订阅的流 如果直接用socket.listen只能订阅一次
    }).catchError((e) {
      Log.e('socket connectException:$e');
    });
  }

  void dispose() {
    clientSocket.close();
  }
}
