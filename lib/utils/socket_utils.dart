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
import 'dart:typed_data';

import 'package:xcam_one/utils/log_utils.dart';
import 'package:xml2json/xml2json.dart';

class SocketUtils {
  SocketUtils._(this._host, this._port);

  factory SocketUtils() {
    _singleton ??= SocketUtils._('192.168.1.254', 3333);
    return _singleton!;
  }

  Timer? _timer;

  static SocketUtils? _singleton;

  String _host;

  int _port;

  late Socket _clientSocket;

  void Function(dynamic event)? _notification;

  // final List<void Function(dynamic event)?> _listEvent = [];

  Future<void> initSocket({String? host, int? port}) async {
    _host = host ?? _host;
    _port = port ?? _port;

    await Socket.connect(_host, _port).then((Socket socket) {
      _clientSocket = socket;

      // _socketStream =
      //     _clientSocket.asBroadcastStream(); //多次订阅的流 如果直接用socket.listen只能订阅一次

      // 每秒发一次心跳请求
      // heartbeat();
    }).catchError((e) {
      Log.e('socket connectException:$e');
    });
  }

  void heartbeat() {
    _timer?.cancel();

    // 每秒发一次心跳请求
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      final msg = ByteData(4);
      msg.setInt16(0, 3016);
      try {
        _clientSocket.add(msg.buffer.asUint8List());
      } catch (e) {
        print("心跳检测失败");
      }
    });
  }

  /// 断开Wi-Fi、关机需要关闭Socket
  void dispose() {
    _clientSocket.close();
    // _timer?.cancel();
  }

  /// 双向销毁
  // void destroy() {
  //   _clientSocket.destroy();
  // }

  void onHandle(event) {
    /// 将xml解析为json数据，传出
    final bytes = Int8List.fromList(event);
    String content = String.fromCharCodes(bytes);
    if (content.startsWith('<?xml')) {
      Log.xmlString(content);
      final _myTransformer = Xml2Json();
      _myTransformer.parse(content);
      content = _myTransformer.toParker();
    } else {
      Log.e('非xml格式，错误返回');
    }

    if (_notification != null) {
      _notification!(content);
    }
  }

  void listen(void Function(dynamic event)? onHandle, onError) {
    _notification = onHandle;
    _clientSocket.listen(this.onHandle,
        onError: onError, cancelOnError: false);
  }
}
