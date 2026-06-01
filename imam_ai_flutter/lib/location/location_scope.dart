import 'package:flutter/material.dart';
import '../services/location_service.dart';

class LocationScope extends InheritedNotifier<LocationService> {
  const LocationScope({
    super.key,
    required LocationService locationService,
    required super.child,
  }) : super(notifier: locationService);

  static LocationService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocationScope>();
    assert(scope != null, 'LocationScope not found');
    return scope!.notifier!;
  }
}
