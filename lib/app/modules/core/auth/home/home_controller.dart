import 'package:mobx/mobx.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../service/home/home_service.dart';
part 'home_controller.g.dart';

class HomeController = HomeControllerBase with _$HomeController;

abstract class HomeControllerBase with Store {
  final HomeService _homeService;

  HomeControllerBase({
    required HomeService homeService,
    required AppLogger logger,
  }) : _homeService = homeService;

  Future<void> saveSchedules() async {
    // final streamerUrls = _controllers
    //     .map(
    //       (controller) => controller.text,
    //     )
    //     .toList();
    // await _homeService.saveSchedules(_selectedDate, streamerUrls);
  }

  Future<void> loadSchedules() async {
    // await _homeService.loadSchedules(_selectedDate, _controllers);
  }

  Future<void> forceUpdateLive() async {
    await _homeService.forceUpdateLive();
  }

  Future<void> updateLists() async {
    await _homeService.forceUpdateLive();
  }
}
