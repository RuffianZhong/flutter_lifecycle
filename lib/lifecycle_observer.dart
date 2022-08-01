import 'package:flutter_lifecycle_aware/lifecycle_owner.dart';
import 'package:flutter_lifecycle_aware/lifecycle_state.dart';

/// 生命周期观察者
/// 通过 onLifecycleChanged 监听 生命周期变化
/// 任何对象可以通过实现此类，并将自身添加到被观察者 LifecycleObservable，实现监听生命周期变化
abstract class LifecycleObserver {
  /// widget 状态改变回调
  void onLifecycleChanged(LifecycleOwner owner, LifecycleState state);
}
