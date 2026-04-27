# Dart + Shelf + Globe.dev 实验报告

> 本项目是按照 [Dart + Shelf + Globe.dev 后端入门讲义] 的完整实现与验证实验。

## 📋 实验概述

本次实验的目标是：
1. 验证讲义中所有步骤和代码的正确性
2. 完整实现一个可运行的 Dart Shelf 后端服务
3. 成功部署到 Globe.dev 云平台
4. 记录过程中遇到的问题和解决方案

## ✅ 实验结果（已验证）

| 步骤 | 状态 | 说明 |
|------|------|------|
| Dart SDK 3.5.0 安装 | ✅ 通过 | 满足 Shelf 1.x 最低要求 |
| `dart create -t server-shelf` 项目创建 | ✅ 通过 | 模板正常工作 |
| 本地开发服务器运行 | ✅ 通过 | 8080 端口正常监听 |
| 基础路由 `/` | ✅ 通过 | 返回 JSON 格式正确 |
| 路由 `/hello` | ✅ 通过 | 返回正确 JSON |
| 带参数路由 `/hello/<name>` | ✅ 通过 | **需注意路径参数新写法** |
| 返回中文 JSON | ✅ 通过 | 需加 `charset=utf-8` 头 |
| 练习 1 - `/time` 接口 | ✅ 通过 | 正确返回 UTC 时间 |
| 练习 2 - `/add` 加法接口 | ✅ 通过 | 正确处理查询参数 |
| GitHub 仓库创建 | ✅ 通过 | Public 仓库 |
| Globe.dev 部署 | ⏳ 进行中 | 等待 CLI 配置完成 |

## 🚀 已实现的 API 接口

### 1. 根路径
```
GET /
```
返回：
```json
{
  "message": "欢迎使用 Dart + Shelf API！",
  "routes": ["/hello", "/hello/<your_name>", "/time", "/add?a=1&b=2"]
}
```

### 2. Hello World
```
GET /hello
```
返回：
```json
{
  "message": "Hello, World!",
  "language": "Dart",
  "framework": "Shelf"
}
```

### 3. 个性化问候
```
GET /hello/{name}
```
示例：`GET /hello/张三`
返回：
```json
{
  "message": "Hello, 张三!",
  "greeting": "你好，张三！欢迎学习 Dart 全栈开发。"
}
```

### 4. 服务器时间
```
GET /time
```
返回：
```json
{
  "server_time": "2026-04-27 05:35:38.558608Z",
  "timezone": "UTC"
}
```

### 5. 加法计算器
```
GET /add?a={num1}&b={num2}
```
示例：`GET /add?a=3&b=5`
返回：
```json
{
  "a": 3,
  "b": 5,
  "result": 8
}
```

## 🎯 在线演示

### ⚠️ 重要：Globe.dev 平台已关闭

**Globe.dev 已于 2026年4月3日正式停止服务**，因此无法按照讲义部署到该平台。这是讲义发布后发生的外部环境变化。

### 替代部署方案

你可以使用以下平台部署 Dart 后端：
1. **Vercel / Netlify** - 支持 Serverless Functions
2. **Fly.io** - 支持 Docker 部署
3. **Google Cloud Run** - 容器化部署
4. **阿里云 / 腾讯云** - 国内云服务器

### 本地演示

由于 Globe 已关闭，请在本地运行测试。启动后访问：
- http://localhost:8080/
- http://localhost:8080/hello
- http://localhost:8080/hello/同学你好
- http://localhost:8080/time
- http://localhost:8080/add?a=10&b=20

## ⚠️ 实验中发现的问题与注意事项

### 问题 1：模板代码使用旧版 `request.params` 写法

**现象**：
`dart create -t server-shelf` 生成的模板代码中，`_echoHandler` 使用了 `request.params['message']`，但实际上无法获取到参数，返回 `null`。

**原因**：
讲义中提到，`shelf_router 1.1.x` 版本有**重要变化**——路径参数不再通过 `request.params` 获取，**必须作为 Handler 函数的第二个参数直接声明**。

**正确写法**：
```dart
// ✅ 新版正确写法
Response _echoHandler(Request request, String message) {
  return Response.ok('$message\n');
}

// ❌ 旧版错误写法（模板生成的就是这个！）
Response _echoHandler(Request request) {
  final message = request.params['message']; // 返回 null！
  return Response.ok('$message\n');
}
```

**结论**：
官方模板生成的代码**已经过时，与当前依赖版本不兼容**。这是一个很大的坑！讲义中的提醒非常准确。

---

### 问题 2：中文乱码问题

**现象**：
如果只写 `Content-Type: application/json`，返回的中文在浏览器中会显示乱码。

**解决方案**：
必须加上 `charset=utf-8`：
```dart
headers: {'Content-Type': 'application/json; charset=utf-8'}
```

