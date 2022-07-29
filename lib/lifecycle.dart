import 'package:flutter/cupertino.dart';
import 'package:flutter_lifecycle/lifecycle_dispatcher.dart';
import 'package:flutter_lifecycle/lifecycle_observable.dart';
import 'package:flutter_lifecycle/lifecycle_owner.dart';

///
/// 具备生命周期感知的 StatefulWidget
///
/// 1.在 StatefulWidget 中，继承/混入 此类，使得组件具备生命周期功能
///
/// 2.在任何你需要的地方构造一个生命周期观察者 LifecycleObserver
///
/// 3.将观察者绑定到当前对象，即可实现观察者监听组件的生命周期
///
/// ```dart
/// ///某个需要感知生命周期的观察者
/// class AModel extends LifecycleObserver {
///   /// 需要依据生命周期释放的资源
///   ScrollController controller = ScrollController();
///
///   @override
///   void onLifecycleChanged(LifecycleOwner owner, LifecycleState state) {
///     if (state == LifecycleState.onDestroy) {
///       ///在组件销毁时释放资源
///       controller.dispose();
///     }
///   }
/// }
/// ```
///
/// ```dart
/// ///在 StatefulWidget 中混入 Lifecycle
/// class _MyPageState extends State<MyPage> with Lifecycle {
///   @override
///   void initState() {
///     super.initState();
///
///     ///绑定观察者
///     getLifecycle().addObserver(AModel());
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Container();
///   }
/// }
///
/// ```
///
mixin Lifecycle<T extends StatefulWidget> on State<T>
    implements LifecycleOwner {
  ///生命周期分发器
  LifecycleDispatcher? _lifecycleDispatcher;

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    _dispatcher().initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dispatcher().didChangeDependencies();
  }

  @override
  @protected
  @mustCallSuper
  void deactivate() {
    super.deactivate();
    _dispatcher().deactivate();
  }

  @override
  @protected
  @mustCallSuper
  void dispose() {
    _dispatcher().dispose();
    super.dispose();
  }

  /// 获取被观察者，用来管理观察者
  @override
  LifecycleObservable getLifecycle() {
    return _dispatcher().getLifecycle();
  }

  /// 获取 StatefulWidget 的 State
  @override
  State<StatefulWidget> getStateful() {
    return _dispatcher().getStateful();
  }

  /// 生命周期分发器
  LifecycleDispatcher _dispatcher() {
    return _lifecycleDispatcher ??= LifecycleDispatcher(this, this);
  }
}
