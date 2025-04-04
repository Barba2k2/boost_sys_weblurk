// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeController on HomeControllerBase, Store {
  late final _$isWebViewHealthyAtom =
      Atom(name: 'HomeControllerBase.isWebViewHealthy', context: context);

  @override
  bool get isWebViewHealthy {
    _$isWebViewHealthyAtom.reportRead();
    return super.isWebViewHealthy;
  }

  @override
  set isWebViewHealthy(bool value) {
    _$isWebViewHealthyAtom.reportWrite(value, super.isWebViewHealthy, () {
      super.isWebViewHealthy = value;
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

  late final _$isRecoveringAtom =
      Atom(name: 'HomeControllerBase.isRecovering', context: context);

  @override
  bool get isRecovering {
    _$isRecoveringAtom.reportRead();
    return super.isRecovering;
  }

  @override
  set isRecovering(bool value) {
    _$isRecoveringAtom.reportWrite(value, super.isRecovering, () {
      super.isRecovering = value;
    });
  }

  late final _$onInitAsyncAction =
      AsyncAction('HomeControllerBase.onInit', context: context);

  @override
  Future<void> onInit() {
    return _$onInitAsyncAction.run(() => super.onInit());
  }

  late final _$_recoverWebViewAsyncAction =
      AsyncAction('HomeControllerBase._recoverWebView', context: context);

  @override
  Future<void> _recoverWebView() {
    return _$_recoverWebViewAsyncAction.run(() => super._recoverWebView());
  }

  late final _$onWebViewCreatedAsyncAction =
      AsyncAction('HomeControllerBase.onWebViewCreated', context: context);

  @override
  Future<void> onWebViewCreated(WebviewController controller) {
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

  late final _$reloadWebViewAsyncAction =
      AsyncAction('HomeControllerBase.reloadWebView', context: context);

  @override
  Future<void> reloadWebView() {
    return _$reloadWebViewAsyncAction.run(() => super.reloadWebView());
  }

  @override
  String toString() {
    return '''
isWebViewHealthy: ${isWebViewHealthy},
currentChannel: ${currentChannel},
isScheduleVisible: ${isScheduleVisible},
initialChannel: ${initialChannel},
isRecovering: ${isRecovering}
    ''';
  }
}
