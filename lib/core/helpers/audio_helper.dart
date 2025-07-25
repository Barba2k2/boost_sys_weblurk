import 'dart:developer';
import 'dart:io';
import 'package:win32audio/win32audio.dart';

class AudioHelper {
  static bool _isMuted = false;
  static double _previousVolume = 1.0;
  static int? _currentProcessId;
  static List<ProcessVolume> _mixerList = [];

  // Inicialização - deve ser chamado no início do app
  static Future<void> initialize() async {
    try {
      await _findCurrentProcess();
    } catch (e) {
      log('Error initializing AudioHelper: $e');
    }
  }

  // Encontra o processo atual do app
  static Future<void> _findCurrentProcess() async {
    try {
      _mixerList = await Audio.enumAudioMixer() ?? [];
      _currentProcessId = pid; // Process ID atual do Dart

      // Verifica se o processo está na lista do mixer
      final currentProcess = _mixerList.firstWhere(
        (process) => process.processId == _currentProcessId,
        orElse: () => ProcessVolume(),
      );

      if (currentProcess.processId != 0) {
        _previousVolume = currentProcess.maxVolume;
        log('Current app process found: $_currentProcessId');
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

      if (mute == _isMuted) return; // Already in desired state

      if (mute) {
        // Store current volume and set to 0
        _previousVolume = await getCurrentVolume();
        await Audio.setAudioMixerVolume(_currentProcessId!, 0.0);
        _isMuted = true;
        log('Application audio muted');
      } else {
        // Restore previous volume
        await Audio.setAudioMixerVolume(_currentProcessId!, _previousVolume);
        _isMuted = false;
        log('Application audio unmuted');
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

      // Atualiza a lista do mixer para obter volumes atuais
      _mixerList = await Audio.enumAudioMixer() ?? [];

      final currentProcess = _mixerList.firstWhere(
        (process) => process.processId == _currentProcessId,
        orElse: () => ProcessVolume(),
      );

      if (currentProcess.processId != 0) {
        return currentProcess.maxVolume;
      }

      return _previousVolume; // Fallback
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

      // Clamp volume to 0.0-1.0 range
      volume = volume.clamp(0.0, 1.0);

      // Use win32audio to set the specific app volume
      await Audio.setAudioMixerVolume(_currentProcessId!, volume);
      _previousVolume = volume;

      // Update mute state based on volume
      _isMuted = volume == 0.0;

      log('Volume set to: ${(volume * 100).toStringAsFixed(1)}%');
    } catch (e) {
      log('Error setting current volume: $e');
      throw Exception('Failed to set current volume: $e');
    }
  }

  // Método adicional para obter informações do processo atual
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
