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

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:xcam_one/global/constants.dart';

import 'package:xcam_one/models/cmd_status_entity.dart';
import 'package:xcam_one/models/version_entity.dart';
import 'package:xcam_one/net/net.dart';
import 'package:xcam_one/notifiers/camera_state.dart';
import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/pages/setting/setting_router.dart';
import 'package:xcam_one/pages/setting/widgets/picker_text.dart';
import 'package:xcam_one/res/resources.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';
import 'package:xcam_one/utils/bottom_sheet_utils.dart';
import 'package:xcam_one/utils/dialog_utils.dart';

enum AppSetting {
  notice,
  operatingInstructions,
  FAQ,
  termsOfUse,
  privacyPolicy,
  appVersion
}

enum CameraSetting {
  cameraStorage,
  countdownShooting,
  HDR,
  formatCamera,
  IQSetting,
  // UpdateFW,
}

extension AppSettingExt on AppSetting {
  String get text => [
        '通知',
        '操作说明',
        'FAQ',
        '使用条款(用户协议)',
        '隐私政策',
        'APP版本',
      ][index];
}

extension CameraSettingExt on CameraSetting {
  String get text => [
        '相机存储',
        '倒计时拍摄',
        'HDR',
        '格式化相机',
        /* '重置相机设置',*/ 'IQ 设置',
        // '固件升级'
      ][index];
}

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>
    with AutomaticKeepAliveClientMixin {
  /// 默认为HDR未开启，每次连接后需要重置一下参数
  bool _isHDR = false;

  int _currentCountdownIndex = CountdownEnum.close.index;

  /// 每行的高度
  final itemHeight = 44.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _currentCountdownIndex =
          Provider.of<CameraState>(context, listen: false).countdown.index;
      setState(() {});
    });
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
              child: Container(
                color: Colors.white,
                child: Column(
                  children: AppSetting.values.map((value) {
                    VoidCallback? onPressed = () => showToast('功能待实现');
                    switch (value) {
                      case AppSetting.notice:
                        onPressed = () => NavigatorUtils.push(
                            context, '${SettingRouter.sysNotice}');
                        break;
                      case AppSetting.operatingInstructions:
                        // TODO: Handle this case.
                        break;
                      case AppSetting.FAQ:
                        // TODO: Handle this case.
                        break;
                      case AppSetting.termsOfUse:
                        // TODO: Handle this case.
                        break;
                      case AppSetting.privacyPolicy:
                        // TODO: Handle this case.
                        break;
                      case AppSetting.appVersion:
                        onPressed = () => NavigatorUtils.push(
                            context, '${SettingRouter.appVersion}');
                        break;
                    }
                    return _buildTitle(context, value.text,
                        isShowLine: value != AppSetting.appVersion,
                        onPressed: onPressed);
                  }).toList(),
                ),
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
                  return Container(
                    color: Colors.white,
                    child: Column(
                      children: CameraSetting.values.map((value) {
                        VoidCallback? onPressed = () => showToast('功能待实现');
                        switch (value) {
                          case CameraSetting.cameraStorage:
                            onPressed = () => NavigatorUtils.push(
                                context, '${SettingRouter.cameraStorage}');
                            break;
                          case CameraSetting.countdownShooting:
                            onPressed =
                                () => _buildCountdownBottomSheet(context);
                            break;
                          case CameraSetting.HDR:
                            return _buildTitleSwitch(context, value.text,
                                isEnable: globalState.isConnect,
                                switchValue: _isHDR);
                          case CameraSetting.formatCamera:
                            onPressed = () => _buildFormatBottomSheet(context);
                            break;
                          case CameraSetting.IQSetting:
                            onPressed = () => NavigatorUtils.push(
                                context, '${SettingRouter.iQSetting}');
                            break;
                          // case CameraSetting.UpdateFW:
                          //   onPressed =
                          //       () => _buildUpdateFWBottomSheet(context);
                          //   break;
                        }

                        return _buildTitle(context, value.text,
                            isEnable: globalState.isConnect,
                            onPressed: onPressed,
                            isShowLine:
                                value.index != CameraSetting.values.length - 1);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(
    BuildContext context,
    String title, {
    bool isEnable = true,
    bool isShowLine = true,
    VoidCallback? onPressed,
  }) {
    final disableColor = Color(0xFFBFBFBF);

    final line = Divider(color: Color(0x173C3C43));

    return TextButton(
      onPressed: isEnable ? onPressed : null,
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(0)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: itemHeight,
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
          isShowLine ? line : SizedBox(),
        ],
      ),
    );
  }

  void _buildFormatBottomSheet(BuildContext context) {
    showMyBottomSheet(context, '格式化相机后将清除相机内全部图片', okPressed: () {
      NavigatorUtils.goBack(context);
      showMyTwoBottomSheet(context, '格式化相机', okPressed: () {
        DioUtils.instance.requestNetwork<CmdStatusEntity>(
            Method.get, HttpApi.format, onSuccess: (cmdStatusEntity) {
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
  }

  void _buildCountdownBottomSheet(BuildContext context) {
    _currentCountdownIndex =
        Provider.of<CameraState>(context, listen: false).countdown.index;
    showModalBottomSheet(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  Icons.close_outlined,
                  size: 24,
                  color: Colors.black,
                ),
                onPressed: () => NavigatorUtils.goBack(context),
              ),
            ),
            Text(
              '倒计时拍摄',
              style: TextStyles.textBold18.copyWith(color: Colors.black),
            ),
            Container(
              height: 250,
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                    initialItem: _currentCountdownIndex),
                backgroundColor: Colors.white,
                onSelectedItemChanged: (int index) {
                  _currentCountdownIndex = index;
                },
                itemExtent: itemHeight,
                children: CountdownEnum.values
                    .map((e) => PickerText(text: e.text))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                      onPressed: () => NavigatorUtils.goBack(context),
                      style: OutlinedButton.styleFrom(
                        primary: Theme.of(context).accentColor,
                        minimumSize: const Size(90, 40),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(22)),
                        ),
                      ).copyWith(
                        side: MaterialStateProperty.resolveWith<BorderSide>(
                          (Set<MaterialState> states) {
                            /// 状态为按下时则显示主题色线框
                            if (states.contains(MaterialState.pressed)) {
                              return BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1,
                              );
                            } else {
                              return BorderSide(
                                  color: Color(0xFFCFCFCF), width: 1);
                            }
                          },
                        ),
                      ),
                      child: Text(
                        '取消',
                        style:
                            TextStyles.textSize16.copyWith(color: Colors.black),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(left: 35),
                    child: TextButton(
                        onPressed: () {
                          Provider.of<CameraState>(context, listen: false)
                                  .countdown =
                              CountdownEnum.values[_currentCountdownIndex];
                          NavigatorUtils.goBack(context);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          minimumSize: const Size(90, 40),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(22)),
                          ),
                        ),
                        child: Text(
                          '确定',
                          style: TextStyles.textSize16
                              .copyWith(color: Colors.white),
                        )),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  void _buildUpdateFWBottomSheet(BuildContext context) {
    showMyBottomSheet(context, '确定是否更新相机固件', okPressed: () {
      /// 1.检测固件版本
      DioUtils.instance
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
              /// 2.上传固件
              final Map<String, dynamic> map = {};

              final Dio dio = Dio();

              final ByteData byteData =
                  await rootBundle.load('assets/FW/FW96660A.bin');

              map['file'] = MultipartFile.fromBytes(
                  byteData.buffer.asUint8List(),
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
                  showToast('更新失败');
                } else {
                  showToast('更新成功');
                }
              });
            } else {
              showToast('固件已是最新');
            }
          }
        }
      });

      NavigatorUtils.goBack(context);
    });
  }

  Widget _buildTitleSwitch(BuildContext context, String title,
      {bool isEnable = true, required bool switchValue}) {
    final disableColor = Color(0xFFBFBFBF);

    final line = Divider(color: Color(0x173C3C43));

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            height: itemHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: TextStyles.textSize16.copyWith(
                        color: isEnable ? Colors.black : disableColor)),
                (Platform.isIOS || Platform.isMacOS)
                    ? CupertinoSwitch(
                        value: switchValue,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: isEnable
                            ? (value) => _onChanged(value, title)
                            : null)
                    : Switch(
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (bool value) =>
                            isEnable ? _onChanged(value, title) : null,
                        value: switchValue,
                      )
              ],
            ),
          ),
          line,
        ],
      ),
    );
  }

  void _onChanged(value, title) {
    switch (title) {
      case 'HDR':
        {
          /// 开启HDR
          DioUtils.instance.requestNetwork<CmdStatusEntity>(
              Method.get, '${HttpApi.setHDR}${value ? 1 : 0}',
              onSuccess: (cmdStatusEntity) {
            if (cmdStatusEntity?.function?.status == 0) {
              Future.delayed(Duration(seconds: 1), () {
                NavigatorUtils.goBack(context);
                setState(() {
                  _isHDR = value;
                });
              });
            } else {
              NavigatorUtils.goBack(context);
              final String showText = _isHDR ? '关闭HDR失败' : '开启HDR失败';
              showToast(showText);
            }
          }, onError: (code, msg) {
            NavigatorUtils.goBack(context);
            showToast('HDR切换失败，请重试');
          });

          /// 加载模态对话框
          showCupertionLoading(context);
          break;
        }
    }
  }

  @override
  bool get wantKeepAlive => true;
}
