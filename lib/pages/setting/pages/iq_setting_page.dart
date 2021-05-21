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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:oktoast/oktoast.dart';

import 'package:xcam_one/models/cmd_status_entity.dart';
import 'package:xcam_one/models/iq_info_entity.dart';
import 'package:xcam_one/net/dio_utils.dart';
import 'package:xcam_one/net/net.dart';

import 'package:xcam_one/pages/setting/widgets/picker_text.dart';
import 'package:xcam_one/res/resources.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';
import 'package:xcam_one/utils/dialog_utils.dart';

enum ExposureEnum {
  EV_P20,
  EV_P16,
  EV_P13,
  EV_P10,
  EV_P06,
  EV_P03,
  EV_00,
  EV_N03,
  EV_N06,
  EV_N10,
  EV_N13,
  EV_N16,
  EV_N20,
}

extension ExposureEnumEx on ExposureEnum {
  String get text => [
        '-2.0',
        '-1.6',
        '-1.3',
        '-1.0',
        '-0.6',
        '-0.3',
        '0',
        '0.3',
        '0.6',
        '1.0',
        '1.3',
        '1.6',
        '2.0'
      ][index];
}

enum ISOEnum {
  ISO_AUTO,
  ISO_100,
  ISO_200,
  ISO_400,
  ISO_800,
  ISO_1600,
}

extension ISOEnumEx on ISOEnum {
  String get text => ['Auto', '100', '200', '400', '800', '1600'][index];
}

class IQSettingPage extends StatefulWidget {
  @override
  _IQSettingPageState createState() => _IQSettingPageState();
}

class _IQSettingPageState extends State<IQSettingPage> {
  /// TODO: 2021/5/18 待处理
  int _sliderSharpness = 0;
  int _sliderSaturation = 0;

  ExposureEnum _currentExposure = ExposureEnum.EV_00;
  int _currentExposureIndex = ExposureEnum.EV_00.index;

  ISOEnum _currentISO = ISOEnum.ISO_AUTO;
  int _currentISOIndex = ISOEnum.ISO_AUTO.index;
  bool _sHdrValue = false;
  bool _wdrValue = false;

  bool _isLoading = true;

  final double _rowHeight = 56;

