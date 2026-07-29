import 'dart:async';
import 'package:flutter/material.dart';
import 'package:practice_app/utils/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_app/blocs/auth/auth_bloc.dart';
import 'package:practice_app/blocs/auth/auth_event.dart';
import 'package:go_router/go_router.dart';

class SessionTimeoutManager extends StatefulWidget {
  final Widget child;
  final Duration timeoutDuration;

  const SessionTimeoutManager({
    super.key,
    required this.child,
    this.timeoutDuration = const Duration(minutes: 30),
  });

  @override
  State<SessionTimeoutManager> createState() => _SessionTimeoutManagerState();
}

class _SessionTimeoutManagerState extends State<SessionTimeoutManager> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeoutDuration, _handleTimeout);
  }

  void _handleUserInteraction([_]) {
    _startTimer();
  }

  void _handleTimeout() {
    final token = LocalStoragePref().getToken();
    if (token != null && token.isNotEmpty) {
      if (mounted) {
        context.read<AuthBloc>().add(LogoutRequested());
        context.go('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired due to inactivity. Please log in again.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handleUserInteraction,
      onPointerMove: _handleUserInteraction,
      onPointerUp: _handleUserInteraction,
      child: widget.child,
    );
  }
}
