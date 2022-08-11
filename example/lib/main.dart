import 'package:flutter/material.dart';
import 'package:flutter_lifecycle_aware/lifecycle_route_observer.dart';

import 'example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /// 配置生命周期感知
      /// config lifecycle
      navigatorObservers: [LifecycleRouteObserver.routeObserver],

      home: const ExamplePage(),
    );
  }
}
