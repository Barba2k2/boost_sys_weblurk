import 'package:flutter/material.dart';

abstract class HomeService {
  Future<void> saveSchedules(DateTime selectedDate, List<String> streamerUrls);
  Future<void> loadSchedules(
    DateTime selectedDate,
    List<TextEditingController> controllers,
  );
  Future<void> forceUpdateLive();
}
