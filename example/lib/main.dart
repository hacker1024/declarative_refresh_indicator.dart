import 'dart:async';
import 'dart:math';

import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// An example app that uses [DeclarativeRefreshIndicator].
///
/// The app shows a list of random colors that has a fake generation delay of
/// 2 seconds. Pull to refresh is enabled, and a switch in the app bar can be
/// toggled to force the indicator to display.
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'declarative_refresh_indicator example',
      home: MyListPage(),
    );
  }
}

class MyListPage extends StatefulWidget {
  const MyListPage({Key? key}) : super(key: key);

  @override
  _MyListPageState createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
  static const _rowHeight = 56.0;

  var _randomColors = const <Color>[];
  var _loading = false;
  var _forceShowIndicator = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    _randomColors = _generateRandomColors();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('declarative_refresh_indicator example'),
        actions: [
          Tooltip(
            message: 'Force show the indicator',
            child: Switch(
              value: _forceShowIndicator,
              onChanged: (value) => setState(() => _forceShowIndicator = value),
            ),
          ),
        ],
      ),
      body: DeclarativeRefreshIndicator(
        refreshing: _loading || _forceShowIndicator,
        onRefresh: _load,
        child: ScrollConfiguration(
          behavior: const AlwaysDraggingScrollBehaviour(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _randomColors.length,
            itemExtent: _rowHeight,
            itemBuilder: (context, index) {
              return ColoredBox(
                color: _randomColors[index],
                child: const SizedBox(height: _rowHeight),
              );
            },
          ),
        ),
      ),
    );
  }

  static List<Color> _generateRandomColors() {
    final random = Random();
    return List.generate(100, (_) {
      const alpha = 0x80;
      final rgb = random.nextInt(0xFFFFFF + 1);
      return Color((alpha << (8 * 3)) | rgb);
    });
  }
}

class AlwaysDraggingScrollBehaviour extends MaterialScrollBehavior {
  const AlwaysDraggingScrollBehaviour();

  @override
  Set<PointerDeviceKind> get dragDevices => const {...PointerDeviceKind.values};
}
