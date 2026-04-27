import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:hello_backend/hello_backend.dart';

void main(List<String> args) async {
  // 读取端口号，默认是 8080
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  // 设置处理器管道
  final handler = const Pipeline()
      .addMiddleware(logRequests()) // 中间件：打印请求日志
      .addHandler(router);

  // 启动服务器，监听所有网络接口
  final ip = InternetAddress.anyIPv4;
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
