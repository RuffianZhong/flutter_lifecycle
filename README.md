# flutter_lifecycle

## English | [中文](https://github.com/RuffianZhong/flutter_lifecycle/blob/master/README_CN.md)

### 1.Introduction

#### 1.1 Describe

flutter_lifecycle draws on the lifecycle idea of the native platform Android/iOS and make a
lifecycle system on Flutter. Developers can perceive StatefulWidget's lifecycle wherever you need

```dart
/// LifecycleState
enum LifecycleState {
  /// describe：init
  /// frequency：single
  /// explanation：Triggered during the initialization phase of StatefulWidget creation
  onInit,

  /// describe：created
  /// frequency：single
  /// explanation：StatefulWidget is created and triggered when the first frame is rendered
  onCreate,

  /// describe：start
  /// frequency：（possibly）multiple
  /// explanation：StatefulWidget starts or becomes visible again (temporarily non-interactive); eg: when the page is first entered / when the non-fullscreen interface disappears; paired with #onStop
  onStart,

  /// describe：resume
  /// frequency：（possibly）multiple
  /// explanation：StatefulWidget starts or re-interacts; eg: when the page is interactive for the first time/non-fullscreen interface disappears; paired with #onPause
  onResume,

  /// describe：pause
  /// frequency：（possibly）multiple
  /// explanation：StatefulWidget is visible but not interactive; called when the StatefulWidget loses focus/enters the background/is blocked by the system or a custom non-fullscreen popup; paired with #onResume
  onPause,

  /// describe：stop
  /// frequency：（possibly）multiple
  /// explanation：StatefulWidget is invisible & non-interactive; called when the StatefulWidget completely leaves the user's field of view/enters the background/is blocked by the system or a custom full-screen popup; paired with #onStart
  onStop,

  /// describe：destroy
  /// frequency：single
  /// explanation：Called when StatefulWidget destroys/exits the program
  onDestroy;
}
```

#### 1.2 diagram

![](https://github.com/RuffianZhong/flutter_lifecycle/blob/master/assets/lifecycle.png)

### 2.Use

#### 2.1 Dependency

Add flutter_lifecycle_aware dependency to pubspec.yaml file

```
dependencies:

  # flutter lifecycle
  flutter_lifecycle_aware: ^0.0.3
```

#### 2.2 Create an observer

Inherit the ```LifecycleObserver``` observer wherever you want to monitor the StatefulWidget's
lifecycle and implement the ```onLifecycleChanged``` method

```dart
///Where you need to monitor the StatefulWidget lifecycle
class AViewModel extends LifecycleObserver {
  ///resources to be released
  ScrollController controller = ScrollController();

  ///initData
  void initData() {}

  ///destroy/release resources
  void destroy() {
    controller.dispose();
  }

  ///Lifecycle callback listener
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

#### 2.3 Use Lifecycle and bind observer objects

Mixin ```Lifecycle``` in StatefulWidget and bind ```LifecycleObserver``` to realize lifecycle awareness

```dart
///Mixin Lifecycle into StatefulWidget and bind LifecycleObserver
class _MyPageState extends State<MyPage> with Lifecycle {
  @override
  void initState() {
    super.initState();

    ///bind LifecycleObserver
    getLifecycle().addObserver(AViewModel());
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

#### 2.4 Auxiliary configuration

Add auxiliary configuration in MaterialApp ```LifecycleRouteObserver.routeObserver```

```dart
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      /// Lifecycle Assist Settings
      navigatorObservers: [LifecycleRouteObserver.routeObserver],
      home: const MyPage(),
    );
  }
}
```


