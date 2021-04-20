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
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:xcam_one/models/cmd_status_entity.dart';
import 'package:xcam_one/models/wifi_app_mode_entity.dart';
import 'package:xcam_one/net/net.dart';
import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/res/resources.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';
import 'package:xcam_one/utils/bottom_sheet_utils.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>
    with AutomaticKeepAliveClientMixin {
  List<String> appTitles = ['通知', '操作说明', 'FAQ', '使用条款(用户协议)', '隐私政策', 'APP版本'];
  List<String> cameraTitles = ['相机存储', '倒计时拍摄', 'HDR', '格式化相机', '重置相机', '相机信息'];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text('设置'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Column(
                children: appTitles
                    .map((title) => _buildTitle(context, title))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 12),
              child: Consumer<GlobalState>(
                builder: (
                  BuildContext context,
                  GlobalState globalState,
                  Widget? child,
                ) {
                  return Column(
                    children: cameraTitles.map((title) {
                      if (title == 'HDR') {
                        return _buildTitle(context, title,
                            isEnable: globalState.isConnect);
                      } else {
                        return _buildTitle(context, title,
                            isEnable: globalState.isConnect);
                      }
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String title,
      {bool isEnable = true}) {
    final disableColor = Color(0xFFBFBFBF);

    final line = Divider(color: Color(0x173C3C43));

    return GestureDetector(
      onTap: isEnable
          ? () {
              switch (title) {
                case '格式化相机':
                  {
                    showMyBottomSheet(context, '格式化相机后将清除相机内全部图片',
                        okPressed: () {
                      NavigatorUtils.goBack(context);
                      showMyTwoBottomSheet(context, '格式化相机', okPressed: () {
                        DioUtils.instance.requestNetwork<CmdStatusEntity>(
                            Method.get, HttpApi.format,
                            onSuccess: (cmdStatusEntity) {
                          if (cmdStatusEntity?.function?.status == 0) {
                            showToast('格式化成功');
                          } else {
                            showToast('格式化失败');
                          }
                        }, onError: (code, msg) {
                          showToast('执行格式化操作失败，请重试');
                        });

                        NavigatorUtils.goBack(context);
                      });
                    });
                    break;
                  }
              }
            }
          : null,
      child: Container(
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
                      style: TextStyles.textSize16.copyWith(
                          color: isEnable ? Colors.black : disableColor)),
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
