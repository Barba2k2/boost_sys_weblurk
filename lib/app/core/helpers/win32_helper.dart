import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart' as win32;
import 'package:flutter/widgets.dart';

class Win32Helper {
  static int? _cachedHwnd;

  /// Obtém o HWND da janela Flutter atual
  static Future<int> getFlutterWindowHandle() async {
    // Retorna o HWND em cache se já foi encontrado
    if (_cachedHwnd != null) {
      return _cachedHwnd!;
    }

    // Estrutura para armazenar informações da janela
    final windowInfo = calloc<win32.WINDOWINFO>();

    // Callback para enumerar janelas
    int enumWindowsProc(int hwnd, int lParam) {
      // Verifica se a janela está visível
      if (win32.IsWindowVisible(hwnd) == 0) return win32.TRUE;

      // Obtém informações da classe da janela
      final classNameBuffer = win32.wsalloc(256);
      win32.GetClassName(hwnd, classNameBuffer, 256);
      final className = classNameBuffer.toDartString();
      win32.free(classNameBuffer);

      // Verifica se é uma janela Flutter
      if (className == 'FLUTTER_RUNNER_WIN32_WINDOW') {
        _cachedHwnd = hwnd;
        return win32.FALSE; // Para a enumeração
      }

      return win32.TRUE; // Continua a enumeração
    }

    try {
      // Registra a callback
      final enumWindowCallback = NativeCallable<win32.WNDENUMPROC>.isolateLocal(
        enumWindowsProc,
        exceptionalReturn: 0,
      );

      // Enumera todas as janelas
      win32.EnumWindows(
        enumWindowCallback.nativeFunction,
        0,
      );

      // Libera a callback
      enumWindowCallback.close();

      if (_cachedHwnd == null) {
        throw win32.WindowsException(win32.GetLastError());
      }

      return _cachedHwnd!;
    } finally {
      win32.free(windowInfo);
    }
  }

  /// Obtém o HWND de um widget Flutter específico
  static Future<int> getWidgetWindowHandle(BuildContext context) async {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject == null) {
      throw Exception('RenderObject não encontrado');
    }

    // Obtém as coordenadas globais do widget
    final RenderBox renderBox = renderObject as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // Obtém o HWND da janela principal do Flutter
    final parentHwnd = await getFlutterWindowHandle();

    // Converte as coordenadas do widget para coordenadas da tela
    final point = calloc<win32.POINT>()
      ..ref.x = position.dx.toInt()
      ..ref.y = position.dy.toInt();

    final rect = calloc<win32.RECT>();

