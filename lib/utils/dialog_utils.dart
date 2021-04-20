/*
 * Copyright (c) 2021. Jingpei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 *  https://jingpei.tech
 *  https://jin.dev
 *
 *  Created by Pepe
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void showCupertionLoading(context) {
  showCupertinoDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CupertinoActivityIndicator(
            radius: 14,
          ),
        );
      });
}

void showLoading(context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: SpinKitThreeBounce(
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
      );
    },
  );
}

void showCupertinoLoading(context) {
  showCupertinoDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Center(
            child: SpinKitThreeBounce(
          color: Theme.of(context).primaryColor,
          size: 24,
        ));
      });
}
