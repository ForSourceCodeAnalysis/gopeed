import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'api/api.dart' as api;
import 'app/modules/app/controllers/app_controller.dart';
import 'app/modules/app/views/app_view.dart';
import 'core/libgopeed_boot.dart';
import 'generated/locales.g.dart';
import 'util/locale_manager.dart';
import 'util/log_util.dart';
import 'util/mac_secure_util.dart';
import 'util/package_info.dart';
import 'util/util.dart';

void main() async {
  //async标识是一个异步函数
  await init(); //await标识等待init执行完成才能执行下面的代码
  onStart();

  runApp(const AppView());
}

//初始化，主要是业务逻辑方面的，不是UI初始化，UI在AppView里面
Future<void> init() async {
  //参考 https://juejin.cn/post/7031196891358429220
  WidgetsFlutterBinding.ensureInitialized();
  if (Util.isDesktop()) {
    //桌面应用特殊处理，注意是window，不是windows，所以不是针对windows系统的，而是针对桌面应用的
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(800, 600),
      center: true,
      skipTaskbar: false,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setPreventClose(true);
    });
  }
//Get是一个轻量但强大的flutter包，可以实现状态管理，依赖管理，导航管理，类似于一个容器
//参考https://pub-web.flutter-io.cn/packages/get
//注入依赖，把AppController实例注入到Get中，方便后续的管理
  final controller = Get.put(AppController());
  //加载配置
  try {
    await controller.loadStartConfig();
    final startCfg = controller.startConfig.value;
    //等待后端服务启动后获取端口号
    controller.runningPort.value = await LibgopeedBoot.instance.start(startCfg);
    api.init(startCfg.network, controller.runningAddress(), startCfg.apiToken);
  } catch (e) {
    logger.e("libgopeed init fail", e);
  }
  //加载下载配置
  try {
    await controller.loadDownloaderConfig();
    MacSecureUtil.loadBookmark();
  } catch (e) {
    logger.e("load config fail", e);
  }

  try {
    await initPackageInfo();
  } catch (e) {
    logger.e("init package info fail", e);
  }
}

Future<void> onStart() async {
  final appController = Get.find<AppController>();
  await appController.trackerUpdateOnStart();

  // if is debug mode, check language message is complete,change debug locale to your comfortable language if you want
  if (kDebugMode) {
    final mainLang = getLocaleKey(debugLocale);
    final fullMessages = AppTranslation.translations[mainLang];
    AppTranslation.translations.keys
        .where((e) => e != mainLang)
        .forEach((lang) {
      final langMessages = AppTranslation.translations[lang];
      if (langMessages == null) {
        logger.w("missing language: $lang");
        return;
      }
      final missingKeys =
          fullMessages!.keys.where((key) => langMessages[key] == null);
      if (missingKeys.isNotEmpty) {
        logger.w("missing language: $lang, keys: $missingKeys");
      }
    });
  }
}
