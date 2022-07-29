import 'package:flutter/cupertino.dart';

/// 路由观察者
/// 辅助监听 RouteAware
/// 需要在 MaterialApp 中添加
/// ```dart
///     MaterialApp(
///       navigatorObservers: [LifecycleRouteObserver.routeObserver],
///     )
/// ```
class LifecycleRouteObserver {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
}