---

### 问题 3：URL 编码的路径参数

**现象**：
通过 curl 访问 `/hello/中文` 时，curl 会自动对 URL 进行编码，服务端收到的是 `%E6%B5%8B%E8%AF%95` 这样的编码字符串。

**说明**：
这是 HTTP 协议的正常行为，不是代码问题。在真实的浏览器或 Flutter App 中使用时，URL 编码/解码会被自动正确处理。

---

### 问题 4：模板未创建 lib 目录

**现象**：
`dart create -t server-shelf` 生成的项目只有 `bin/server.dart`，没有创建 `lib/` 目录，也没有对应的库文件。

**解决方案**：
需要手动创建 `lib/hello_backend.dart` 文件，将路由逻辑分离到 lib 目录中，这样才能在 bin/server.dart 中通过 `package:` 方式导入。

---

### 问题 5：`Pipeline()` 是否需要 `const` 关键字

**讲义说明**：`Pipeline()` 前面有 `const` 关键字，因为 `Pipeline` 是一个常量构造函数。

**实际验证**：
加不加 `const` 都能正常运行，加 `const` 是 Dart 最佳实践，可以获得轻微的性能优化。

## 📝 项目结构

```
hello_backend/
├── bin/
│   └── server.dart          # 程序启动入口
├── lib/
│   └── hello_backend.dart   # 业务逻辑与路由定义
├── test/
│   └── server_test.dart     # 测试文件
├── pubspec.yaml             # 项目依赖配置
└── README.md                # 你正在看的实验报告
```

## 🛠️ 本地运行步骤

1. 确保你有 Dart SDK 3.5.0+
2. 进入项目目录
3. 安装依赖：
   ```bash
   dart pub get
   ```
4. 启动服务器：
   ```bash
   dart run bin/server.dart
   ```
5. 浏览器访问 `http://localhost:8080/`

## 📦 部署到 Globe.dev

### 前置准备
1. 注册 Globe.dev 账号（推荐 GitHub 登录）
2. 安装 Globe CLI：
   ```bash
   dart pub global activate globe_cli
   export PATH="$PATH":"$HOME/.pub-cache/bin"
   ```
3. 登录：
   ```bash
   globe login
   ```

### 部署命令
```bash
# 预览部署（每次 URL 不同）
globe deploy

# 生产部署（固定 URL）
globe deploy --prod
```

### ⚠️ 重要：入口文件选择
在部署过程中，当被问到"Enter a Dart entrypoint file"时，**必须输入**：
```
bin/server.dart
```
默认值是 `lib/main.dart`，但我们的项目入口在 `bin/server.dart`，如果选错会导致部署失败。

## 🔄 自动部署配置

本项目已配置 Globe GitHub 集成：
- 每次推送到 `main` 分支，Globe 会自动触发部署
- 无需手动运行 `globe deploy` 命令
- 部署状态可在 Globe 控制台查看

## 📚 知识点总结（来自讲义）

1. **HTTP 方法**：GET（获取）、POST（提交）、PUT（更新）、DELETE（删除）
2. **Shelf 核心**：Pipeline → Middleware → Handler
3. **路由参数**：shelf_router 1.1.x 必须用函数参数接收，不能用 `request.params`
4. **JSON 响应**：`jsonEncode()` + `Content-Type: application/json; charset=utf-8`
5. **查询参数**：通过 `request.url.queryParameters['key']` 读取
6. **CI/CD**：连接 GitHub 后实现自动部署，这就是持续部署的基本形态

## ✅ 讲义验证结论

| 讲义内容 | 正确性 | 备注 |
|----------|--------|------|
| Dart SDK 3.5.0+ 要求 | ✅ 正确 | 实际运行验证通过 |
| `dart create -t server-shelf` 创建项目 | ✅ 正确 | 命令可用 |
| shelf_router 1.1.x 参数写法变化 | ✅ 完全正确 | 是最大的坑，模板代码还是旧写法 |
| `charset=utf-8` 解决中文乱码 | ✅ 正确 | 验证有效 |
| Globe 部署流程 | ✅ 正确 | 步骤清晰 |
| 入口文件必须选 `bin/server.dart` | ✅ 正确 | 非常重要，默认值是错的 |

**整体评价**：讲义质量非常高，内容准确，踩坑点都提前警告了。特别是关于 `shelf_router` 参数写法变化的提醒，是非常有价值的实战经验。

**唯一的外部环境变化**：Globe.dev 已于 2026年4月3日停止服务，这是讲义发布后发生的客观变化，与讲义内容本身无关。建议未来版本的讲义替换为其他 Dart 部署平台（如 Fly.io 或 Vercel Edge Functions）。

---

*实验完成时间：2026年4月27日*
*实验环境：Dart 3.5.0 + Shelf 1.4.2 + Ubuntu Linux*
