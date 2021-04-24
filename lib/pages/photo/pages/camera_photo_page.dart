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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'package:xcam_one/global/global_store.dart';
import 'package:xcam_one/models/camera_file_entity.dart';
import 'package:xcam_one/models/wifi_app_mode_entity.dart';
import 'package:xcam_one/net/net.dart';
import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/notifiers/photo_state.dart';
import 'package:xcam_one/pages/photo/widgets/empty_photo.dart';
import 'package:xcam_one/pages/photo_view/photo_view_router.dart';

import 'package:xcam_one/res/styles.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';
import 'package:xcam_one/utils/dialog_utils.dart';
import 'package:xcam_one/widgets/my_button.dart';

class CameraPhotoPage extends StatefulWidget {
  @override
  _CameraPhotoPageState createState() => _CameraPhotoPageState();
}

class _CameraPhotoPageState extends State<CameraPhotoPage>
    with AutomaticKeepAliveClientMixin {
  late PhotoState watchPhotoState;

  late EasyRefreshController _refreshController;

  /// 固定为20个
  final int showUnit = 20;

  /// 获取全景相机
  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if(Provider.of<GlobalState>(context, listen: false).isConnect) {
        _onRefresh();
      }
    });
  }

  Future<void> _onRefresh() async {
    try {
      final bool? isPlay = await GlobalStore.videoPlayerController?.isPlaying();
      if (isPlay ?? false) {
        await GlobalStore.videoPlayerController?.stop();
      }
    } catch (e) {
      e.toString();
    }

    /// 加载模态对话框
    showCupertinoLoading(context);

    await DioUtils.instance.requestNetwork<WifiAppModeEntity>(
        Method.get,
        HttpApi.appModeChange +
            WifiAppMode.wifiAppModePlayback.index.toString(),
        onSuccess: (modeEntity) async {
      /// NOTE: 4/12/21 必须要切换到WifiAppMode.wifiAppModeMovie才能进行正确获取
      GlobalStore.wifiAppMode = WifiAppMode.wifiAppModePlayback;

      await DioUtils.instance.requestNetwork<CameraFileListEntity>(
          Method.get, HttpApi.getFileList, onSuccess: (data) async {
        data?.list?.allFile?.sort((s1, s2) {
          return int.parse(s2.file?.timeCode ?? '0')
              .compareTo(int.parse(s1.file?.timeCode ?? '0'));
        });

        final photoState = Provider.of<PhotoState>(context, listen: false);

        /// NOTE: 4/17/21 待注意 内部会进行分组
        photoState.currentCount = showUnit;
        photoState.allFile = (data?.list?.allFile);

        NavigatorUtils.goBack(context);

        /// 必须刷新一次
        // setState(() {});
      }, onError: (code, message) {
        NavigatorUtils.goBack(context);
        showToast('获取文件失败，请重试');
      });
    }, onError: (code, msg) {
      NavigatorUtils.goBack(context);
      showToast('相机模式切换失败，请重试');
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    watchPhotoState = context.watch<PhotoState>();

    if (context.watch<GlobalState>().isConnect) {
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
    return Container(
      child: EasyRefresh(
        controller: _refreshController,
        enableControlFinishRefresh: false,
        enableControlFinishLoad: true,
        header: ClassicalHeader(
            refreshText: '下拉刷新',
            refreshReadyText: '松开刷新',
            refreshingText: '刷新中...',
            refreshedText: '刷新成功',
            refreshFailedText: '刷新失败',
            textColor: Theme.of(context).primaryColor,
            showInfo: false,
            infoText: '刷新时间 %T',
            infoColor: Theme.of(context).accentColor),
        footer: BallPulseFooter(
          color: Theme.of(context).primaryColor,
        ),
        onRefresh: () async {
          await _onRefresh();
          _refreshController.resetLoadState();
        },
        onLoad: () async {
          await Future.delayed(Duration(milliseconds: 200), () {
            watchPhotoState.currentCount += 20;

            /// 根据当前显示数量进行分组
            watchPhotoState.groupByCameraFile();

            _refreshController.finishLoad(
                noMore: watchPhotoState.currentCount ==
                    (watchPhotoState.allFile?.length ?? 0));
          });
        },
        child: watchPhotoState.allFile?.isEmpty ?? true
            ? buildEmptyPhoto(
                context,
                text: '您还没有全景图片快去拍摄吧',
              )
            : ListView.builder(
                itemCount: watchPhotoState.groupFileList?.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final keys = watchPhotoState.groupFileList?.keys.toList();
                  return _buildPhotoGroup(context, keys![index]);
                },
              ),
      ),
    );
  }

  Widget _buildPhotoGroup(BuildContext context, String key) {
    final int length = watchPhotoState.groupFileList![key]!.length;
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
            child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemBuilder: (BuildContext context, int index) {
                  int currentIndex = 0;
                  final List<String> keys =
                      watchPhotoState.groupFileList!.keys.toList();
                  for (int i = 0; i < keys.length; i++) {
                    if (keys[i].contains(key)) {
                      currentIndex += index;
                      break;
                    }
                    currentIndex +=
                        watchPhotoState.groupFileList![keys[i]]!.length;
                  }

                  return _buildPhoto(
                    context,
                    watchPhotoState.groupFileList![key]![index],
                    currentIndex,
                  );
                })),
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
            color: Theme.of(context).primaryColor,
            size: 24,
          ));
        },
        errorWidget: (context, url, error) {
          debugPrint(error.toString());
          return Icon(
            Icons.broken_image_outlined,
            // color: Theme.of(context).primaryColor,
          );
        },
        imageUrl: Uri.encodeFull(url),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
