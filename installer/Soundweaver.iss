#ifndef AppVersion
  #error AppVersion is required
#endif
#ifndef AppSource
  #error AppSource is required
#endif
#ifndef Bootstrapper
  #error Bootstrapper is required
#endif
#ifndef SetupOutput
  #error SetupOutput is required
#endif

[Setup]
AppId={{A8945704-E6F9-45F0-AF1D-BD1EB4B32FD6}
AppName=织声 · Soundweaver
AppVersion={#AppVersion}
AppPublisher=Sunny-Jiang-chs
AppPublisherURL=https://github.com/Sunny-Jiang-chs/Soundweaver
AppSupportURL=https://github.com/Sunny-Jiang-chs/Soundweaver/issues
DefaultDirName={localappdata}\Programs\Soundweaver
DefaultGroupName=织声 Soundweaver
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
WizardStyle=modern
SetupIconFile={#AppSource}\_internal\audiovttforge\web_static\branding\soundweaver.ico
UninstallDisplayIcon={app}\Soundweaver.exe
OutputDir={#SetupOutput}
OutputBaseFilename=Soundweaver-{#AppVersion}-Setup
Compression=lzma2/fast
SolidCompression=yes
CloseApplications=yes
RestartApplications=no
VersionInfoVersion={#AppVersion}.0

[Tasks]
Name: desktopicon; Description: "Create a desktop shortcut"; Flags: unchecked

[Files]
Source: "{#AppSource}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#Bootstrapper}"; DestName: "WebView2Setup.exe"; Flags: dontcopy

[Icons]
Name: "{group}\织声 Soundweaver"; Filename: "{app}\Soundweaver.exe"
Name: "{autodesktop}\织声 Soundweaver"; Filename: "{app}\Soundweaver.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\Soundweaver.exe"; Description: "Launch Soundweaver"; Flags: nowait postinstall skipifsilent

[Code]
function WebView2Installed: Boolean;
var
  Version: String;
  Key: String;
begin
  Key := 'SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}';
  Result := (RegQueryStringValue(HKCU, Key, 'pv', Version) and (Version <> '') and (Version <> '0.0.0.0')) or
    (RegQueryStringValue(HKLM32, Key, 'pv', Version) and (Version <> '') and (Version <> '0.0.0.0')) or
    (RegQueryStringValue(HKLM64, Key, 'pv', Version) and (Version <> '') and (Version <> '0.0.0.0'));
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: Integer;
begin
  Result := '';
  if not WebView2Installed then begin
    ExtractTemporaryFile('WebView2Setup.exe');
    if not Exec(ExpandConstant('{tmp}\WebView2Setup.exe'), '/silent /install', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then begin
      Result := 'Could not start Microsoft WebView2 installation. Install the WebView2 Evergreen Runtime and retry.';
      Exit;
    end;
    if not WebView2Installed then
      Result := 'Microsoft WebView2 could not be installed. Connect to the Internet, install the WebView2 Evergreen Runtime, and retry.';
  end;
end;
