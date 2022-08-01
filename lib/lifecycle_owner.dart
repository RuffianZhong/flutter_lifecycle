import 'package:flutter/material.dart';
import 'package:flutter_lifecycle_aware/lifecycle_observable.dart';

/// 生命周期持有者
/// 对外提供对外提供被观察者对象
/// Lifecycle 需要继承/混入/实现
abstract class LifecycleOwner {
  ///Lifecycle被观察者
  LifecycleObservable getLifecycle();

  ///Lifecycle stateful对象
  State getStateful();
}
