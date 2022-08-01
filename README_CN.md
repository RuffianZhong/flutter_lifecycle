# flutter_lifecycle

### 1.简介

#### 1.1 描述

flutter_lifecycle 借鉴原生平台 Android/iOS 的生命周期思想，实现了在 Flutter 上的一套生命周期系统。开发者可以在任何你需要的地方感知 StatefulWidget
的生命周期

```dart
/// 生命周期状态
enum LifecycleState {
  /// 描述：初始化状态
  /// 频率：单次调用
  /// 说明：在 StatefulWidget 创建的初始化阶段触发
  onInit,

  /// 描述：创建完成状态
  /// 频率：单次调用
  /// 说明：StatefulWidget 创建完成，第一帧渲染完成触发
  onCreate,

  /// 描述：开始执行
  /// 频率：（可能）多次调用
  /// 说明：StatefulWidget 开始或重新 可见（暂时不可交互）；例如：首次进入页面时/非全屏界面消失时；与 #onStop 成对
  onStart,

  /// 描述：开始交互
  /// 频率：（可能）多次调用
  /// 说明：StatefulWidget 开始或重新 可交互；例如：首次进入页面可交互时/非全屏界面消失时；与 #onPause 成对
  onResume,

  /// 描述：挂起/暂停执行
  /// 频率：（可能）多次调用
  /// 说明：StatefulWidget 可见但不可交互；在 StatefulWidget 失去焦点/进入后台/被系统或自定义的 非 全屏弹窗遮挡时调用；与 #onResume 成对
  onPause,

  /// 描述：停止执行
  /// 频率：（可能）多次调用
  /// 说明：StatefulWidget 不可见 & 不可交互；在 StatefulWidget 完全离开用户视野/进入后台/被系统或自定义的全屏弹窗遮挡时调用；与 #onStart 成对
  onStop,

  /// 描述：销毁
  /// 频率：单次调用
  /// 说明：StatefulWidget 销毁/退出程序时调用
  onDestroy;
}
```

#### 1.2 图解

![](https://github.com/RuffianZhong/flutter_lifecycle/blob/master/assets/lifecycle.png)

### 2.使用

#### 2.1 依赖

pubspec.yaml 文件中添加 flutter_lifecycle 依赖

```
dependencies:

  # flutter生命周期
  flutter_lifecycle_aware: ^0.0.1
```

#### 2.2 创建观察者

在任何你想要监听 StatefulWidget 生命周期的地方继承 ```LifecycleObserver``` 观察者，实现 ```onLifecycleChanged``` 方法

```dart
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
```

#### 2.3 使用 Lifecycle 并且绑定观察者对象

在 StatefulWidget 中混入 ```Lifecycle``` ,绑定 ```LifecycleObserver``` 实现生命周期感知

```dart
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
```

#### 2.4 辅助配置

在 MaterialApp 中添加辅助配置 ```LifecycleRouteObserver.routeObserver```

```dart
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
```


