/*
 * Copyright (c) 2021 Jing Pei Technology Co., Ltd. All rights reserved.
 * See LICENSE for distribution and usage details.
 *
 * https://jingpei.tech
 * https://jin.dev
 *
 * Created by Angus
 */

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:xcam_one/global/constants.dart';
import 'package:xcam_one/utils/log_utils.dart';
import 'package:sprintf/sprintf.dart';

import 'dio_utils.dart';
import 'error_handle.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String? accessToken = SpUtil.getString(Constant.accessToken);
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return super.onRequest(options, handler);
  }
}

class TokenInterceptor extends Interceptor {
  Future<String?> getToken() async {
    final Map<String, String?> params = <String, String>{};
    params['refresh_token'] = SpUtil.getString(Constant.refreshToken);
    try {
      _tokenDio.options = DioUtils.instance.dio!.options;
      final Response response =
          await _tokenDio.post('auth/refreshToken', data: params);
      if (response.statusCode == ExceptionHandle.success) {
        return json.decode(response.data.toString())['access_token'];
      }
    } catch (e) {
      Log.e('刷新Token失败！');
    }
    return null;
  }

  final Dio _tokenDio = Dio();

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    //401代表token过期
    if (response.statusCode == ExceptionHandle.unauthorized) {
      Log.d('-----------自动刷新Token------------');
      final Dio? dio = DioUtils.instance.dio;
      dio?.interceptors.requestLock.lock();

      final String? accessToken = await getToken(); // 获取新的accessToken
      Log.e('-----------NewToken: $accessToken ------------');
      await SpUtil.putString(Constant.accessToken, accessToken ?? '');
      dio?.interceptors.requestLock.unlock();

      if (accessToken != null) {
        // 重新请求失败接口
        final RequestOptions request = response.requestOptions;
        request.headers['Authorization'] = 'Bearer $accessToken';
        try {
          Log.e('----------- 重新请求接口 ------------');

          /// 避免重复执行拦截器，使用tokenDio
          final Response response = await _tokenDio.request(request.path,
              data: request.data,
              queryParameters: request.queryParameters,
              cancelToken: request.cancelToken,
              options: request as Options,
              // options: Options(method:'GET'),
              onReceiveProgress: request.onReceiveProgress);

          // 再调用一次
          return onResponse(response, handler);
        } on DioError catch (e) {
          /// TODO: 4/5/21 待处理 未验证
          return super.onError(e, ErrorInterceptorHandler());
        }
      }
    }
    return super.onResponse(response, handler);
  }
}

class LoggingInterceptor extends Interceptor {
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _startTime = DateTime.now();
    Log.d('----------Start----------');
    if (options.queryParameters.isEmpty) {
      Log.d('RequestUrl: ' + options.baseUrl + options.path);
    } else {
      Log.d('RequestUrl: ' +
          options.baseUrl +
          options.path +
          '?' +
          Transformer.urlEncodeMap(options.queryParameters));
    }
    Log.d('RequestMethod: ' + options.method);
    Log.d('RequestHeaders:' + options.headers.toString());
    Log.d('RequestContentType: ${options.contentType}');
    Log.d('RequestData: ${options.data.toString()}');

    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _endTime = DateTime.now();

    final int duration = _endTime!.difference(_startTime!).inMilliseconds;

    if (response.statusCode == ExceptionHandle.success) {
      Log.d('ResponseCode: ${response.statusCode}');
    } else {
      Log.e('ResponseCode: ${response.statusCode}');
    }
    // 输出结果
    Log.json(response.data.toString());
    Log.d('----------End: $duration 毫秒----------');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    Log.d('----------Error-----------');
    return super.onError(err, handler);
  }
}

/// TODO: 4/5/21 待处理 转换xml 至固定格式
class AdapterInterceptor extends Interceptor {
  static const String _kMsg = 'msg';
  static const String _kSlash = '\'';
  static const String _kMessage = 'message';

  static const String _kDefaultText = '\"无返回信息\"';
  static const String _kNotFound = '未找到查询信息';

  static const String _kFailureFormat = '{\"code\":%d,\"message\":\"%s\"}';
  static const String _kSuccessFormat =
      '{\"code\":0,\"data\":%s,\"message\":\"\"}';

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final Response r = adapterData(response);
    return super.onResponse(r, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      adapterData(err.response!);
    }
    return super.onError(err, handler);
  }

  Response adapterData(Response response) {
    String result;
    String content = response.data?.toString() ?? '';

    /// 成功时，直接格式化返回
    if (response.statusCode == ExceptionHandle.success ||
        response.statusCode == ExceptionHandle.success_not_content) {
      if (content.isEmpty) {
        content = _kDefaultText;
      }
      result = sprintf(_kSuccessFormat, [content]);
      response.statusCode = ExceptionHandle.success;
    } else {
      if (response.statusCode == ExceptionHandle.not_found) {
        /// 错误数据格式化后，按照成功数据返回
        result = sprintf(_kFailureFormat, [response.statusCode, _kNotFound]);
        response.statusCode = ExceptionHandle.success;
      } else {
        if (content.isEmpty) {
          // 一般为网络断开等异常
          result = content;
        } else {
          String msg;
          try {
            content = content.replaceAll("\\", '');
            if (_kSlash == content.substring(0, 1)) {
              content = content.substring(1, content.length - 1);
            }
            Map<String, dynamic> map = json.decode(content);
            if (map.containsKey(_kMessage)) {
              msg = map[_kMessage];
            } else if (map.containsKey(_kMsg)) {
              msg = map[_kMsg];
            } else {
              msg = '未知异常';
            }
            result = sprintf(_kFailureFormat, [response.statusCode, msg]);
            // 401 token失效时，单独处理，其他一律为成功
            if (response.statusCode == ExceptionHandle.unauthorized) {
              response.statusCode = ExceptionHandle.unauthorized;
            } else {
              response.statusCode = ExceptionHandle.success;
            }
          } catch (e) {
            Log.d('异常信息：$e');
            // 解析异常直接按照返回原数据处理（一般为返回500,503 HTML页面代码）
            result = sprintf(_kFailureFormat,
                [response.statusCode, '服务器异常(${response.statusCode})']);
          }
        }
      }
    }
    response.data = result;
    return response;
  }
}
