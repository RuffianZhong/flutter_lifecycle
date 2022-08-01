import 'package:flutter/material.dart';
import 'package:flutter_lifecycle/lifecycle.dart';
import 'package:flutter_lifecycle/lifecycle_observer.dart';
import 'package:flutter_lifecycle/lifecycle_owner.dart';
import 'package:flutter_lifecycle/lifecycle_route_observer.dart';
import 'package:flutter_lifecycle/lifecycle_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /// 生命周期辅助设置
      navigatorObservers: [LifecycleRouteObserver.routeObserver],
      home: const MyPage(),
    );
  }
}

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

///StatefulWidget中混入Lifecycle然后绑定LifecycleObserver
class _MyPageState extends State<MyPage> with Lifecycle {
  @override
  void initState() {
    super.initState();

    ///绑定LifecycleObserver
    getLifecycle().addObserver(AViewModel());
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

///需要监听StatefulWidget生命周期的地方
class AViewModel extends LifecycleObserver {
  ///需要释放的资源
  ScrollController controller = ScrollController();

  ///初始化数据
  void initData() {}

  ///销毁/释放资源
  void destroy() {
    controller.dispose();
  }

  ///生命周期回调监听
  @override
  void onLifecycleChanged(LifecycleOwner owner, LifecycleState state) {
    if (state == LifecycleState.onCreate) {
      initData();
    } else if (state == LifecycleState.onDestroy) {
      destroy();
    }
  }
}
