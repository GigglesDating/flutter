import 'package:flutter/material.dart';

typedef ErrorWidgetBuilder = Widget Function(
    Object error, StackTrace? stackTrace);

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final ErrorWidgetBuilder onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    required this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Set up error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        _error = details.exception;
        _stackTrace = details.stack;
      });
    };
  }

  @override
  void dispose() {
    // Reset error handler
    FlutterError.onError = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.onError(_error!, _stackTrace);
    }

    return widget.child;
  }
}
