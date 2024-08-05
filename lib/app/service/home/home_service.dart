import 'package:flutter/material.dart';

abstract class HomeService {
  Future<void> loadSchedules(
    DateTime selectedDate,
    List<TextEditingController> controllers,
  );
  Future<void> forceUpdateLive();
}