    try {
      // Converte coordenadas de cliente para tela
      win32.ClientToScreen(parentHwnd, point);

      // Define a área do widget
      rect.ref.left = point.ref.x;
      rect.ref.top = point.ref.y;
      rect.ref.right = point.ref.x + size.width.toInt();
      rect.ref.bottom = point.ref.y + size.height.toInt();

      // Cria uma janela filha para o widget
      final hwnd = win32.CreateWindowEx(
        0, // dwExStyle
        win32.TEXT('STATIC'), // lpClassName
        win32.TEXT('Flutter Widget Window'), // lpWindowName
        win32.WINDOW_STYLE.WS_CHILD | win32.WINDOW_STYLE.WS_VISIBLE, // dwStyle
        rect.ref.left, // x
        rect.ref.top, // y
        rect.ref.right - rect.ref.left, // width
        rect.ref.bottom - rect.ref.top, // height
        parentHwnd, // hWndParent
        0, // hMenu
        win32.GetModuleHandle(nullptr), // hInstance
        nullptr, // lpParam
      );

      if (hwnd == 0) {
        final error = win32.GetLastError();
        throw win32.WindowsException(error);
      }

      return hwnd;
    } finally {
      win32.free(point);
      win32.free(rect);
    }
  }

  /// Limpa o cache do HWND
  static void clearCache() {
    _cachedHwnd = null;
  }

  /// Verifica se um HWND é válido
  static bool isValidWindow(int hwnd) {
    return win32.IsWindow(hwnd) != 0;
  }

  /// Destrói uma janela criada
  static void destroyWindow(int hwnd) {
    if (isValidWindow(hwnd)) {
      win32.DestroyWindow(hwnd);
    }
  }

  /// Muta o áudio do processo do app (WASAPI)
  static void muteAppAudio() {
    final hrInit =
        win32.CoInitializeEx(nullptr, win32.COINIT_APARTMENTTHREADED);
    if (win32.FAILED(hrInit)) return;
    try {
      final deviceEnumerator = calloc<win32.COMObject>();
      final hrEnum = win32.CoCreateInstance(
        win32.GUIDFromString(win32.CLSID_MMDeviceEnumerator).cast<win32.GUID>(),
        nullptr,
        win32.CLSCTX_ALL,
        win32.GUIDFromString(win32.IID_IMMDeviceEnumerator).cast<win32.GUID>(),
        deviceEnumerator.cast(),
      );
      if (win32.FAILED(hrEnum)) {
        win32.free(deviceEnumerator);
        return;
      }
      final enumerator = win32.IMMDeviceEnumerator(deviceEnumerator);
      final devicePtr = calloc<Pointer<win32.COMObject>>();
      try {
        final hrDev = enumerator.getDefaultAudioEndpoint(0, 1, devicePtr);
        if (win32.FAILED(hrDev) || devicePtr.value == nullptr) {
          return;
        }
        final device = win32.IMMDevice(devicePtr.value);
        final sessionManagerPtr = calloc<Pointer<win32.COMObject>>();
        try {
          final hrSess = device.activate(
            win32.GUIDFromString(win32.IID_IAudioSessionManager2)
                .cast<win32.GUID>(),
            win32.CLSCTX_ALL,
            nullptr,
            sessionManagerPtr.cast(),
          );
          if (win32.FAILED(hrSess) || sessionManagerPtr.value == nullptr) {
            return;
          }
          final sessionManager =
              win32.IAudioSessionManager2(sessionManagerPtr.value);
          final sessionEnumeratorPtr = calloc<Pointer<win32.COMObject>>();
          try {
            final hrEnumSess =
                sessionManager.getSessionEnumerator(sessionEnumeratorPtr);
            if (win32.FAILED(hrEnumSess) ||
                sessionEnumeratorPtr.value == nullptr) {
              return;
            }
            final sessionEnumerator =
                win32.IAudioSessionEnumerator(sessionEnumeratorPtr.value);
            final countPtr = calloc<win32.INT32>();
            try {
              final hrCount = sessionEnumerator.getCount(countPtr);
              if (win32.FAILED(hrCount)) return;
              final count = countPtr.value;
              final pid = win32.GetCurrentProcessId();
              for (var i = 0; i < count; i++) {
                final sessionPtr = calloc<Pointer<win32.COMObject>>();
                try {
                  final hrSessGet = sessionEnumerator.getSession(i, sessionPtr);
                  if (win32.FAILED(hrSessGet) || sessionPtr.value == nullptr) {
                    continue;
                  }
                  final session = win32.IAudioSessionControl2(sessionPtr.value);
                  final sessionPidPtr = calloc<win32.UINT32>();
                  try {
                    final hrPid = session.getProcessId(sessionPidPtr);
                    if (win32.FAILED(hrPid)) continue;
                    if (sessionPidPtr.value == pid) {
                      final simpleVolumePtr =
                          calloc<Pointer<win32.COMObject>>();
                      try {
                        final hrQ = session.queryInterface(
                          win32.GUIDFromString(win32.IID_ISimpleAudioVolume)
                              .cast<win32.GUID>(),
                          simpleVolumePtr.cast(),
                        );
                        if (win32.FAILED(hrQ) ||
                            simpleVolumePtr.value == nullptr) {
                          continue;
                        }
                        final simpleVolume =
                            win32.ISimpleAudioVolume(simpleVolumePtr.value);
                        simpleVolume.setMute(win32.TRUE, nullptr);
                        simpleVolume.release();
                      } finally {
                        win32.free(simpleVolumePtr);
                      }
                    }
                  } finally {
                    win32.free(sessionPidPtr);
                  }
                  session.release();
                } finally {
                  win32.free(sessionPtr);
                }
              }
            } finally {
              win32.free(countPtr);
            }
            sessionEnumerator.release();
          } finally {
            win32.free(sessionEnumeratorPtr);
          }
          sessionManager.release();
        } finally {
          win32.free(sessionManagerPtr);
        }
        device.release();
      } finally {
        win32.free(devicePtr);
      }
      enumerator.release();
      win32.free(deviceEnumerator);
    } catch (e) {
      // ignore
    } finally {
      win32.CoUninitialize();
    }
  }

  /// Desmuta o áudio do processo do app (WASAPI)
  static void unmuteAppAudio() {
    final hrInit =
        win32.CoInitializeEx(nullptr, win32.COINIT_APARTMENTTHREADED);
    if (win32.FAILED(hrInit)) return;
    try {
      final deviceEnumerator = calloc<win32.COMObject>();
      final hrEnum = win32.CoCreateInstance(
        win32.GUIDFromString(win32.CLSID_MMDeviceEnumerator).cast<win32.GUID>(),
        nullptr,
        win32.CLSCTX_ALL,
        win32.GUIDFromString(win32.IID_IMMDeviceEnumerator).cast<win32.GUID>(),
        deviceEnumerator.cast(),
      );
      if (win32.FAILED(hrEnum)) {
        win32.free(deviceEnumerator);
        return;
      }
      final enumerator = win32.IMMDeviceEnumerator(deviceEnumerator);
      final devicePtr = calloc<Pointer<win32.COMObject>>();
      try {
        final hrDev = enumerator.getDefaultAudioEndpoint(0, 1, devicePtr);
        if (win32.FAILED(hrDev) || devicePtr.value == nullptr) {
          return;
        }
        final device = win32.IMMDevice(devicePtr.value);
        final sessionManagerPtr = calloc<Pointer<win32.COMObject>>();
        try {
          final hrSess = device.activate(
            win32.GUIDFromString(win32.IID_IAudioSessionManager2)
                .cast<win32.GUID>(),
            win32.CLSCTX_ALL,
            nullptr,
            sessionManagerPtr.cast(),
          );
          if (win32.FAILED(hrSess) || sessionManagerPtr.value == nullptr) {
            return;
          }
          final sessionManager =
              win32.IAudioSessionManager2(sessionManagerPtr.value);
          final sessionEnumeratorPtr = calloc<Pointer<win32.COMObject>>();
          try {
            final hrEnumSess =
                sessionManager.getSessionEnumerator(sessionEnumeratorPtr);
            if (win32.FAILED(hrEnumSess) ||
                sessionEnumeratorPtr.value == nullptr) {
              return;
            }
            final sessionEnumerator =
                win32.IAudioSessionEnumerator(sessionEnumeratorPtr.value);
            final countPtr = calloc<win32.INT32>();
            try {
              final hrCount = sessionEnumerator.getCount(countPtr);
              if (win32.FAILED(hrCount)) return;
              final count = countPtr.value;
              final pid = win32.GetCurrentProcessId();
              for (var i = 0; i < count; i++) {
                final sessionPtr = calloc<Pointer<win32.COMObject>>();
                try {
                  final hrSessGet = sessionEnumerator.getSession(i, sessionPtr);
                  if (win32.FAILED(hrSessGet) || sessionPtr.value == nullptr) {
                    continue;
                  }
                  final session = win32.IAudioSessionControl2(sessionPtr.value);
                  final sessionPidPtr = calloc<win32.UINT32>();
                  try {
                    final hrPid = session.getProcessId(sessionPidPtr);
                    if (win32.FAILED(hrPid)) continue;
                    if (sessionPidPtr.value == pid) {
                      final simpleVolumePtr =
                          calloc<Pointer<win32.COMObject>>();
                      try {
                        final hrQ = session.queryInterface(
                          win32.GUIDFromString(win32.IID_ISimpleAudioVolume)
                              .cast<win32.GUID>(),
                          simpleVolumePtr.cast(),
                        );
                        if (win32.FAILED(hrQ) ||
                            simpleVolumePtr.value == nullptr) {
                          continue;
                        }
                        final simpleVolume =
                            win32.ISimpleAudioVolume(simpleVolumePtr.value);
                        simpleVolume.setMute(win32.FALSE, nullptr);
                        simpleVolume.release();
                      } finally {
                        win32.free(simpleVolumePtr);
                      }
                    }
                  } finally {
                    win32.free(sessionPidPtr);
                  }
                  session.release();
                } finally {
                  win32.free(sessionPtr);
                }
              }
            } finally {
              win32.free(countPtr);
            }
            sessionEnumerator.release();
          } finally {
            win32.free(sessionEnumeratorPtr);
          }
          sessionManager.release();
        } finally {
          win32.free(sessionManagerPtr);
        }
        device.release();
      } finally {
        win32.free(devicePtr);
      }
      enumerator.release();
      win32.free(deviceEnumerator);
    } catch (e) {
      // ignore
    } finally {
      win32.CoUninitialize();
    }
  }
}
