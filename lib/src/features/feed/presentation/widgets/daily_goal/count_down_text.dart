import 'dart:async';

import 'package:flutter/material.dart';

class CountdownText extends StatefulWidget {
  final int minutes; // Changed to int

  const CountdownText({super.key, required this.minutes});

  @override
  State<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  late Timer _timer;
  late DateTime _endTime;

  @override
  void initState() {
    super.initState();
    // Calculate the absolute end time based on the minutes provided.
    // This ensures the timer is accurate even if the UI lags.
    _endTime = DateTime.now().add(Duration(minutes: widget.minutes));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(CountdownText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.minutes != oldWidget.minutes) {
      _endTime = DateTime.now().add(Duration(minutes: widget.minutes));
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final remaining = _endTime.difference(now);

    // If time is up, hide or show 00:00
    if (remaining.isNegative) return const SizedBox.shrink();

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    // Format: MM:SS
    final timeDisplay =
        "${twoDigits(remaining.inMinutes)}:${twoDigits(remaining.inSeconds.remainder(60))}";

    return Text(
      "[$timeDisplay]",
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 10,
        color: Colors.grey[600],
        fontFamily: 'Fredoka',
      ),
    );
  }
}
