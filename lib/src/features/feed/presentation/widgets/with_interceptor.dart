import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

Widget withInterceptor(Widget child) {
  if (kIsWeb) {
    return PointerInterceptor(child: child);
  }
  return child;
}
