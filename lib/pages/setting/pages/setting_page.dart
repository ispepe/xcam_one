/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'package:flutter/material.dart';
import 'package:xcam_one/res/resources.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  /// TODO: 4/4/21 待处理 临时处理
  final bool isConnect = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text('设置'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: _buildRow('通知'),
          ),
          _buildRow('操作说明'),
          _buildRow('FAQ'),
          _buildRow('使用条款(用户协议)'),
          _buildRow('隐私政策'),
          _buildRow('APP版本'),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: _buildRow('相机存储', color: Color(0xFFBFBFBF)),
          ),
          _buildRow('倒计时拍摄', color: Color(0xFFBFBFBF)),
          _buildRow('HDR', color: Color(0xFFBFBFBF)),
          _buildRow('格式化相机', color: Color(0xFFBFBFBF)),
          _buildRow('相机信息', color: Color(0xFFBFBFBF)),
        ],
      ),
    );
  }

  Container _buildRow(String title, {Color? color}) {
    final line = Divider(color: Color(0x173C3C43));
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: TextStyles.textSize16
                        .copyWith(color: color ?? Colors.black)),
                Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Color(0xFFD2D2D2),
                  size: 16,
                )
              ],
            ),
          ),
          line,
        ],
      ),
    );
  }
}
