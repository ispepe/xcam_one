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
import 'package:xcam_one/routers/fluro_navigator.dart';

void showMyBottomSheet(BuildContext context, title,
    {required VoidCallback? okPressed}) {
  final size = MediaQuery.of(context).size;

  showModalBottomSheet(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/warning_icon.png',
                    width: 32,
                    height: 32,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: size.width * 0.5,
                      ),
                      child: Text(
                        title,
                        maxLines: 3,
                        style:
                            TextStyles.textBold18.copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 24),
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
                        onPressed: okPressed,
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
        ),
      );
    },
  );
}

void showMyTwoBottomSheet(BuildContext context, title,
    {required VoidCallback? okPressed}) {
  final size = MediaQuery.of(context).size;
  showModalBottomSheet(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.7,
              ),
              child: Text(
                title,
                style: TextStyles.textBold18.copyWith(color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 24),
              child: TextButton(
                  onPressed: okPressed,
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    minimumSize: const Size(200, 44),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(22)),
                    ),
                  ),
                  child: Text(
                    '确定',
                    style: TextStyles.textSize16.copyWith(color: Colors.white),
                  )),
            )
          ],
        ),
      );
    },
  );
}
