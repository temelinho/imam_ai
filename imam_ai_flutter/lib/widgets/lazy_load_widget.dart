import 'package:flutter/material.dart';

class LazyLoadWidget extends StatefulWidget {
  final WidgetBuilder builder;
  final bool isActivated;

  const LazyLoadWidget({
    super.key,
    required this.builder,
    required this.isActivated,
  });

  @override
  State<LazyLoadWidget> createState() => _LazyLoadWidgetState();
}

class _LazyLoadWidgetState extends State<LazyLoadWidget> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isActivated) {
      _initialized = true;
    }

    if (!_initialized) {
      return const SizedBox.shrink();
    }

    return widget.builder(context);
  }
}
