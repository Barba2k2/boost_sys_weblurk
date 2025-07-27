import 'dart:developer';
import 'dart:io';
import 'package:win32audio/win32audio.dart';

class AudioHelper {
  static bool _isMuted = false;
  static double _previousVolume = 1.0;
  static int? _currentProcessId;
  static List<ProcessVolume> _mixerList = [];

  static Future<void> initialize() async {
    try {
      await _findCurrentProcess();
    } catch (e) {
      log('Error initializing AudioHelper: $e');
    }
  }

  static Future<void> _findCurrentProcess() async {
    try {
      _mixerList = await Audio.enumAudioMixer() ?? [];
      _currentProcessId = pid;

      final currentProcess = _mixerList.firstWhere(
        (process) => process.processId == _currentProcessId,
        orElse: () => ProcessVolume(),
      );

      if (currentProcess.processId != 0) {
        _previousVolume = currentProcess.maxVolume;
      }
    } catch (e) {
      log('Error finding current process: $e');
    }
  }

  static Future<void> setApplicationMute(bool mute) async {
    try {
      if (_currentProcessId == null) {
        await _findCurrentProcess();
      }

      if (_currentProcessId == null) {
        throw Exception('Could not find current process ID');
      }

      if (mute == _isMuted) return;

      if (mute) {
        _previousVolume = await getCurrentVolume();
        await Audio.setAudioMixerVolume(_currentProcessId!, 0.0);
        _isMuted = true;
      } else {
        await Audio.setAudioMixerVolume(_currentProcessId!, _previousVolume);
        _isMuted = false;
      }
    } catch (e) {
      log('Error setting audio mute: $e');
      throw Exception('Failed to set audio mute: $e');
    }
  }

  static Future<bool> isApplicationMuted() async {
    return _isMuted;
  }

  static Future<double> getCurrentVolume() async {
    try {
      if (_currentProcessId == null) {
        await _findCurrentProcess();
      }

      _mixerList = await Audio.enumAudioMixer() ?? [];

      final currentProcess = _mixerList.firstWhere(
        (process) => process.processId == _currentProcessId,
        orElse: () => ProcessVolume(),
      );

      if (currentProcess.processId != 0) {
        return currentProcess.maxVolume;
      }

      return _previousVolume;
    } catch (e) {
      log('Error getting current volume: $e');
      return _previousVolume;
    }
  }

  static Future<void> setCurrentVolume(double volume) async {
    try {
      if (_currentProcessId == null) {
        await _findCurrentProcess();
      }

      if (_currentProcessId == null) {
        throw Exception('Could not find current process ID');
      }

      volume = volume.clamp(0.0, 1.0);

      await Audio.setAudioMixerVolume(_currentProcessId!, volume);
      _previousVolume = volume;

      _isMuted = volume == 0.0;
    } catch (e) {
      log('Error setting current volume: $e');
      throw Exception('Failed to set current volume: $e');
    }
  }

  static Future<ProcessVolume?> getCurrentProcessInfo() async {
    try {
      if (_currentProcessId == null) {
        await _findCurrentProcess();
      }

      _mixerList = await Audio.enumAudioMixer() ?? [];

      return _mixerList.firstWhere(
        (process) => process.processId == _currentProcessId,
        orElse: () => ProcessVolume(),
      );
    } catch (e) {
      log('Error getting process info: $e');
      return null;
    }
  }

  static void dispose() {
    _isMuted = false;
    _currentProcessId = null;
    _mixerList.clear();
  }
}
