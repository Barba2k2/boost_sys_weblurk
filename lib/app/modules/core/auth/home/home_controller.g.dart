// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeController on HomeControllerBase, Store {
  late final _$initializationFutureAtom =
      Atom(name: 'HomeControllerBase.initializationFuture', context: context);

  @override
  Future<void> get initializationFuture {
    _$initializationFutureAtom.reportRead();
    return super.initializationFuture;
  }

  bool _initializationFutureIsInitialized = false;

  @override
  set initializationFuture(Future<void> value) {
    _$initializationFutureAtom.reportWrite(value,
        _initializationFutureIsInitialized ? super.initializationFuture : null,
        () {
      super.initializationFuture = value;
      _initializationFutureIsInitialized = true;
    });
  }

  late final _$isScheduleVisibleAtom =
      Atom(name: 'HomeControllerBase.isScheduleVisible', context: context);

  @override
  bool get isScheduleVisible {
    _$isScheduleVisibleAtom.reportRead();
    return super.isScheduleVisible;
  }

  @override
  set isScheduleVisible(bool value) {
    _$isScheduleVisibleAtom.reportWrite(value, super.isScheduleVisible, () {
      super.isScheduleVisible = value;
    });
  }

  late final _$initialChannelAtom =
      Atom(name: 'HomeControllerBase.initialChannel', context: context);

  @override
  String get initialChannel {
    _$initialChannelAtom.reportRead();
    return super.initialChannel;
  }

  @override
  set initialChannel(String value) {
    _$initialChannelAtom.reportWrite(value, super.initialChannel, () {
      super.initialChannel = value;
    });
  }

  late final _$currentChannelAtom =
      Atom(name: 'HomeControllerBase.currentChannel', context: context);

  @override
  String? get currentChannel {
    _$currentChannelAtom.reportRead();
    return super.currentChannel;
  }

  @override
  set currentChannel(String? value) {
    _$currentChannelAtom.reportWrite(value, super.currentChannel, () {
      super.currentChannel = value;
    });
  }

  late final _$webViewControllerAtom =
      Atom(name: 'HomeControllerBase.webViewController', context: context);

  @override
  Webview? get webViewController {
    _$webViewControllerAtom.reportRead();
    return super.webViewController;
  }

  @override
  set webViewController(Webview? value) {
    _$webViewControllerAtom.reportWrite(value, super.webViewController, () {
      super.webViewController = value;
    });
  }

  late final _$onInitAsyncAction =
      AsyncAction('HomeControllerBase.onInit', context: context);

  @override
  Future<void> onInit() {
    return _$onInitAsyncAction.run(() => super.onInit());
  }

  late final _$loadSchedulesAsyncAction =
      AsyncAction('HomeControllerBase.loadSchedules', context: context);

  @override
  Future<void> loadSchedules() {
    return _$loadSchedulesAsyncAction.run(() => super.loadSchedules());
  }

  late final _$initializeWebViewAsyncAction =
      AsyncAction('HomeControllerBase.initializeWebView', context: context);

  @override
  Future<void> initializeWebView(Webview controller) {
    return _$initializeWebViewAsyncAction
        .run(() => super.initializeWebView(controller));
  }

  late final _$_loadInitialChannelAsyncAction =
      AsyncAction('HomeControllerBase._loadInitialChannel', context: context);

  @override
  Future<void> _loadInitialChannel() {
    return _$_loadInitialChannelAsyncAction
        .run(() => super._loadInitialChannel());
  }

  late final _$onWebViewCreatedAsyncAction =
      AsyncAction('HomeControllerBase.onWebViewCreated', context: context);

  @override
  Future<void> onWebViewCreated(Webview controller) {
    return _$onWebViewCreatedAsyncAction
        .run(() => super.onWebViewCreated(controller));
  }

  late final _$loadCurrentChannelAsyncAction =
      AsyncAction('HomeControllerBase.loadCurrentChannel', context: context);

  @override
  Future<void> loadCurrentChannel() {
    return _$loadCurrentChannelAsyncAction
        .run(() => super.loadCurrentChannel());
  }

  late final _$startPollingForUpdatesAsyncAction = AsyncAction(
      'HomeControllerBase.startPollingForUpdates',
      context: context);

  @override
  Future<void> startPollingForUpdates() {
    return _$startPollingForUpdatesAsyncAction
        .run(() => super.startPollingForUpdates());
  }

  late final _$startCheckingScoresAsyncAction =
      AsyncAction('HomeControllerBase.startCheckingScores', context: context);

  @override
  Future<void> startCheckingScores() {
    return _$startCheckingScoresAsyncAction
        .run(() => super.startCheckingScores());
  }

  late final _$reloadWebViewAsyncAction =
      AsyncAction('HomeControllerBase.reloadWebView', context: context);

  @override
  Future<void> reloadWebView() {
    return _$reloadWebViewAsyncAction.run(() => super.reloadWebView());
  }

  @override
  String toString() {
    return '''
initializationFuture: ${initializationFuture},
isScheduleVisible: ${isScheduleVisible},
initialChannel: ${initialChannel},
currentChannel: ${currentChannel},
webViewController: ${webViewController}
    ''';
  }
}
