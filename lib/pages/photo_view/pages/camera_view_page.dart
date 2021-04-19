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

import 'package:dio/dio.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xcam_one/global/global_store.dart';

import 'package:xcam_one/models/camera_file_entity.dart';
import 'package:xcam_one/models/cmd_status_entity.dart';
import 'package:xcam_one/net/net.dart';
import 'package:xcam_one/notifiers/global_state.dart';
import 'package:xcam_one/notifiers/photo_state.dart';
import 'package:xcam_one/res/resources.dart';
import 'package:xcam_one/routers/fluro_navigator.dart';

class CameraViewPage extends StatefulWidget {
  const CameraViewPage({Key? key, required this.currentIndex})
      : super(key: key);

  final int currentIndex;

  @override
  _CameraViewPageState createState() => _CameraViewPageState();
}

class _CameraViewPageState extends State<CameraViewPage> {
  PageController? pageController;

  late int _photoIndex;

  late PhotoState photoState;

  bool _isShowBack = false;

  @override
  void initState() {
    super.initState();
    _photoIndex = widget.currentIndex;
    pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    photoState = context.read<PhotoState>();

    return Scaffold(
      appBar: _isShowBack
          ? null
          : AppBar(
              leading: GestureDetector(
                onTap: () => NavigatorUtils.goBack(context),
                child: Icon(
                  Icons.arrow_back_ios,
                ),
              ),
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: GestureDetector(
                    onTap: () {
                      _showModelBottomSheet(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Image.asset(
                        'assets/images/more_back.png',
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                )
              ],
            ),
      body: _buildBody(context),
      bottomNavigationBar: _isShowBack
          ? null
          : SafeArea(
              child: Container(
                color: Colors.white,
                height: kBottomNavigationBarHeight + 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () {
                          final String filePath =
                              photoState.allFile![_photoIndex].file!.filePath!;
                          DioUtils.instance.requestNetwork<CmdStatusEntity>(
                              Method.get, '${HttpApi.deleteFile}$filePath',
                              onSuccess: (data) {
                            if (data?.function?.status == 0) {
                              showToast('删除成功');
                              photoState.cameraFileRemoveAt(_photoIndex);
                            } else {
                              showToast('删除失败');
                            }
                          }, onError: (e, m) {
                            showToast('删除失败');
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
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () {
                          String filePath =
                              photoState.allFile![_photoIndex].file!.filePath!;

                          filePath = filePath.substring(3, filePath.length);
                          filePath = filePath.replaceAll('\\', '/');
                          final url =
                              '${GlobalStore.config[EConfig.baseUrl]}$filePath';
                          _saveImage(url);
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                content: SpinKitThreeBounce(
                                  color: Theme.of(context).primaryColor,
                                  size: 24,
                                ),
                              );
                            },
                          );
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
            ),
    );
  }

  void _showModelBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      context: context,
      builder: (BuildContext context) {
        final CameraFileInfo entity = photoState.allFile![_photoIndex].file!;
        final int length = int.parse(entity.size!);

        final String _currentImageSize = (length / 1024) > 1024
            ? '${(length / 1024 / 1024).toStringAsFixed(2)}M'
            : '${(length / 1024).toStringAsFixed(2)}KB';

        final line = Divider(color: Color(0xFFF5F5F5));
        final valueColor = Color(0xFFBFBFBF);

        return Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '详细信息',
                      style:
                          TextStyles.textSize14.copyWith(color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () {
                        NavigatorUtils.goBack(context);
                      },
                      child: Icon(
                        Icons.close_outlined,
                        color: Colors.black,
                        size: 24,
                      ),
                    )
                  ],
                ),
              ),
              line,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '文件名',
                      style:
                          TextStyles.textSize14.copyWith(color: Colors.black),
                    ),
                    Text(
                      entity.name!,
                      style: TextStyles.textSize14.copyWith(color: valueColor),
                    ),
                  ],
                ),
              ),
              line,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '拍摄时间',
                      style:
                          TextStyles.textSize14.copyWith(color: Colors.black),
                    ),
                    Text(
                      entity.time.toString(),
                      style: TextStyles.textSize14.copyWith(color: valueColor),
                    ),
                  ],
                ),
              ),
              line,

              /// NOTE: 4/12/21 待注意 FW说固定即可
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '分辨率',
                      style:
                          TextStyles.textSize14.copyWith(color: Colors.black),
                    ),
                    Text(
                      '4608x3456',
                      style: TextStyles.textSize14.copyWith(color: valueColor),
                    ),
                  ],
                ),
              ),
              line,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '图片大小',
                      style:
                          TextStyles.textSize14.copyWith(color: Colors.black),
                    ),
                    Text(
                      '$_currentImageSize',
                      style: TextStyles.textSize14.copyWith(color: valueColor),
                    ),
                  ],
                ),
              ),
              line,
            ],
          ),
        );
      },
    );
  }

  void _saveImage(url) {
    Dio()
        .get(url, options: Options(responseType: ResponseType.bytes))
        .then((value) {
      PhotoManager.editor.saveImage(value.data).then((asset) {
        if (asset != null) {
          showToast('保存成功');

          /// TODO: 4/14/21 保存成功通知相册刷新
          Navigator.pop(context);
        } else {
          showToast('保存失败');
          Navigator.pop(context);
        }
      });
    });
  }

  Widget _buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final bgColor = Color(0xFFF2F2F2);
    final _photoState = context.watch<PhotoState>();
    return Container(
      width: size.width,
      height: size.height,
      color: _isShowBack ? Colors.black : bgColor,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isShowBack = !_isShowBack;
          });
        },
        child: PhotoViewGallery.builder(
          pageController: pageController,
          onPageChanged: onPageChanged,
          backgroundDecoration: BoxDecoration(
            color: _isShowBack ? Colors.black : bgColor,
          ),
          scrollPhysics: const BouncingScrollPhysics(),
          itemCount: _photoState.allFile?.length,
          builder: (BuildContext context, int index) {
            String filePath = _photoState.allFile![index].file!.filePath!;
            filePath = filePath.substring(3, filePath.length);
            filePath = filePath.replaceAll('\\', '/');
            final url =
                '${GlobalStore.config[EConfig.baseUrl]}$filePath${HttpApi.getScreennail}'; // ignore: lines_longer_than_80_chars

            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(url),
              initialScale: PhotoViewComputedScale.contained,
            );
          },
          loadingBuilder: (context, event) {
            return Center(
                child: SpinKitCircle(
              color: Theme.of(context).primaryColor,
              size: 32,
            ));
          },
        ),
      ),
    );
  }

  void onPageChanged(int index) {
    debugPrint('index = $index');
    _photoIndex = index;
  }
}
