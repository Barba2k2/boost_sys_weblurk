// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeController on HomeControllerBase, Store {
  late final _$isInitializedAtom =
      Atom(name: 'HomeControllerBase.isInitialized', context: context);

  @override
  bool get isInitialized {
    _$isInitializedAtom.reportRead();
    return super.isInitialized;
  }

  @override
  set isInitialized(bool value) {
    _$isInitializedAtom.reportWrite(value, super.isInitialized, () {
      super.isInitialized = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: 'HomeControllerBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
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
  WebViewController? get webViewController {
    _$webViewControllerAtom.reportRead();
    return super.webViewController;
  }

  @override
  set webViewController(WebViewController? value) {
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

  late final _$onWebViewCreatedAsyncAction =
      AsyncAction('HomeControllerBase.onWebViewCreated', context: context);

  @override
  Future<void> onWebViewCreated(WebViewController controller) {
    return _$onWebViewCreatedAsyncAction
        .run(() => super.onWebViewCreated(controller));
  }

  late final _$loadSchedulesAsyncAction =
      AsyncAction('HomeControllerBase.loadSchedules', context: context);

  @override
  Future<void> loadSchedules() {
    return _$loadSchedulesAsyncAction.run(() => super.loadSchedules());
  }

  late final _$reloadWebViewAsyncAction =
      AsyncAction('HomeControllerBase.reloadWebView', context: context);

  @override
  Future<void> reloadWebView() {
    return _$reloadWebViewAsyncAction.run(() => super.reloadWebView());
  }

  late final _$HomeControllerBaseActionController =
      ActionController(name: 'HomeControllerBase', context: context);

  @override
  void dispose() {
    final _$actionInfo = _$HomeControllerBaseActionController.startAction(
        name: 'HomeControllerBase.dispose');
    try {
      return super.dispose();
    } finally {
      _$HomeControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isInitialized: ${isInitialized},
isLoading: ${isLoading},
currentChannel: ${currentChannel},
webViewController: ${webViewController}
    ''';
  }
}
