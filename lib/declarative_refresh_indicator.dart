library declarative_refresh_indicator;

import 'dart:async';

import 'package:flutter/material.dart';

/// A declarative [RefreshIndicator] alternative.
///
/// The API is inspired by [Switch] and [Checkbox]:
/// The indicator itself does not maintain any state. Instead, when the state of
/// the indicator changes, the widget calls the [onRefresh] callback. Most
/// widgets that use an indicator will listen for the [onRefresh] callback and
/// rebuild the indicator with a new [refreshing] value to show and hide it.
///
/// With the exception of [refreshing] and [onRefresh], all properties are
/// equivalent to [RefreshIndicator] properties or function arguments with the
/// same name.
class DeclarativeRefreshIndicator extends StatefulWidget {
  /// Equivalent to [RefreshIndicator.child].
  final Widget child;

  /// Whether the indicator should be shown or hidden.
  ///
  /// `true` shows the indicator, and `false` hides it.
  ///
  /// Remember to rebuild the widget after modifying this value.
  ///
  /// See the [DeclarativeRefreshIndicator] for more information.
  final bool refreshing;

  /// Called when the user triggers a refresh.
  ///
  /// The indicator calls the callback and expects the parent widget to rebuild
  /// the indicator with [refreshing] set to `true`.
  ///
  /// See the [DeclarativeRefreshIndicator] for more information.
  final VoidCallback onRefresh;

  /// Equivalent to the `atTop` argument in [RefreshIndicatorState.show].
  ///
  /// Note: Changes to this value will not appear until the indicator is next
  /// shown.
  final bool atTop;

  /// Equivalent to [RefreshIndicator.displacement].
  final double displacement;

  /// Equivalent to [RefreshIndicator.color].
  final Color? color;

  /// Equivalent to [RefreshIndicator.backgroundColor].
  final Color? backgroundColor;

  /// Equivalent to [RefreshIndicator.notificationPredicate].
  final ScrollNotificationPredicate notificationPredicate;

  /// Equivalent to [RefreshIndicator.semanticsLabel].
  final String? semanticsLabel;

  /// Equivalent to [RefreshIndicator.semanticsValue].
  final String? semanticsValue;

  /// Equivalent to [RefreshIndicator.strokeWidth].
  final double strokeWidth;

  /// Equivalent to [RefreshIndicator.triggerMode].
  final RefreshIndicatorTriggerMode triggerMode;

  const DeclarativeRefreshIndicator({
    Key? key,
    required this.child,
    required this.refreshing,
    required this.onRefresh,
    this.atTop = true,
    this.displacement = 40,
    this.color,
    this.backgroundColor,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.strokeWidth = 2,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
  }) : super(key: key);

  @override
  _DeclarativeRefreshIndicatorState createState() =>
      _DeclarativeRefreshIndicatorState();
}

class _DeclarativeRefreshIndicatorState
    extends State<DeclarativeRefreshIndicator> {
  /// The key used to start the [RefreshIndicator].
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  /// A [Completer] used to stop the [RefreshIndicator]
  Completer<void>? _completer;

  /// As showing the [RefreshIndicator] will always call its refresh callback,
  /// this boolean tells the callback if it should notify the callback given to
  /// the widget by the user.
  ///
  /// When it is true, showing the [RefreshIndicator]
  /// (interactively or programmatically) will call the given callback.
  var _onlyShow = false;

  /// When the [completer] is not in use by the indicator, it must be `null`.
  /// If the completer is `null`, the indicator must be hidden.
  bool get _showing => _completer != null;

  /// Show the indicator without calling the given refresh callback.
  void _show() {
    assert(!_showing, 'Show called, but already showing!');
    // Notify the [RefreshIndicator] callback that the real callback given to
    // this widget by the user should not be called; this is just cosmetic.
    _onlyShow = true;
    // Show the [RefreshIndicator].
    _refreshIndicatorKey.currentState!.show(atTop: widget.atTop);
  }

  /// Hide the indicator.
  void _hide() {
    assert(_showing,
        'Hide called, but not showing! Did you call setState in initState?');
    assert(!_completer!.isCompleted,
        'The completer should never exist in a completed state!');
    _completer!.complete();
    _completer = null;
  }

  @override
  void initState() {
    super.initState();
    // If the indicator should be shown initially, show it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.refreshing) _show();
    });
  }

  @override
  void didUpdateWidget(DeclarativeRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the [refreshing] field has not changed, do nothing.
    if (oldWidget.refreshing == widget.refreshing) return;
    // Otherwise, update the indicator accordingly.
    if (widget.refreshing) {
      // The indicator may have been shown already, if it was shown
      // interactively. If it hasn't, show it now.
      if (!_showing) _show();
    } else {
      _hide();
    }
  }

  Future<void> _onRefresh() async {
    // If this callback was triggered for cosmetic purposes, don't call the
    // given refresh callback, and reset [_onlyShow] for future calls.
    if (_onlyShow) {
      _onlyShow = false;
    } else {
      widget.onRefresh();
    }

    // The completer should not exist at this point.
    // It's created here, and must complete before this callback can be
    // called again.
    assert(_completer == null);

    // Create the completer and use it.
    final completer = Completer<void>();
    _completer = completer;
    await completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _onRefresh,
      displacement: widget.displacement,
      color: widget.color,
      backgroundColor: widget.backgroundColor,
      notificationPredicate: widget.notificationPredicate,
      semanticsLabel: widget.semanticsLabel,
      semanticsValue: widget.semanticsValue,
      strokeWidth: widget.strokeWidth,
      triggerMode: widget.triggerMode,
      child: widget.child,
    );
  }
}
