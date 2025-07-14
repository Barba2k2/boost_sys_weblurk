// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeController on HomeControllerBase, Store {
  Computed<String?>? _$currentChannelComputed;

  @override
  String? get currentChannel => (_$currentChannelComputed ??= Computed<String?>(
          () => super.currentChannel,
          name: 'HomeControllerBase.currentChannel'))
      .value;
  Computed<List<ScheduleModel>>? _$currentListSchedulesComputed;

  @override
  List<ScheduleModel> get currentListSchedules =>
      (_$currentListSchedulesComputed ??= Computed<List<ScheduleModel>>(
              () => super.currentListSchedules,
              name: 'HomeControllerBase.currentListSchedules'))
          .value;

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

  late final _$currentTabIndexAtom =
      Atom(name: 'HomeControllerBase.currentTabIndex', context: context);

  @override
  int get currentTabIndex {
    _$currentTabIndexAtom.reportRead();
    return super.currentTabIndex;
  }

  @override
  set currentTabIndex(int value) {
    _$currentTabIndexAtom.reportWrite(value, super.currentTabIndex, () {
      super.currentTabIndex = value;
    });
  }

  late final _$currentChannelListAAtom =
      Atom(name: 'HomeControllerBase.currentChannelListA', context: context);

  @override
  String? get currentChannelListA {
    _$currentChannelListAAtom.reportRead();
    return super.currentChannelListA;
  }

  @override
  set currentChannelListA(String? value) {
    _$currentChannelListAAtom.reportWrite(value, super.currentChannelListA, () {
      super.currentChannelListA = value;
    });
  }

  late final _$currentChannelListBAtom =
      Atom(name: 'HomeControllerBase.currentChannelListB', context: context);

  @override
  String? get currentChannelListB {
    _$currentChannelListBAtom.reportRead();
    return super.currentChannelListB;
  }

  @override
  set currentChannelListB(String? value) {
    _$currentChannelListBAtom.reportWrite(value, super.currentChannelListB, () {
      super.currentChannelListB = value;
    });
  }

  late final _$isLoadingListsAtom =
      Atom(name: 'HomeControllerBase.isLoadingLists', context: context);

  @override
  bool get isLoadingLists {
    _$isLoadingListsAtom.reportRead();
    return super.isLoadingLists;
  }

  @override
  set isLoadingLists(bool value) {
    _$isLoadingListsAtom.reportWrite(value, super.isLoadingLists, () {
      super.isLoadingLists = value;
    });
  }

  late final _$listaASchedulesAtom =
      Atom(name: 'HomeControllerBase.listaASchedules', context: context);

  @override
  List<ScheduleModel> get listaASchedules {
    _$listaASchedulesAtom.reportRead();
    return super.listaASchedules;
  }

  @override
  set listaASchedules(List<ScheduleModel> value) {
    _$listaASchedulesAtom.reportWrite(value, super.listaASchedules, () {
      super.listaASchedules = value;
    });
  }

  late final _$listaBSchedulesAtom =
      Atom(name: 'HomeControllerBase.listaBSchedules', context: context);

  @override
  List<ScheduleModel> get listaBSchedules {
    _$listaBSchedulesAtom.reportRead();
    return super.listaBSchedules;
  }

  @override
  set listaBSchedules(List<ScheduleModel> value) {
    _$listaBSchedulesAtom.reportWrite(value, super.listaBSchedules, () {
      super.listaBSchedules = value;
    });
  }

  late final _$onInitAsyncAction =
      AsyncAction('HomeControllerBase.onInit', context: context);

  @override
  Future<void> onInit() {
    return _$onInitAsyncAction.run(() => super.onInit());
  }

  late final _$switchTabAsyncAction =
      AsyncAction('HomeControllerBase.switchTab', context: context);

  @override
  Future<void> switchTab(int index) {
    return _$switchTabAsyncAction.run(() => super.switchTab(index));
  }

  late final _$_recoverWebViewAsyncAction =
      AsyncAction('HomeControllerBase._recoverWebView', context: context);

  @override
  Future<void> _recoverWebView() {
    return _$_recoverWebViewAsyncAction.run(() => super._recoverWebView());
  }

  late final _$loadInitialChannelsAsyncAction =
      AsyncAction('HomeControllerBase.loadInitialChannels', context: context);

  @override
  Future<void> loadInitialChannels() {
    return _$loadInitialChannelsAsyncAction
        .run(() => super.loadInitialChannels());
  }

  late final _$loadListaAAsyncAction =
      AsyncAction('HomeControllerBase.loadListaA', context: context);

  @override
  Future<void> loadListaA() {
    return _$loadListaAAsyncAction.run(() => super.loadListaA());
  }

  late final _$loadListaBAsyncAction =
      AsyncAction('HomeControllerBase.loadListaB', context: context);

  @override
  Future<void> loadListaB() {
    return _$loadListaBAsyncAction.run(() => super.loadListaB());
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

  late final _$_handleChannelUpdateAsyncAction =
      AsyncAction('HomeControllerBase._handleChannelUpdate', context: context);

  @override
  Future<void> _handleChannelUpdate(String channelUrl) {
    return _$_handleChannelUpdateAsyncAction
        .run(() => super._handleChannelUpdate(channelUrl));
  }

  @override
  String toString() {
    return '''
isWebViewHealthy: ${isWebViewHealthy},
isScheduleVisible: ${isScheduleVisible},
initialChannel: ${initialChannel},
isRecovering: ${isRecovering},
currentTabIndex: ${currentTabIndex},
currentChannelListA: ${currentChannelListA},
currentChannelListB: ${currentChannelListB},
isLoadingLists: ${isLoadingLists},
listaASchedules: ${listaASchedules},
listaBSchedules: ${listaBSchedules},
currentChannel: ${currentChannel},
currentListSchedules: ${currentListSchedules}
    ''';
  }
}