  /// 初始化Slider值，用于错误返回
  int _initSliderValue = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      DioUtils.instance.requestNetwork<IQInfoEntity>(
          Method.get, HttpApi.getIQInfo, onSuccess: (iqInfoEntity) {
        if (iqInfoEntity?.function?.status == 0) {
          _sHdrValue = iqInfoEntity?.function?.shdr == 1;
          _wdrValue = iqInfoEntity?.function?.wdr == 1;
          _sliderSharpness = iqInfoEntity?.function?.sharpness ?? 0;
          _sliderSaturation = iqInfoEntity?.function?.saturation ?? 0;
          if (iqInfoEntity?.function?.ev != null) {
            _currentExposure = ExposureEnum.values[iqInfoEntity!.function!.ev!];
          }
          _currentExposureIndex = _currentExposure.index;

          if (iqInfoEntity?.function?.iso != null) {
            _currentISO = ISOEnum.values[iqInfoEntity!.function!.iso!];
          }
          _currentISOIndex = _currentISO.index;

          setState(() {
            _isLoading = false;
          });
        }
      }, onError: (code, message) {
        showToast('获取相机IQ信息错误');

        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: Center(
          child: SpinKitThreeBounce(
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
      );
    }

    final greyColor = Color(0xFFF2F2F2);
    final line = Divider(color: Color(0x173C3C43));

    return Scaffold(
      backgroundColor: greyColor,
      appBar: AppBar(
        title: Text('IQ 设置'),
        centerTitle: true,
        leading: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => NavigatorUtils.goBack(context),
          child: Icon(
            Icons.arrow_back_ios,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSwitch(context, 'SHDR', _sHdrValue, (value) {
                DioUtils.instance.requestNetwork<CmdStatusEntity>(
                    Method.get, '${HttpApi.setSHDR}${value ? 1 : 0}',
                    onSuccess: (cmdStatusEntity) {
                  if (cmdStatusEntity?.function?.status == 0) {
                    setState(() {
                      /// NOTE: 2021/5/19 待注意 SHDR与WDR互斥，但是可以同时关闭
                      _sHdrValue = value;
                      if(_sHdrValue) {
                        _wdrValue = !_sHdrValue;
                      }
                    });
                    NavigatorUtils.goBack(context);
                  }
                }, onError: (code, message) {
                  showToast('设置SHDR失败');
                  NavigatorUtils.goBack(context);
                });
                showCupertionLoading(context);
              }),
              line,
              _buildSwitch(context, 'WDR', _wdrValue, (value) {
                DioUtils.instance.requestNetwork<CmdStatusEntity>(
                    Method.get, '${HttpApi.setWDR}${value ? 1 : 0}',
                    onSuccess: (cmdStatusEntity) {
                  if (cmdStatusEntity?.function?.status == 0) {
                    setState(() {
                      /// NOTE: 2021/5/19 待注意 SHDR与WDR互斥，但是可以同时关闭
                      _wdrValue = value;
                      if (_wdrValue) {
                        _sHdrValue = !_wdrValue;
                      }
                    });
                    NavigatorUtils.goBack(context);
                  }
                }, onError: (code, message) {
                  showToast('设置WDR失败');
                  NavigatorUtils.goBack(context);
                });
                showCupertionLoading(context);
              }),
              line,
              _buildButton(context, () {
                _currentExposureIndex = _currentExposure.index;
                _buildEVBottomSheet(context);
              }, 'EV', _currentExposure.text),
              line,
              _buildSlider(context, text: 'Saturation', onChanged: (value) {
                setState(() {
                  _sliderSaturation = value.toInt();
                });
              }, onChangeEnd: (value) {
                DioUtils.instance.requestNetwork<CmdStatusEntity>(
                    Method.get, '${HttpApi.setSaturation}$value',
                    onSuccess: (cmdStatusEntity) {
                  if (cmdStatusEntity?.function?.status != 0) {
                    setState(() {
                      _sliderSaturation = _initSliderValue;
                    });
                  }
                  NavigatorUtils.goBack(context);
                }, onError: (code, message) {
                  showToast('设置Saturation失败');
                  setState(() {
                    _sliderSaturation = _initSliderValue;
                  });
                  NavigatorUtils.goBack(context);
                });

                showCupertionLoading(context);
              }, sliderValue: _sliderSaturation),
              line,
              _buildSlider(
                context,
                text: 'Sharpness',
                onChanged: (value) {
                  setState(() {
                    _sliderSharpness = value.toInt();
                  });
                },
                onChangeEnd: (value) {
                  DioUtils.instance.requestNetwork<CmdStatusEntity>(
                      Method.get, '${HttpApi.setSharpness}$value',
                      onSuccess: (cmdStatusEntity) {
                    if (cmdStatusEntity?.function?.status != 0) {
                      setState(() {
                        _sliderSharpness = _initSliderValue;
                      });
                    }
                    NavigatorUtils.goBack(context);
                  }, onError: (code, message) {
                    showToast('设置Sharpness失败');
                    setState(() {
                      _sliderSharpness = _initSliderValue;
                    });
                    NavigatorUtils.goBack(context);
                  });
                  showCupertionLoading(context);
                },
                sliderValue: _sliderSharpness,
              ),
              line,
              _buildButton(context, () {
                _currentISOIndex = _currentISO.index;
                _buildISOBottomSheet(context);
              }, 'ISO', _currentISO.text),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(BuildContext context,
      {required String text,
      required Function(double) onChanged,
      required Function(double) onChangeEnd,
      required int sliderValue}) {
    return Container(
      height: _rowHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(text),
          Expanded(
              child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Theme.of(context).accentColor,
              inactiveTrackColor:
                  Theme.of(context).accentColor.withOpacity(0.3),
              valueIndicatorColor:
                  Theme.of(context).accentColor.withOpacity(0.7),
              overlayColor: Theme.of(context).accentColor.withOpacity(0.3),
              thumbColor: Theme.of(context).accentColor,
            ),
            child: Slider(
              value: sliderValue.toDouble(),
              onChangeEnd: onChangeEnd,
              onChangeStart: (value) {
                _initSliderValue = value.toInt();
              },
              min: 0.0,
              max: 100.0,
              divisions: 100,
              label: sliderValue.toString(),
              onChanged: onChanged,
            ),
          )),
          SizedBox(
            width: 32,
            child: Text('$sliderValue'),
          )
        ],
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, VoidCallback onTap, String title, String text) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        height: _rowHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  child: Text(text),
                ),
                Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Color(0xFFD2D2D2),
                  size: 16,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(BuildContext context, String text, bool value,
      ValueChanged<bool> onChanged) {
    return Container(
      height: _rowHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text),
          (Platform.isIOS || Platform.isMacOS)
              ? CupertinoSwitch(
                  value: value,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: onChanged)
              : Switch(
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: onChanged,
                  value: value,
                )
        ],
      ),
    );
  }

  void _buildEVBottomSheet(BuildContext context) {
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
              'EV',
              style: TextStyles.textBold18.copyWith(color: Colors.black),
            ),
            Container(
              height: 250,
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                    initialItem: _currentExposure.index),
                backgroundColor: Colors.white,
                onSelectedItemChanged: (int index) {
                  _currentExposureIndex = index;
                },
                itemExtent: 44.0,
                children: ExposureEnum.values
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
                          DioUtils.instance.requestNetwork<CmdStatusEntity>(
                              Method.get,
                              '${HttpApi.setEV}$_currentExposureIndex',
                              onSuccess: (cmdStatusEntity) {
                            if (cmdStatusEntity?.function?.status == 0) {
                              setState(() {
                                _currentExposure =
                                    ExposureEnum.values[_currentExposureIndex];
                              });
                              NavigatorUtils.goBack(context);
                              NavigatorUtils.goBack(context);
                            }
                          }, onError: (code, message) {
                            showToast('设置EV失败');
                            NavigatorUtils.goBack(context);
                            NavigatorUtils.goBack(context);
                          });
                          showCupertionLoading(context);
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

  void _buildISOBottomSheet(BuildContext context) {
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
              'ISO',
              style: TextStyles.textBold18.copyWith(color: Colors.black),
            ),
            Container(
              height: 250,
              child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: _currentISO.index),
                backgroundColor: Colors.white,
                onSelectedItemChanged: (int index) {
                  _currentISOIndex = index;
                },
                itemExtent: 44.0,
                children: ISOEnum.values
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
                          DioUtils.instance.requestNetwork<CmdStatusEntity>(
                              Method.get, '${HttpApi.setISO}$_currentISOIndex',
                              onSuccess: (cmdStatusEntity) {
                            if (cmdStatusEntity?.function?.status == 0) {
                              setState(() {
                                _currentISO = ISOEnum.values[_currentISOIndex];
                              });
                              NavigatorUtils.goBack(context);
                              NavigatorUtils.goBack(context);
                            }
                          }, onError: (code, message) {
                            showToast('设置ISO失败');
                            NavigatorUtils.goBack(context);
                            NavigatorUtils.goBack(context);
                          });
                          showCupertionLoading(context);
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
}
