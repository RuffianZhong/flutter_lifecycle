import 'package:flutter/cupertino.dart';
import 'package:flutter_lifecycle_aware/lifecycle_delegate.dart';
import 'package:flutter_lifecycle_aware/lifecycle_observable.dart';
import 'package:flutter_lifecycle_aware/lifecycle_observable_impl.dart';
import 'package:flutter_lifecycle_aware/lifecycle_owner.dart';
import 'package:flutter_lifecycle_aware/lifecycle_route_observer.dart';
import 'package:flutter_lifecycle_aware/lifecycle_state.dart';

/// 生命周期分发核心实现类
///
/// * 继承 StateDelegate 接口，监听 State 对应的生命中周期 *
/// widget 生命周期
/// initState：在整个生命周期中的初始化阶段调用，只会调用一次
/// didChangeDependencies：当 State 对象依赖发生变动时调用
/// didUpdateWidget：当 Widget 状态发生改变时调用；实际上每次更新状态时，Flutter 会创建一个新的 Widget，并在该函数中进行新旧 Widget 对比；一般调用该方法之后会调用 build
/// reassemble：只有在 debug 或 热重载 时调用
/// deactivate：从 Widget Tree 中移除 State 对象时会调用，一般用在 dispose 之前
/// dispose：用于 Widget 被销毁时，通常会在此方法中移除监听或清理数据等，整个生命周期只会执行一次
///
/// * 混入 LifecycleOwner 提供 lifecycle 实现接口 *
///
/// * 混入 WidgetsBindingObserver 监听 App 生命周期改变，前后台切换监听 *
/// AppLifecycleState
/// resumed：应用程序可见且获取焦点状态，回到用户视野
/// inactive：应用程序处于非活动状态，可见但是不可交互的状态
/// paused：应用程序处于用户不可见，不响应用户状态，处于后台运行状态
///
/// * 混入 RouteAware 监听页面 进栈/出栈 相关的监听 *
/// RouteAware
/// didPopNext()：调用时期：顶部路由弹出，当前路由显示
/// didPushNext()：调用时期：新的路由添加入栈，当前路由不再可见
///
class LifecycleDispatcher extends LifecycleDelegate
    with LifecycleOwner, WidgetsBindingObserver, RouteAware {
  final State _state;
  final LifecycleOwner _owner;
  late LifecycleObservableImpl _observable;

  ModalRoute? _modalRoute;

  ///切回到前台时，是否需要调用 onStart
  bool _callStartStateWhenForeground = false;

  LifecycleDispatcher(this._owner, this._state) {
    _observable = LifecycleObservableImpl(_owner);
  }

  /// 分发/更新生命周期状态
  void _dispatchLifecycleState(LifecycleState state) {
    _observable.notify(state);
  }

  @override
  void initState() {
    _dispatchLifecycleState(LifecycleState.onInit);

    ///WidgetsBindingObserver 监听
    WidgetsBinding.instance.addObserver(this);

    ///首次绘制完成，只回调一次
    WidgetsBinding.instance.addPostFrameCallback(_postFrameCallback);
  }

  ///WidgetsBinding绘制完成回调(首次)
  void _postFrameCallback(Duration timeStamp) {
    ///生命周期方法回调
    _dispatchLifecycleState(LifecycleState.onCreate);
    _dispatchLifecycleState(LifecycleState.onStart);
    _dispatchLifecycleState(LifecycleState.onResume);
  }

  @override
  void didChangeDependencies() {
    ///首次调用时添加路由监听，监听 RouteAware 生命周期，用来辅助实现页面 onStart/onResume && onPause/onStop
    if (_modalRoute == null) {
      _modalRoute = ModalRoute.of(_state.context);
      LifecycleRouteObserver.routeObserver
          .subscribe(this, _modalRoute as PageRoute);
    }
  }

  @override
  void deactivate() {
    _dispatchLifecycleState(LifecycleState.onPause);
    _dispatchLifecycleState(LifecycleState.onStop);
  }

  @override
  void dispose() {
    _dispatchLifecycleState(LifecycleState.onDestroy);

    ///WidgetsBindingObserver 注销
    WidgetsBinding.instance.removeObserver(this);

    ///解绑
    LifecycleRouteObserver.routeObserver.unsubscribe(this);
  }

  /// 函数回调时机：1.正常切换前台/后台 2.系统级别弹窗&activity / 自定义开启弹窗&activity
  /// 1.正常切换前后台
  /// 1.1 切到后台：inactive > paused
  /// 1.2 切回前台：resumed
  /// 2.系统级别弹窗&activity / 自定义开启弹窗&activity
  /// 2.1 非全屏：展示：inactive 消失：resumed
  /// 2.1 全屏：展示：inactive > paused 消失：resumed
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /// flutter 所有界面都在同一个Activity/Controller中，因此所有页面都能响应切换前后台的回调
    /// 此处逻辑只需要栈顶页面需要响应 挂起/恢复 回调
    bool isCurrent = _modalRoute?.isCurrent ?? false;
    if (isCurrent) {
      switch (state) {
        case AppLifecycleState.resumed: //恢复交互
          /// 如果执行了 AppLifecycleState.paused 则需要从 onStart 开始
          if (_callStartStateWhenForeground) {
            _dispatchLifecycleState(LifecycleState.onStart);
            _callStartStateWhenForeground = false;
          }

          _dispatchLifecycleState(LifecycleState.onResume);

          break;
        case AppLifecycleState.inactive: //挂起

          ///进入后台 和 从桌面回来 都会执行 inactive 回调，添加逻辑，去除从后台回来的多余执行
          if (!_callStartStateWhenForeground) {
            _dispatchLifecycleState(LifecycleState.onPause);
          }

          break;
        case AppLifecycleState.paused: //停止

          ///切后台执行了 AppLifecycleState.paused ，则认为回到前台生命周期从 onStart 开始
          _callStartStateWhenForeground = true;

          _dispatchLifecycleState(LifecycleState.onStop);
          break;
        case AppLifecycleState.detached: //销毁
          _dispatchLifecycleState(LifecycleState.onDestroy);
          break;
      }
    }
  }

  @override
  LifecycleObservable getLifecycle() {
    return _observable;
  }

  @override
  State<StatefulWidget> getStateful() {
    return _state;
  }

  /// 调用时期：顶部路由弹出，当前路由显示
  @override
  void didPopNext() {
    /// 回到当前 widget onStart/onResume
    _dispatchLifecycleState(LifecycleState.onStart);
    _dispatchLifecycleState(LifecycleState.onResume);
  }

  /// 调用时期：新的路由添加入栈，当前路由不再可见
  @override
  void didPushNext() {
    /// 新的 widget 已经添加入栈，当前 widget 挂起
    _dispatchLifecycleState(LifecycleState.onPause);
    _dispatchLifecycleState(LifecycleState.onStop);
  }
}
