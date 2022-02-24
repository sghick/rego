import 'package:rego/base_core/widgets/text_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

abstract class BasePage {}

abstract class StatelessPage extends StatelessWidget implements BasePage {}

abstract class StatefulPage extends StatefulWidget implements BasePage {
  PageState<StatefulPage> createPageState();

  @override
  State<StatefulWidget> createState() {
    return createPageState();
  }
}

abstract class PageState<T extends StatefulPage> extends State {}

class BarIcon {
  final IconData icon;
  final onPressed;
  final double size;

  const BarIcon(this.icon, this.onPressed, {this.size = 24});
}

const BarIcon backButton = const BarIcon(Icons.arrow_back, null);
const BarIcon drawerButton = const BarIcon(Icons.menu, null);

class BaseFrame extends StatefulWidget {
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final List<Widget>? persistentFooterButtons;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? drawerScrimColor;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;

  final bool? resizeToAvoidBottomInset;
  final bool primary;
  final DragStartBehavior drawerDragStartBehavior;
  final double? drawerEdgeDragWidth;

  /// custom parts
  final String? title;
  final BarIcon? leadingIcon;
  final BarIcon? actionIcon;
  final bool confirmBackButton;

  const BaseFrame({
    Key? key,
    this.appBar,
    this.title,
    this.leadingIcon,
    this.actionIcon,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.persistentFooterButtons,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
    this.confirmBackButton = false,
  }) : super(
          key: key,
        );

  @override
  State<BaseFrame> createState() {
    return BaseFrameState();
  }
}

class BaseFrameState extends State<BaseFrame> {
  GlobalKey<MutableTextState> titleTextKey = GlobalKey<MutableTextState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _lastPopTime;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var topBar = widget.appBar;
    if (topBar == null && widget.title!.isNotEmpty) {
      topBar = AppBar(
        title: MutableText(
          key: titleTextKey,
          initText: widget.title ?? '',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: leadingWidget(context),
        actions: actionWidgets(),
      );
    }

    Widget coreWidget = Scaffold(
        key: scaffoldKey,
        appBar: topBar,
        body: widget.body,
        floatingActionButton: widget.floatingActionButton,
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
        persistentFooterButtons: widget.persistentFooterButtons,
        drawer: widget.drawer,
        endDrawer: widget.endDrawer,
        bottomNavigationBar: widget.bottomNavigationBar,
        bottomSheet: widget.bottomSheet,
        backgroundColor: widget.backgroundColor,
        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
        primary: widget.primary,
        drawerDragStartBehavior: widget.drawerDragStartBehavior,
        extendBody: widget.extendBody,
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        drawerScrimColor: widget.drawerScrimColor,
        drawerEdgeDragWidth: widget.drawerEdgeDragWidth);

    if (!widget.confirmBackButton) {
      return coreWidget;
    }

    return WillPopScope(
      onWillPop: () async {
        if (_lastPopTime == null ||
            DateTime.now().difference(_lastPopTime!) > Duration(seconds: 1)) {
          _lastPopTime = DateTime.now();
          // Fluttertoast.showToast(msg: '再按一次退出');
          return false;
        }
        return true;
      },
      child: coreWidget,
    );
  }

  Widget leadingWidget(BuildContext context) {
    BarIcon? btn = widget.leadingIcon;
    if (btn == null) {
      btn = BarIcon(Icons.arrow_back, () {
        Navigator.of(context).pop();
      });
    }

    return Builder(builder: (BuildContext context) {
      return IconButton(
        icon: Icon(
          btn!.icon,
          color: Colors.white,
          size: btn.size,
        ),
        onPressed: btn.onPressed,
      );
    });
  }

  List<Widget>? actionWidgets() {
    if (widget.actionIcon == null) {
      return null;
    }

    return [
      Builder(builder: (BuildContext context) {
        return IconButton(
          icon: Icon(
            widget.actionIcon!.icon,
            color: Colors.white,
            size: widget.actionIcon!.size,
          ),
          onPressed: widget.actionIcon!.onPressed,
        );
      })
    ];
  }

  void setTitle(String newTitle) {
    if (titleTextKey.currentState != null) {
      titleTextKey.currentState!.onTextChanged(newTitle);
    }
  }

  void openDrawer() {
    scaffoldKey.currentState!.openDrawer();
  }
}
