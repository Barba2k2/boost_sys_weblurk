import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../service/home/home_service.dart';
part 'home_controller.g.dart';

class HomeController = HomeControllerBase with _$HomeController;

abstract class HomeControllerBase with Store {
  final DateTime _selectedDate;
  final List<TextEditingController> _controllers;
  final HomeService _homeService;

  HomeControllerBase({
    required DateTime selectedDate,
    required List<TextEditingController> controllers,
    required HomeService homeService,
    required AppLogger logger,
  })  : _selectedDate = selectedDate,
        _controllers = controllers,
        _homeService = homeService;

  Future<void> saveSchedules() async {
    final streamerUrls = _controllers
        .map(
          (controller) => controller.text,
        )
        .toList();
    await _homeService.saveSchedules(_selectedDate, streamerUrls);
  }

  Future<void> loadSchedules() async {
    await _homeService.loadSchedules(_selectedDate, _controllers);
  }

  Future<void> forceUpdateLive() async {
    await _homeService.forceUpdateLive();
  }
}
