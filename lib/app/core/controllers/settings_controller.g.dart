// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SettingsController on SettingsControllerBase, Store {
  late final _$isAudioMutedAtom =
      Atom(name: 'SettingsControllerBase.isAudioMuted', context: context);

  @override
  bool get isAudioMuted {
    _$isAudioMutedAtom.reportRead();
    return super.isAudioMuted;
  }

  @override
  set isAudioMuted(bool value) {
    _$isAudioMutedAtom.reportWrite(value, super.isAudioMuted, () {
      super.isAudioMuted = value;
    });
  }

  late final _$terminateAppAsyncAction =
      AsyncAction('SettingsControllerBase.terminateApp', context: context);

  @override
  Future<void> terminateApp() {
    return _$terminateAppAsyncAction.run(() => super.terminateApp());
  }

  late final _$muteAppAudioAsyncAction =
      AsyncAction('SettingsControllerBase.muteAppAudio', context: context);

  @override
  Future<void> muteAppAudio() {
    return _$muteAppAudioAsyncAction.run(() => super.muteAppAudio());
  }

  @override
  String toString() {
    return '''
isAudioMuted: ${isAudioMuted}
    ''';
  }
}
