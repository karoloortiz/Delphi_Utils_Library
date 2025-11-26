{
  KLib Version = 4.0
  The Clear BSD License

  Copyright (c) 2020 by Karol De Nery Ortiz LLave. All rights reserved.
  zitrokarol@gmail.com

  Redistribution and use in source and binary forms, with or without
  modification, are permitted (subject to the limitations in the disclaimer
  below) provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

  * Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  * Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.

  NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY
  THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
  CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
}

unit KLib.VC_Redist;

interface

type
  TVC_RedistVersion = (VC_Redist2013X86, VC_Redist2013X64, VC_Redist2019X64);

  TVC_RedistInstallOpts = record
    fileNameInstaller: string;
    version: TVC_RedistVersion;
    deleteFileAfterInstall: boolean;
    isFileAResource: boolean;
  end;

procedure installVC_RedistIfNotExists(installOptions: TVC_RedistInstallOpts);
procedure installVC_Redist(installOptions: TVC_RedistInstallOpts);
function checkIfVC_RedistIsInstalled(version: TVC_RedistVersion): boolean;
function checkIfVC_Redist2013IsInstalled(accordingWindowsArchitecture: boolean = true): boolean;
function checkIfVC_Redist2013X86IsInstalled: boolean;
function checkIfVC_Redist2013X64IsInstalled: boolean;
function checkIfVC_Redist2019X64IsInstalled: boolean;

implementation

uses
  KLib.FileSystem, KLib.Windows, KLib.Validate,
  System.SysUtils;

procedure installVC_RedistIfNotExists(installOptions: TVC_RedistInstallOpts);
var
  _isVC_RedistInstalled: boolean;
begin
  _isVC_RedistInstalled := checkIfVC_RedistIsInstalled(installOptions.version);
  if not _isVC_RedistInstalled then
  begin
    installVC_Redist(installOptions);
  end;
end;

procedure installVC_Redist(installOptions: TVC_RedistInstallOpts);
var
  _pathFileName: string;
begin
  _pathFileName := installOptions.fileNameInstaller;
  if installOptions.isFileAResource then
  begin
    _pathFileName := getCombinedPathWithCurrentDir(installOptions.fileNameInstaller);
    getResourceAsExeFile(installOptions.fileNameInstaller, _pathFileName);
  end;

  executeAndWaitExe(_pathFileName);

  Sleep(2000);

  if installOptions.deleteFileAfterInstall then
  begin
    deleteFileIfExists(_pathFileName);
  end;

  validateVC_RedistIsInstalled(installOptions.version);
end;

function checkIfVC_RedistIsInstalled(version: TVC_RedistVersion): boolean;
const
  ERR_MSG_VERSION_NOT_SPECIFIED = 'Version of Microsoft Visual C++ Redistributable not being specified.';
var
  VC_RedistIsInstalled: boolean;
begin
  case version of
    TVC_RedistVersion.VC_Redist2013X86:
      VC_RedistIsInstalled := checkIfVC_Redist2013X86IsInstalled;
    TVC_RedistVersion.VC_Redist2013X64:
      VC_RedistIsInstalled := checkIfVC_Redist2013X64IsInstalled;
    TVC_RedistVersion.VC_Redist2019X64:
      VC_RedistIsInstalled := checkIfVC_Redist2019X64IsInstalled;
  else
    raise Exception.Create(ERR_MSG_VERSION_NOT_SPECIFIED);
  end;

  Result := VC_RedistIsInstalled;
end;

function checkIfVC_Redist2013IsInstalled(accordingWindowsArchitecture: boolean = true): boolean;
var
  VC_Redist2013IsInstalled: boolean;

  _windowsArchitecture: TWindowsArchitecture;
begin
  if accordingWindowsArchitecture then
  begin
    _windowsArchitecture := getWindowsArchitecture;
    VC_Redist2013IsInstalled := false;
    case _windowsArchitecture of
      TWindowsArchitecture.WindowsX86:
        VC_Redist2013IsInstalled := checkIfVC_Redist2013X86IsInstalled;
      TWindowsArchitecture.WindowsX64:
        VC_Redist2013IsInstalled := checkIfVC_Redist2013X64IsInstalled;
    end;
  end
  else
  begin
    VC_Redist2013IsInstalled := checkIfVC_Redist2013X86IsInstalled or checkIfVC_Redist2013X64IsInstalled;
  end;

  Result := VC_Redist2013IsInstalled;
end;

function checkIfVC_Redist2013X86IsInstalled: boolean;
const
  HKEY_VCREDIST_X86 = '\SOFTWARE\Microsoft\VisualStudio\12.0\VC\Runtimes\x86';
  HKEY_VCREDIST_X86_V2 = '\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\12.0\VC\Runtimes\x86';
var
  VC_Redist2013X86IsInstalled: boolean;

  _existsHKEY_VCREDIST_X86: boolean;
  _existsHKEY_VCREDIST_X86_V2: boolean;
begin
  _existsHKEY_VCREDIST_X86 := checkIfExistsKeyIn_HKEY_LOCAL_MACHINE(HKEY_VCREDIST_X86);
  _existsHKEY_VCREDIST_X86_V2 := checkIfExistsKeyIn_HKEY_LOCAL_MACHINE(HKEY_VCREDIST_X86_V2);
  VC_Redist2013X86IsInstalled := _existsHKEY_VCREDIST_X86 or _existsHKEY_VCREDIST_X86_V2;

  Result := VC_Redist2013X86IsInstalled;
end;

function checkIfVC_Redist2013X64IsInstalled: boolean;
const
  HKEY_VCREDIST_X64 = '\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\12.0\VC\Runtimes\x64';
var
  existsHKEY_VCREDIST_X64: boolean;
begin
  existsHKEY_VCREDIST_X64 := checkIfExistsKeyIn_HKEY_LOCAL_MACHINE(HKEY_VCREDIST_X64);

  Result := existsHKEY_VCREDIST_X64;
end;

function checkIfVC_Redist2019X64IsInstalled: boolean;
const
  HKEY_VC_REDIST2019_X64 = '\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64';
  VCRUNTIME140_1_DLL = 'vcruntime140_1.dll';
var
  VC_Redist2019X64IsInstalled: boolean;
  _existsHKEY_VC_REDIST2019_X64: boolean;
  _dllExists: boolean;
begin
  _existsHKEY_VC_REDIST2019_X64 := checkIfExistsKeyIn_HKEY_LOCAL_MACHINE(HKEY_VC_REDIST2019_X64);
  _dllExists := checkIfFileExistsInSystem32(VCRUNTIME140_1_DLL);
  VC_Redist2019X64IsInstalled := _existsHKEY_VC_REDIST2019_X64 and _dllExists;

  Result := VC_Redist2019X64IsInstalled;
end;

end.
