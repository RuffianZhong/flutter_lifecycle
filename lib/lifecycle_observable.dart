import 'package:flutter_lifecycle/lifecycle_observer.dart';
import 'package:flutter_lifecycle/lifecycle_state.dart';

/// 生命周期被观察者
/// 管理观察者对象：添加观察者，移除观察者，通知观察者
abstract class LifecycleObservable {
  /// 添加观察者
  void addObserver(LifecycleObserver observer);

  /// 移除观察者
  void removeObserver(LifecycleObserver observer);

  /// 通知观察者
  void notify(LifecycleState state);
}
