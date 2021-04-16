/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:xcam_one/global/global_store.dart';

import 'package:xcam_one/models/camera_file_entity.dart';
import 'package:xcam_one/models/wifi_app_mode_entity.dart';
import 'package:xcam_one/net/net.dart';
import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/pages/photo_view/photo_view_router.dart';

import 'package:xcam_one/res/styles.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';
import 'package:xcam_one/widgets/my_button.dart';

class CameraPhotoPage extends StatefulWidget {
  @override
  _CameraPhotoPageState createState() => _CameraPhotoPageState();
}

class _CameraPhotoPageState extends State<CameraPhotoPage>
    with AutomaticKeepAliveClientMixin {
  bool _isShowLoading = true;

  late GlobalState globalState;

  /// 获取全景相机
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      /// TODO: 4/16/21 待处理 增加刷新操作
      if (GlobalStore.wifiAppMode != WifiAppMode.wifiAppModePlayback) {
        GlobalStore.videoPlayerController?.stop();
        DioUtils.instance.requestNetwork<WifiAppModeEntity>(
            Method.get,
            HttpApi.appModeChange +
                WifiAppMode.wifiAppModePlayback.index.toString(),
            onSuccess: (modeEntity) {
          /// NOTE: 4/12/21 必须要切换到WifiAppMode.wifiAppModeMovie才能进行正确获取
          GlobalStore.wifiAppMode = WifiAppMode.wifiAppModePlayback;
          _getFileList();
        }, onError: (code, msg) {
          debugPrint('code: $code, message: $msg');
        });
      } else {
        _getFileList();
      }
    });
  }

  Future<void> _getFileList() async {
    DioUtils.instance.asyncRequestNetwork<CameraFileListEntity>(
        Method.get, HttpApi.getFileList, onSuccess: (data) {
      globalState.allFile = data?.list?.allFile;

      setState(() {
        _isShowLoading = false;
      });
    }, onError: (code, message) {
      debugPrint('code: $code, message: $message');
      setState(() {
        _isShowLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    globalState = context.watch<GlobalState>();

    if (globalState.isConnect) {
      return _buildCameraPhoto(context);
    } else {
      return _buildConnectCamera(context);
    }
  }

  Container _buildConnectCamera(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/images/camera_01.png',
                            width: 32,
                            height: 48,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SpinKitThreeBounce(
                              color: Color(0xFFB3B3B3),
                              size: 24,
                            )),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/images/camera_02.png',
                            width: 48,
                            height: 38,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '未读取到任何数据 \n请连接相机',
                      textAlign: TextAlign.center,
                      style: TextStyles.textSize14
                          .copyWith(color: Color(0xFFBFBFBF)),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 140.0),
                child: MyButton(
                    minWidth: 248,
                    onPressed: () {
                      AppSettings.openWIFISettings();
                    },
                    buttonText: '去连接'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPhoto(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_isShowLoading) {
      return Container(
        height: size.height,
        width: size.width,
        child: Center(
            child: SpinKitThreeBounce(
          color: Theme.of(context).accentColor,
          size: 48,
        )),
      );
    }

    return Container(
      child: globalState.groupFileList != null
          ? ListView.builder(
              itemCount: globalState.groupFileList?.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final keys = globalState.groupFileList?.keys.toList();
                return _buildPhotoGroup(context, keys![index], index);
              },
            )
          : Container(),
    );
  }

  Widget _buildPhotoGroup(BuildContext context, String key, int groupIndex) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            key,
            style: TextStyles.textSize16.copyWith(color: Colors.black),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: globalState.groupFileList != null &&
                  globalState.groupFileList![key] != null
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: globalState.groupFileList![key]!.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    int currentIndex = 0;
                    final List<String> keys =
                        globalState.groupFileList!.keys.toList();
                    for (int i = 0; i < keys.length; i++) {
                      if (keys[i].contains(key)) {
                        currentIndex += index;
                        break;
                      }
                      currentIndex +=
                          globalState.groupFileList![keys[i]]!.length;
                    }

                    return _buildPhoto(
                      context,
                      globalState.groupFileList![key]![index],
                      currentIndex,
                    );
                  })
              : Container(),
        ),
      ],
    );
  }

  Widget _buildPhoto(BuildContext context, CameraFile cameraFile, int index) {
    String filePath = cameraFile.file!.filePath!
        .substring(3, cameraFile.file!.filePath!.length);
    filePath = filePath.replaceAll('\\', '/');

    final url =
        '${GlobalStore.config[EConfig.baseUrl]}$filePath${HttpApi.getThumbnail}'; // ignore: lines_longer_than_80_chars

    return GestureDetector(
      onTap: () {
        NavigatorUtils.push(context,
            '${PhotoViewRouter.photoView}?currentIndex=$index&type=camera');
      },
      child: CachedNetworkImage(
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: (BuildContext context, url) {
          return Center(
              child: SpinKitCircle(
            color: Theme.of(context).accentColor,
            size: 24,
          ));
        },
        errorWidget: (context, url, error) => Icon(Icons.photo_outlined),
        imageUrl: Uri.encodeFull(url),
      ),
    );
  }

  @override
  bool get wantKeepAlive => false;
}
