; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Boost SysWeblurk 1.0.8"
#define MyAppVersion "1.0.8"
#define MyAppPublisher "Barba Tech Company"
#define MyAppURL "https://barbatech.soluitons"
#define MyAppExeName "boost_sys_weblurk2.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{6E2B4611-C1B3-4AD1-8C7A-C28899A6C739}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\Boost_SysWeblurk_1_0_8
UninstallDisplayIcon={app}\{#MyAppExeName}
; "ArchitecturesAllowed=x64compatible" specifies that Setup cannot run
; on anything but x64 and Windows 11 on Arm.
ArchitecturesAllowed=x64compatible
; "ArchitecturesInstallIn64BitMode=x64compatible" requests that the
; install be done in "64-bit mode" on x64 or Windows 11 on Arm,
; meaning it should use the native 64-bit Program Files directory and
; the 64-bit view of the registry.
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only).
;PrivilegesRequired=lowest
OutputDir=C:\Projects\BoostTwitch\BoostTeam_Core\boost_sys_weblurk\installers
OutputBaseFilename=boost_sys_weblurk
SetupIconFile=C:\Projects\BoostTwitch\BoostTeam_Core\boost_sys_weblurk\assets\images\cla-boost.ico
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "C:\Projects\BoostTwitch\BoostTeam_Core\boost_sys_weblurk\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Projects\BoostTwitch\BoostTeam_Core\boost_sys_weblurk\build\windows\x64\runner\Release\desktop_webview_window_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Projects\BoostTwitch\BoostTeam_Core\boost_sys_weblurk\build\windows\x64\runner\Release\flutter_secure_storage_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Projects\BoostTwitch\BoostTeam_Core\boost_sys_weblurk\build\windows\x64\runner\Release\flutter_volume_controller_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Projects\BoostTwitch\BoostTeam_Core\boost_sys_weblurk\build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Projects\BoostTwitch\BoostTeam_Core\boost_sys_weblurk\build\windows\x64\runner\Release\screen_retriever_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Projects\BoostTwitch\BoostTeam_Core\boost_sys_weblurk\build\windows\x64\runner\Release\url_launcher_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Projects\BoostTwitch\BoostTeam_Core\boost_sys_weblurk\build\windows\x64\runner\Release\webview_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Projects\BoostTwitch\BoostTeam_Core\boost_sys_weblurk\build\windows\x64\runner\Release\Webview2Loader.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Projects\BoostTwitch\BoostTeam_Core\boost_sys_weblurk\build\windows\x64\runner\Release\window_manager_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Projects\BoostTwitch\BoostTeam_Core\boost_sys_weblurk\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

