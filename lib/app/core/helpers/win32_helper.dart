import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
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
    final windowInfo = calloc<WINDOWINFO>();

    // Callback para enumerar janelas
    int enumWindowsProc(int hwnd, int lParam) {
      // Verifica se a janela está visível
      if (IsWindowVisible(hwnd) == 0) return TRUE;

      // Obtém informações da classe da janela
      final classNameBuffer = wsalloc(256);
      GetClassName(hwnd, classNameBuffer, 256);
      final className = classNameBuffer.toDartString();
      free(classNameBuffer);

      // Verifica se é uma janela Flutter
      if (className == 'FLUTTER_RUNNER_WIN32_WINDOW') {
        _cachedHwnd = hwnd;
        return FALSE; // Para a enumeração
      }

      return TRUE; // Continua a enumeração
    }

    try {
      // Registra a callback
      final enumWindowCallback = NativeCallable<WNDENUMPROC>.isolateLocal(
        enumWindowsProc,
        exceptionalReturn: 0,
      );

      // Enumera todas as janelas
      EnumWindows(
        enumWindowCallback.nativeFunction,
        0,
      );

      // Libera a callback
      enumWindowCallback.close();

      if (_cachedHwnd == null) {
        throw WindowsException(GetLastError());
      }

      return _cachedHwnd!;
    } finally {
      free(windowInfo);
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
    final point = calloc<POINT>()
      ..ref.x = position.dx.toInt()
      ..ref.y = position.dy.toInt();

    final rect = calloc<RECT>();

    try {
      // Converte coordenadas de cliente para tela
      ClientToScreen(parentHwnd, point);

      // Define a área do widget
      rect.ref.left = point.ref.x;
      rect.ref.top = point.ref.y;
      rect.ref.right = point.ref.x + size.width.toInt();
      rect.ref.bottom = point.ref.y + size.height.toInt();

      // Cria uma janela filha para o widget
      final hwnd = CreateWindowEx(
        0, // dwExStyle
        TEXT('STATIC'), // lpClassName
        TEXT('Flutter Widget Window'), // lpWindowName
        WINDOW_STYLE.WS_CHILD | WINDOW_STYLE.WS_VISIBLE, // dwStyle
        rect.ref.left, // x
        rect.ref.top, // y
        rect.ref.right - rect.ref.left, // width
        rect.ref.bottom - rect.ref.top, // height
        parentHwnd, // hWndParent
        0, // hMenu
        GetModuleHandle(nullptr), // hInstance
        nullptr, // lpParam
      );

      if (hwnd == 0) {
        final error = GetLastError();
        throw WindowsException(error);
      }

      return hwnd;
    } finally {
      free(point);
      free(rect);
    }
  }

  /// Limpa o cache do HWND
  static void clearCache() {
    _cachedHwnd = null;
  }

  /// Verifica se um HWND é válido
  static bool isValidWindow(int hwnd) {
    return IsWindow(hwnd) != 0;
  }

  /// Destrói uma janela criada
  static void destroyWindow(int hwnd) {
    if (isValidWindow(hwnd)) {
      DestroyWindow(hwnd);
    }
  }
}
