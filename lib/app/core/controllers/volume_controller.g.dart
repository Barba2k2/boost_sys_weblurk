// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volume_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$VolumeController on VolumeControllerBase, Store {
  late final _$isMutedAtom =
      Atom(name: 'VolumeControllerBase.isMuted', context: context);

  @override
  bool get isMuted {
    _$isMutedAtom.reportRead();
    return super.isMuted;
  }

  @override
  set isMuted(bool value) {
    _$isMutedAtom.reportWrite(value, super.isMuted, () {
      super.isMuted = value;
    });
  }

  late final _$currentVolumeAtom =
      Atom(name: 'VolumeControllerBase.currentVolume', context: context);

  @override
  double get currentVolume {
    _$currentVolumeAtom.reportRead();
    return super.currentVolume;
  }

  @override
  set currentVolume(double value) {
    _$currentVolumeAtom.reportWrite(value, super.currentVolume, () {
      super.currentVolume = value;
    });
  }

  late final _$isVolumeControlAvailableAtom = Atom(
      name: 'VolumeControllerBase.isVolumeControlAvailable', context: context);

  @override
  bool get isVolumeControlAvailable {
    _$isVolumeControlAvailableAtom.reportRead();
    return super.isVolumeControlAvailable;
  }

  @override
  set isVolumeControlAvailable(bool value) {
    _$isVolumeControlAvailableAtom
        .reportWrite(value, super.isVolumeControlAvailable, () {
      super.isVolumeControlAvailable = value;
    });
  }

  late final _$muteAsyncAction =
      AsyncAction('VolumeControllerBase.mute', context: context);

  @override
  Future<void> mute() {
    return _$muteAsyncAction.run(() => super.mute());
  }

  late final _$unmuteAsyncAction =
      AsyncAction('VolumeControllerBase.unmute', context: context);

  @override
  Future<void> unmute() {
    return _$unmuteAsyncAction.run(() => super.unmute());
  }

  late final _$toggleMuteAsyncAction =
      AsyncAction('VolumeControllerBase.toggleMute', context: context);

  @override
  Future<void> toggleMute() {
    return _$toggleMuteAsyncAction.run(() => super.toggleMute());
  }

  late final _$setVolumeAsyncAction =
      AsyncAction('VolumeControllerBase.setVolume', context: context);

  @override
  Future<void> setVolume(double volume) {
    return _$setVolumeAsyncAction.run(() => super.setVolume(volume));
  }

  late final _$getVolumeAsyncAction =
      AsyncAction('VolumeControllerBase.getVolume', context: context);

  @override
  Future<double> getVolume() {
    return _$getVolumeAsyncAction.run(() => super.getVolume());
  }

  @override
  String toString() {
    return '''
isMuted: ${isMuted},
currentVolume: ${currentVolume},
isVolumeControlAvailable: ${isVolumeControlAvailable}
    ''';
  }
}
