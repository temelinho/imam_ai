import 'package:flutter/material.dart';

/// Sadece ilk aktif olduğunda child oluşturur; IndexedStack yerine tek ekran modunda kullanılmaz.
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
  Widget? _child;

  @override
  void didUpdateWidget(covariant LazyLoadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActivated && _child == null) {
      _child = widget.builder(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActivated && _child == null) {
      return const SizedBox.shrink();
    }
    _child ??= widget.builder(context);
    return _child!;
  }
}
