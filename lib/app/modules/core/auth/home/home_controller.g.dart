// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeController on HomeControllerBase, Store {
  Computed<WebViewAdapter>? _$webViewControllerComputed;

  @override
  WebViewAdapter get webViewController => (_$webViewControllerComputed ??=
          Computed<WebViewAdapter>(() => super.webViewController,
              name: 'HomeControllerBase.webViewController'))
      .value;
  Computed<WebViewStateController>? _$stateControllerComputed;

  @override
  WebViewStateController get stateController => (_$stateControllerComputed ??=
          Computed<WebViewStateController>(() => super.stateController,
              name: 'HomeControllerBase.stateController'))
      .value;
  Computed<String?>? _$currentChannelComputed;

  @override
  String? get currentChannel => (_$currentChannelComputed ??= Computed<String?>(
          () => super.currentChannel,
          name: 'HomeControllerBase.currentChannel'))
      .value;
  Computed<bool>? _$isWebViewInitializedComputed;

  @override
  bool get isWebViewInitialized => (_$isWebViewInitializedComputed ??=
          Computed<bool>(() => super.isWebViewInitialized,
              name: 'HomeControllerBase.isWebViewInitialized'))
      .value;

  late final _$initializationErrorAtom =
      Atom(name: 'HomeControllerBase.initializationError', context: context);

  @override
  String? get initializationError {
    _$initializationErrorAtom.reportRead();
    return super.initializationError;
  }

  @override
  set initializationError(String? value) {
    _$initializationErrorAtom.reportWrite(value, super.initializationError, () {
      super.initializationError = value;
    });
  }

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

  late final _$forceUpdateChannelAsyncAction =
      AsyncAction('HomeControllerBase.forceUpdateChannel', context: context);

  @override
  Future<void> forceUpdateChannel() {
    return _$forceUpdateChannelAsyncAction
        .run(() => super.forceUpdateChannel());
  }

  late final _$restartWebViewAsyncAction =
      AsyncAction('HomeControllerBase.restartWebView', context: context);

  @override
  Future<void> restartWebView() {
    return _$restartWebViewAsyncAction.run(() => super.restartWebView());
  }

  late final _$HomeControllerBaseActionController =
      ActionController(name: 'HomeControllerBase', context: context);

  @override
  void toggleScheduleVisibility() {
    final _$actionInfo = _$HomeControllerBaseActionController.startAction(
        name: 'HomeControllerBase.toggleScheduleVisibility');
    try {
      return super.toggleScheduleVisibility();
    } finally {
      _$HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
initializationError: ${initializationError},
initializationFuture: ${initializationFuture},
isScheduleVisible: ${isScheduleVisible},
webViewController: ${webViewController},
stateController: ${stateController},
currentChannel: ${currentChannel},
isWebViewInitialized: ${isWebViewInitialized}
    ''';
  }
}
