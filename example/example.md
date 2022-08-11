### example

#### 1. Dependency

Add flutter_lifecycle_aware dependency to pubspec.yaml file

```
dependencies:

  # flutter lifecycle
  flutter_lifecycle_aware: ^0.0.3
```

#### 2. Create an observer

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

#### 3. Use Lifecycle and bind observer objects

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

#### 4. Auxiliary configuration

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
