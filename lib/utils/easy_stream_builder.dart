import 'package:flutter/material.dart';

class EasyStreamBuilder<V> extends StatelessWidget {
  final V initialData;
  final Stream<V> stream;
  final AsyncWidgetBuilder<V> builder, loadBuilder, errorBuilder;

  const EasyStreamBuilder(
      {Key key,
      this.initialData,
      this.stream,
      this.builder,
      this.loadBuilder,
      this.errorBuilder})
      : super(key: key);

  Widget _loadBuilder(BuildContext context, AsyncSnapshot<V> snap) {
    return loadBuilder == null ? Container() : loadBuilder(context, snap);
  }

  Widget _errorBuilder(BuildContext context, AsyncSnapshot<V> snap) {
    return errorBuilder == null ? Container() : errorBuilder(context, snap);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<V>(
      initialData: initialData,
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) return _errorBuilder(context, snap);
        if (!snap.hasData) return _loadBuilder(context, snap);
        return builder(context, snap);
      },
    );
  }
}
