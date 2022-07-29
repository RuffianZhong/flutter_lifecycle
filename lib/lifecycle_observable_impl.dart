import 'package:flutter_lifecycle/lifecycle_observable.dart';
import 'package:flutter_lifecycle/lifecycle_observer.dart';
import 'package:flutter_lifecycle/lifecycle_owner.dart';
import 'package:flutter_lifecycle/lifecycle_state.dart';

/// 生命周期可观察对象（被观察者）实现类
/// 管理观察者对象
/// 添加观察者：添加需要生命周期感知的对象
/// 移除观察者：移除不再需要通知的对象
class LifecycleObservableImpl extends LifecycleObservable {
  /// 带状态的观察者集合
  /// 理想状态下 set 集合即可满足存储，由于观察者注册时机不确定/不一致，所以需要保存观察者对应的生命周期（可能与widget生命周期不一致）
  final Map<LifecycleObserver, LifecycleObserverDispatcher> _observerMap = {};

  /// 组件当前生命周期状态
  LifecycleState _lifecycleState = LifecycleState.onInit;

  /// 具备生命周期感知对象
  final LifecycleOwner _owner;

  LifecycleObservableImpl(this._owner);

  /// 添加观察者的时期由开发者控制，有可能不能完整触发整个生命周期，此处需要特殊处理
  /// 添加完成之后需要补充前面已经过去的生命周期（用户在哪里添加观察者无法得知）
  @override
  void addObserver(LifecycleObserver observer) {
    LifecycleObserverDispatcher observerDispatcher =
        LifecycleObserverDispatcher(_owner, observer);

    _observerMap.putIfAbsent(observer, () => observerDispatcher);

    /// 延迟/补充生命周期分发，如果需要的话
    observerDispatcher.dispatchStateIfNeed(_lifecycleState);
  }

  @override
  void removeObserver(LifecycleObserver observer) {
    _observerMap.remove(observer);
  }

  @override
  void notify(LifecycleState state) {
    /// 设置当前 widget 生命周期
    _lifecycleState = state;

    /// 分发生命周期
    _dispatchState(state);
  }

  /// 分发当前 widget 生命周期，通知所有被观察者
  void _dispatchState(LifecycleState state) {
    ///copy方式解决并发修改Map
    Map<LifecycleObserver, LifecycleObserverDispatcher> map =
        Map.from(_observerMap);

    if (map.isEmpty) return;

    map.forEach((key, value) {
      value.dispatchState(state);

      ///分发完onDestroy之后移除对象
      if (state == LifecycleState.onDestroy) {
        removeObserver(key);
      }
    });
  }
}

/// 观察者分发器
/// 观察者自身生命周期分发类：包括常规分发 和 延迟分发
/// 延迟分发：如果 观察者 在 widget 初始化时注册，那么两者生命周期一直保持同步；如果 观察者 在 widget 生周期中后期才注册，则会丢失已经过去的前期生命周期回调，需要补上
class LifecycleObserverDispatcher {
  /// 观察者
  final LifecycleObserver observer;

  /// 生命周期感知对象
  final LifecycleOwner owner;

  LifecycleObserverDispatcher(this.owner, this.observer);

  /// 常规分发：观察者生命周期事件分发
  void dispatchState(LifecycleState state) {
    /// 生命周期改变回调
    observer.onLifecycleChanged(owner, state);
  }

  /// 延迟分发：如果 观察者 在 widget 初始化时注册，那么两者生命周期一直保持同步；如果 观察者 在 widget 生周期中后期才注册，则会丢失已经过去的前期生命周期回调，需要补上
  /// 延迟/补充的生命周期分发
  /// 如果用户 #addObserver 时机较晚，会导致前期对应的生命周期丢失，这里延迟分发
  void dispatchStateIfNeed(LifecycleState state) {
    int stateIndex = state.index;

    if (stateIndex >= LifecycleState.onInit.index) {
      dispatchState(LifecycleState.onInit);
    }

    if (stateIndex >= LifecycleState.onCreate.index) {
      dispatchState(LifecycleState.onCreate);
    }

    if (stateIndex >= LifecycleState.onStart.index) {
      dispatchState(LifecycleState.onStart);
    }

    if (stateIndex >= LifecycleState.onResume.index) {
      dispatchState(LifecycleState.onResume);
    }

    /// 以下条件几乎不会触发
    if (stateIndex >= LifecycleState.onPause.index) {
      dispatchState(LifecycleState.onPause);
    }

    if (stateIndex >= LifecycleState.onStop.index) {
      dispatchState(LifecycleState.onStop);
    }

    if (stateIndex >= LifecycleState.onDestroy.index) {
      dispatchState(LifecycleState.onDestroy);
    }
  }
}
