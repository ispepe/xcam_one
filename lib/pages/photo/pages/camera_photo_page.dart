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
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import 'package:xcam_one/global/global_store.dart';
import 'package:xcam_one/models/camera_file_entity.dart';
import 'package:xcam_one/models/cmd_status_entity.dart';
import 'package:xcam_one/models/wifi_app_mode_entity.dart';
import 'package:xcam_one/net/net.dart';
import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/notifiers/photo_state.dart';
import 'package:xcam_one/pages/photo/widgets/empty_photo.dart';
import 'package:xcam_one/pages/photo_view/photo_view_router.dart';

import 'package:xcam_one/res/styles.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';
import 'package:xcam_one/utils/bottom_sheet_utils.dart';
import 'package:xcam_one/utils/dialog_utils.dart';
import 'package:xcam_one/widgets/my_button.dart';

class CameraPhotoPage extends StatefulWidget {
  @override
  _CameraPhotoPageState createState() => _CameraPhotoPageState();
}

class _CameraPhotoPageState extends State<CameraPhotoPage>
    with AutomaticKeepAliveClientMixin {
  late PhotoState _watchPhotoState;
  late PhotoState _photoState;
  late GlobalState _watchGlobalState;

  late EasyRefreshController _refreshController;

  /// 获取全景相机
  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (Provider.of<GlobalState>(context, listen: false).isConnect) {
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

    /// NOTE: 2021/5/21 待注意 加载模态对话框是因为加载时间较长，防止页面切换操作
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

    /// 重置加载状态
    _refreshController.resetLoadState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _watchPhotoState = context.watch<PhotoState>();
    _watchGlobalState = context.watch<GlobalState>();
    _photoState = context.read<PhotoState>();

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
                    onPressed: _watchGlobalState.isInit
                        ? null
                        : () {
                            AppSettings.openWIFISettings();
                          },
                    buttonText: _watchGlobalState.isInit ? '初始化中' : '去连接'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPhoto(BuildContext context) {
    return Scaffold(
      body: EasyRefresh(
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
        onRefresh: _watchPhotoState.isMultipleSelect
            ? null
            : () async {
                await _onRefresh();
              },
        onLoad: _watchPhotoState.isMultipleSelect
            ? null
            : () async {
                await Future.delayed(Duration(milliseconds: 200), () {
                  _refreshController.finishLoad(
                      noMore: _watchPhotoState.loadCameraFile());
                });
              },
        child: _watchPhotoState.allFile?.isEmpty ?? true
            ? buildEmptyPhoto(
                context,
                text: '您还没有全景图片快去拍摄吧',
              )
            : ListView.builder(
                itemCount: _watchPhotoState.groupFileList?.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final keys = _watchPhotoState.groupFileList?.keys.toList();
                  return _buildPhotoGroup(context, keys![index]);
                },
              ),
      ),
      bottomNavigationBar: _watchPhotoState.isMultipleSelect
          ? SafeArea(
              child: Container(
                color: Colors.white,
                height: kBottomNavigationBarHeight + 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          showMyBottomSheet(context, '这些照片将从相机中彻底删除，请再次确认',
                              okPressed: () {
                            NavigatorUtils.goBack(context);
                            showCupertinoLoading(context);

                            int counter = 0;
                            bool isDeleteError = false;
                            _photoState.listSelect.forEach((photoIndex) async {
                              final String filePath = _photoState
                                  .allFile![photoIndex].file!.filePath!;
                              await DioUtils.instance
                                  .requestNetwork<CmdStatusEntity>(Method.get,
                                      '${HttpApi.deleteFile}$filePath',
                                      onSuccess: (data) {
                                counter++;
                                if (data?.function?.status == 0) {
                                  _photoState.cameraFileRemoveAt(photoIndex);
                                } else {
                                  showToast('删除$filePath文件失败');
                                  isDeleteError = true;
                                }

                                if (counter == _photoState.listSelect.length) {
                                  if (!isDeleteError) {
                                    showToast('删除成功');
                                  }
                                  _photoState.isMultipleSelect = false;
                                  _photoState.listSelect.clear();
                                  NavigatorUtils.goBack(context);
                                }
                              }, onError: (e, m) {
                                showToast('删除$filePath文件失败');
                                isDeleteError = true;
                                if (counter == _photoState.listSelect.length) {
                                  if (!isDeleteError) {
                                    showToast('删除成功');
                                  }
                                  _photoState.isMultipleSelect = false;
                                  _photoState.listSelect.clear();
                                  NavigatorUtils.goBack(context);
                                }
                              });
                            });
                          });
                        },
                        child: Icon(
                          Icons.delete_outline_outlined,
                          color: Colors.red,
                          size: 32,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 32.0),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          showCupertinoLoading(context);

                          int counter = 0;
                          bool isSaveError = false;
                          _photoState.listSelect.forEach((photoIndex) async {
                            String filePath = _photoState
                                .allFile![photoIndex].file!.filePath!;

                            filePath = filePath.substring(3, filePath.length);
                            filePath = filePath.replaceAll('\\', '/');

                            final url =
                                '${GlobalStore.config[EConfig.baseUrl]}$filePath'; // ignore: lines_longer_than_80_chars
                            await _saveImage(url).then((value) {
                              counter++;
                              if (!value) {
                                showToast('$filePath保存失败');
                                isSaveError = true;
                              }

                              if (counter == _photoState.listSelect.length) {
                                if (!isSaveError) {
                                  showToast('保存成功');
                                }

                                _photoState.isMultipleSelect = false;
                                _photoState.listSelect.clear();
                                Navigator.pop(context);
                              }
                            });
                          });
                        },
                        child: Icon(
                          Icons.save_alt_outlined,
                          size: 32,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Future<bool> _saveImage(url) async {
    bool result = true;
    await Dio()
        .get(url, options: Options(responseType: ResponseType.bytes))
        .then((value) async {
      if (value.data != null) {
        await PhotoManager.editor.saveImage(value.data).then((asset) {
          if (asset == null) {
            result = false;
          }
        });
      } else {
        showToast('请求$url失败');
      }
    });

    return result;
  }

  Widget _buildPhotoGroup(BuildContext context, String key) {
    final int length = _watchPhotoState.groupFileList![key]!.length;
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
                      _watchPhotoState.groupFileList!.keys.toList();
                  for (int i = 0; i < keys.length; i++) {
                    if (keys[i].contains(key)) {
                      currentIndex += index;
                      break;
                    }
                    currentIndex +=
                        _watchPhotoState.groupFileList![keys[i]]!.length;
                  }

                  return _buildPhoto(
                    context,
                    _watchPhotoState.groupFileList![key]![index],
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
        if (_photoState.isMultipleSelect) {
          if (_photoState.listSelect.contains(index)) {
            _photoState.listSelect.remove(index);
          } else {
            _photoState.listSelect.add(index);
          }
          if (_photoState.isAllSelect) {
            _photoState.isAllSelect = false;
          }
          setState(() {});
        } else {
          NavigatorUtils.push(context,
              '${PhotoViewRouter.photoView}?currentIndex=$index&type=camera');
        }
      },
      onLongPress: () async {
        if (!_photoState.isMultipleSelect) {
          await HapticFeedback.heavyImpact();
          setState(() {
            _photoState.isMultipleSelect = true;
            _photoState.isAllSelect = false;
            _photoState.listSelect.clear();
            _photoState.listSelect.add(index);
          });
        }
      },
      child: _watchPhotoState.isMultipleSelect &&
              _watchPhotoState.listSelect.contains(index)
          ? Container(
              decoration: BoxDecoration(
                border:
                    Border.all(width: 2, color: Theme.of(context).primaryColor),
              ),
              child: Stack(children: [
                _buildCachedNetworkImage(url),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(
                      'assets/images/select_mark.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                )
              ]),
            )
          : _buildCachedNetworkImage(url),
    );
  }

  Widget _buildCachedNetworkImage(String url) {
    return CachedNetworkImage(
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
