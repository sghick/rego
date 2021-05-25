import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:rego/net/repo/repo.dart';

class PullRefreshContainer extends StatefulWidget {
  final Future Function() onPullRefresh;
  final Widget child;
  final bool handleCommonError;
  final bool autoRefresh;

  PullRefreshContainer({this.child,
    this.onPullRefresh,
    this.handleCommonError = false,
    this.autoRefresh = false});

  @override
  State<StatefulWidget> createState() {
    return _PullRefreshContainer();
  }
}

class _PullRefreshContainer extends State<PullRefreshContainer> {
  final GlobalKey<RefreshIndicatorState> _key =
  GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    if (widget.onPullRefresh != null && widget.autoRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
        if (_key.currentState != null) {
          _key.currentState.show();
        } else {
          Future.delayed(Duration(milliseconds: 100), () {
            if (_key.currentState != null) {
              _key.currentState.show();
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onPullRefresh == null) {
      return widget.child;
    }
    return RefreshIndicator(
        key: _key, onRefresh: _onPullRefresh, child: widget.child);
  }

  Future<void> _onPullRefresh() {
    var task = widget.onPullRefresh();
    if (task == null) {
      task = Future.delayed(Duration(milliseconds: 500), () {});
    }
    task.catchError((e) {
      //TODO Just comment the code for future refactoring
//      if (!widget.handleCommonError) return;
//      if (e is APIException) {
//        Fluttertoast.showToast(msg: e.msg);
//        if (e == loginRequiredAPIException) {
//          goPage(context, "/login", goBack: false);
//        }
//      } else {
//        Fluttertoast.showToast(msg: "数据请求失败，请重试");
//      }
    });
    return task;
  }

  void showPullRefreshLoading() {
    if (widget.onPullRefresh != null) {
      _key.currentState.show();
    }
  }

  void dismissPullRefreshLoading() {
    if (widget.onPullRefresh != null) {
      _key.currentState.show();
    }
  }
}

class PullRefreshScrollView extends StatelessWidget {
  final Future Function() onPullRefresh;
  final Widget child;
  final bool handleCommonError;
  final bool autoRefresh;

  PullRefreshScrollView({this.child,
    this.onPullRefresh,
    this.handleCommonError = false,
    this.autoRefresh = false});

  @override
  Widget build(BuildContext context) {
    return PullRefreshContainer(
        autoRefresh: autoRefresh,
        handleCommonError: handleCommonError,
        onPullRefresh: onPullRefresh,
        child: FilledScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: child,
        ));
  }
}

class _FilledScrollView extends StatelessWidget {
  final Widget child;
  final ScrollPhysics physics;

  const _FilledScrollView({Key key, this.physics, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.max, children: [
      Expanded(
          child: SingleChildScrollView(
            physics: this.physics,
            child: this.child,
          ))
    ]);
  }
}

class FilledScrollView extends StatelessWidget {
  final Widget child;
  final ScrollPhysics physics;

  const FilledScrollView({Key key, this.physics, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          physics: physics,
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class SimpleListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subTitle;
  final onPressed;

  const SimpleListTile(
      {Key key, this.icon, this.title, this.subTitle, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      child: Container(
        height: 65,
        padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 20),
              child: Icon(
                icon,
                size: 24,
                color: Colors.grey[500],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: titleWidgets(),
              ),
            ),
          ],
        ),
      ),
      onPressed: onPressed,
    );
  }

  List<Widget> titleWidgets() {
    List<Widget> res = [];
    if (isNotEmpty(title)) {
      res.add(Text(
        title,
        style: TextStyle(fontSize: 14, color: Colors.black87),
      ));
    }
    if (isNotEmpty(subTitle)) {
      res.add(Text(
        subTitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.6),
      ));
    }
    return res;
  }
}

typedef Widget RepoWidgetBuilder<T extends Repo>(BuildContext context, T repo,
    Widget child);

Widget repoWidget<T extends Repo>(T repoInstance,
    RepoWidgetBuilder<T> builder) {
  return ChangeNotifierProvider<T>.value(
    value: repoInstance,
    child: Consumer<T>(
      builder: (BuildContext context, T value, Widget child) {
        return builder(context, value, child);
      },
    ),
  );
}
