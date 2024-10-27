#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  RECT workArea;
  SystemParametersInfo(SPI_GETWORKAREA, 0, &workArea, 0);

  // Calcula a largura e altura da área de trabalho
  int workAreaWidth = workArea.right - workArea.left;
  int workAreaHeight = workArea.bottom - workArea.top;

  // Define o tamanho da sua janela
  Win32Window::Size size(1280, 720);

  // Calcula o ponto central (origin)
  Win32Window::Point origin(
      (workAreaWidth - size.width) / 2,    // centraliza horizontalmente
      (workAreaHeight - size.height) / 2    // centraliza verticalmente
  );
  if (!window.Create(L"Boost Team SysWebLurk", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
