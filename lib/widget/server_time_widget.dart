import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  String _clock = 'Clock';
  // ignore: unused_field
  late Timer? _timer;

  @override
  void initState() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(
          () {
            _clock = DateFormat('HH:mm:ss').format(DateTime.now());
          },
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 95,
          child: Text(
            _clock,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 0,
            ),
          ),
        ),
      ],
    );
  }
}
