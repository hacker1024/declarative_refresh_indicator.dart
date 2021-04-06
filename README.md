# Declarative Refresh Indicator

A declarative [`RefreshIndicator`][RefreshIndicator]
alternative that takes inspiration from the [`Switch`][Switch]
and [`Checkbox`][Checkbox] APIs.

## Usage
Much like the [`Switch`][Switch] and [`Checkbox`][Checkbox] widgets,
`DeclarativeRefreshIndicator` takes `refreshing` and `onRefresh` arguments to
receive state and dispatch events. The widget holds no state of its own.

```dart
class _MyWidgetState extends State<MyWidget> {
  var _loading = false;
  
  void _refresh() async {
    setState(() => _loading = true);
    await _getData();
    if (mounted) setState(() => _loading = false);
  }
  
  @override
  Widget build(BuildContext context) {
    return DeclarativeRefreshIndicator(
      refreshing: _loading,
      onRefresh: _refresh,
      child: /* a scrollable widget */,
    );
  }
}
```

## Why do I need this?
While the simplistic example above isn't hard to implement with a regular
[`RefreshIndicator`][RefreshIndicator], the regular [`RefreshIndicator`][RefreshIndicator]
becomes harder to use with event-based state management systems like BLoC and
Redux, where events or actions are synchronously dispatched and no future is
available.

[RefreshIndicator]: https://api.flutter.dev/flutter/material/RefreshIndicator-class.html
[Switch]: https://api.flutter.dev/flutter/material/Switch-class.html
[Checkbox]: https://api.flutter.dev/flutter/material/Switch-class.html

## License
```
MIT License

Copyright (c) 2021 hacker1024

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```