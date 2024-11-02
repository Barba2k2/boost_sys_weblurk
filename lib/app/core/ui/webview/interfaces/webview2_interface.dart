// lib/src/interfaces/webview2_interfaces.dart
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

typedef NavigateNative = Int32 Function(
  Pointer<NativeType>,
  Pointer<Utf16> source,
);
typedef Navigate = int Function(Pointer<NativeType>, Pointer<Utf16> source);

typedef ExecuteScriptNative = Int32 Function(
  Pointer<NativeType>,
  Pointer<Utf16> javaScript,
  Pointer<Pointer<Utf16>> result,
);
typedef ExecuteScript = int Function(
  Pointer<NativeType>,
  Pointer<Utf16> javaScript,
  Pointer<Pointer<Utf16>> result,
);

typedef AddScriptToExecuteOnDocumentCreatedNative = Int32 Function(
  Pointer<NativeType>,
  Pointer<Utf16> script,
  Pointer<NativeType> handler,
);
typedef AddScriptToExecuteOnDocumentCreated = int Function(
  Pointer<NativeType>,
  Pointer<Utf16> script,
  Pointer<NativeType> handler,
);

typedef ReleaseNative = Int32 Function(Pointer<NativeType>);
typedef Release = int Function(Pointer<NativeType>);

typedef GetCoreWebView2Native = Int32 Function(
  Pointer<NativeType>,
  Pointer<Pointer<ICoreWebView2>>,
);
typedef GetCoreWebView2 = int Function(
  Pointer<NativeType>,
  Pointer<Pointer<ICoreWebView2>>,
);

typedef PutBoundsNative = Int32 Function(Pointer<NativeType>, Pointer<RECT>);
typedef PutBounds = int Function(Pointer<NativeType>, Pointer<RECT>);

typedef CloseNative = Int32 Function(Pointer<NativeType>);
typedef Close = int Function(Pointer<NativeType>);

typedef CreateControllerNative = Int32 Function(
  Pointer<NativeType>,
  IntPtr hwnd,
  Pointer<Pointer<ICoreWebView2Controller>>,
);
typedef CreateController = int Function(
  Pointer<NativeType>,
  int hwnd,
  Pointer<Pointer<ICoreWebView2Controller>>,
);

base class ICoreWebView2 extends Struct {
  @IntPtr()
  external int vtable;
}

base class ICoreWebView2Controller extends Struct {
  @IntPtr()
  external int vtable;
}

base class ICoreWebView2Environment extends Struct {
  @IntPtr()
  external int vtable;
}

base class ICoreWebView2EnvironmentOptions extends Struct {
  @IntPtr()
  external int vtable;
}

base class ICoreWebView2Vtbl extends Struct {
  external Pointer<NativeFunction<NavigateNative>> navigate;
  external Pointer<NativeFunction<ExecuteScriptNative>> executeScript;
  external Pointer<NativeFunction<AddScriptToExecuteOnDocumentCreatedNative>>
      addScriptToExecuteOnDocumentCreated;
  external Pointer<NativeFunction<ReleaseNative>> release;
}

base class ICoreWebView2ControllerVtbl extends Struct {
  external Pointer<NativeFunction<GetCoreWebView2Native>> getCoreWebView2;
  external Pointer<NativeFunction<PutBoundsNative>> putBounds;
  external Pointer<NativeFunction<CloseNative>> close;
}

base class ICoreWebView2EnvironmentVtbl extends Struct {
  external Pointer<NativeFunction<CreateControllerNative>> createController;
}

extension ICoreWebView2Extension on Pointer<ICoreWebView2> {
  Pointer<ICoreWebView2Vtbl> get vtable {
    return Pointer<ICoreWebView2Vtbl>.fromAddress(ref.vtable);
  }

  int navigate(Pointer<Utf16> source) {
    return vtable.ref.navigate.asFunction<Navigate>()(this, source);
  }

  int executeScript(Pointer<Utf16> javaScript, Pointer<Pointer<Utf16>> result) {
    return vtable.ref.executeScript.asFunction<ExecuteScript>()(
      this,
      javaScript,
      result,
    );
  }

  int addScriptToExecuteOnDocumentCreated(
      Pointer<Utf16> script, Pointer<NativeType> handler) {
    return vtable.ref.addScriptToExecuteOnDocumentCreated
        .asFunction<AddScriptToExecuteOnDocumentCreated>()(
      this,
      script,
      handler,
    );
  }

  int release() => vtable.ref.release.asFunction<Release>()(this);
}

extension ICoreWebView2ControllerExtension on Pointer<ICoreWebView2Controller> {
  Pointer<ICoreWebView2ControllerVtbl> get vtable {
    return Pointer<ICoreWebView2ControllerVtbl>.fromAddress(ref.vtable);
  }

  int getCoreWebView2(Pointer<Pointer<ICoreWebView2>> webview) {
    return vtable.ref.getCoreWebView2.asFunction<GetCoreWebView2>()(
        this, webview);
  }

  int putBounds(Pointer<RECT> bounds) {
    return vtable.ref.putBounds.asFunction<PutBounds>()(this, bounds);
  }

  int close() => vtable.ref.close.asFunction<Close>()(this);
}

extension ICoreWebView2EnvironmentExtension
    on Pointer<ICoreWebView2Environment> {
  Pointer<ICoreWebView2EnvironmentVtbl> get vtable {
    return Pointer<ICoreWebView2EnvironmentVtbl>.fromAddress(ref.vtable);
  }

  int createController(
    int hwnd,
    Pointer<Pointer<ICoreWebView2Controller>> controller,
  ) {
    return vtable.ref.createController.asFunction<CreateController>()(
      this,
      hwnd,
      controller,
    );
  }
}
