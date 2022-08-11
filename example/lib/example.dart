import 'package:flutter/material.dart';
import 'package:flutter_lifecycle_aware/lifecycle.dart';
import 'package:flutter_lifecycle_aware/lifecycle_observer.dart';
import 'package:flutter_lifecycle_aware/lifecycle_owner.dart';
import 'package:flutter_lifecycle_aware/lifecycle_state.dart';

/// Sample
class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

/// (StatefulWidget) with Lifecycle and addObserver(LifecycleObserver)
class _ExamplePageState extends State<ExamplePage> with Lifecycle {
  @override
  void initState() {
    super.initState();

    /// register LifecycleObserver
    getLifecycle().addObserver(AViewModel());
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

/// everywhere you need StatefulWidget's lifecycle
class AViewModel extends LifecycleObserver {
  /// some res need to release
  ScrollController controller = ScrollController();

  /// init data
  void initData() {}

  /// release res
  void destroy() {
    controller.dispose();
  }

  /// listening StatefulWidget's lifecycle
  @override
  void onLifecycleChanged(LifecycleOwner owner, LifecycleState state) {
    if (state == LifecycleState.onCreate) {
      initData();
    } else if (state == LifecycleState.onDestroy) {
      destroy();
    }
  }
}
