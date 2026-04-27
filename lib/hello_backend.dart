import 'dart:convert'; // 用于 JSON 编解码
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

// 定义路由
final router = Router()
  ..get('/', _rootHandler)
  ..get('/hello', _helloHandler)
  ..get('/hello/<name>', _helloNameHandler)
  ..get('/time', _timeHandler)
  ..get('/add', _addHandler);

// 根路径：返回 API 说明
Response _rootHandler(Request req) {
  final data = {
    'message': '欢迎使用 Dart + Shelf API！',
    'routes': ['/hello', '/hello/<your_name>', '/time', '/add?a=1&b=2'],
  };
  return Response.ok(
    jsonEncode(data),
    headers: {'Content-Type': 'application/json; charset=utf-8'},
  );
}

// /hello：返回通用问候
Response _helloHandler(Request req) {
  final data = {
    'message': 'Hello, World!',
    'language': 'Dart',
    'framework': 'Shelf',
  };
  return Response.ok(
    jsonEncode(data),
    headers: {'Content-Type': 'application/json; charset=utf-8'},
  );
}

// /hello/<name>：返回个性化问候
// ⚠️ 路径参数 name 必须作为第二个函数参数接收！
Response _helloNameHandler(Request request, String name) {
  final data = {
    'message': 'Hello, $name!',
    'greeting': '你好，$name！欢迎学习 Dart 全栈开发。',
  };
  return Response.ok(
    jsonEncode(data),
    headers: {'Content-Type': 'application/json; charset=utf-8'},
  );
}

// 练习1：返回服务器时间
Response _timeHandler(Request req) {
  final now = DateTime.now().toUtc();
  final data = {
    'server_time': now.toString(),
    'timezone': 'UTC',
  };
  return Response.ok(
    jsonEncode(data),
    headers: {'Content-Type': 'application/json; charset=utf-8'},
  );
}

// 练习2：加法计算器
Response _addHandler(Request req) {
  final aStr = req.url.queryParameters['a'];
  final bStr = req.url.queryParameters['b'];
  
  if (aStr == null || bStr == null) {
    return Response(400, 
      body: jsonEncode({'error': '请提供参数 a 和 b，例如：/add?a=3&b=5'}),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );
  }
  
  final a = int.tryParse(aStr);
  final b = int.tryParse(bStr);
  
  if (a == null || b == null) {
    return Response(400,
      body: jsonEncode({'error': '参数 a 和 b 必须是有效的数字'}),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );
  }
  
  final data = {
    'a': a,
    'b': b,
    'result': a + b,
  };
  return Response.ok(
    jsonEncode(data),
    headers: {'Content-Type': 'application/json; charset=utf-8'},
  );
}
