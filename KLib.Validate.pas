{
  KLib Version = 2.0
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

unit KLib.Validate;

interface

uses
  KLib.Types, KLib.VC_Redist, KLib.Constants,
  Vcl.StdCtrls, Vcl.Forms,
  Xml.XMLIntf;

//------REGEX----------
procedure validateThatEmailIsValid(email: string; errMsg: string = 'Invalid email.');
//-------------------
//------VCREDIST-------
procedure validateVC_RedistIsInstalled(version: TVC_RedistVersion; errMsg: string = 'Microsoft Visual C++ Redistributable not correctly installed.');
procedure validateThatVC_Redist2013IsInstalled(errMsg: string = 'Microsoft Visual C++ Redistributable 2013 not correctly installed.');
procedure validateThatVC_Redist2013X86IsInstalled(errMsg: string = 'Microsoft Visual C++ Redistributable 2013 x86 not correctly installed.');
procedure validateThatVC_Redist2013X64IsInstalled(errMsg: string = 'Microsoft Visual C++ Redistributable 2013 x64 not correctly installed.');
procedure validateThatVC_Redist2019X64IsInstalled(errMsg: string = 'Microsoft Visual C++ Redistributable 2019 x64 not correctly installed.');
//-------------------
procedure validateThatServiceNotExists(nameService: string; errMsg: string = 'Service already exists.');
procedure validateThatServiceExists(nameService: string; errMsg: string = 'Service doesn''t exists.');

procedure validateThatPortIsAvaliable(port: Word; host: string = LOCALHOST_IP_ADDRESS;
  errMsg: string = 'Port is not avaliable.');
procedure validateThatPortIsNotAvaliable(port: Word; host: string = LOCALHOST_IP_ADDRESS;
  errMsg: string = 'Port is avaliable.');

procedure validateThatAddressIsLocalhost(address: string; errMsg: string = 'The address does not match with the localhost ip.');
procedure validateThatAddressIsNotLocalhost(address: string; errMsg: string = 'The address match with the localhost ip.');

procedure validateThatWindowsGroupOrUserExists(windowsGroupOrUser: string; errMsg: string = 'Not exists in Windows Groups/Users.');
procedure validateThatWindowsGroupOrUserNotExists(windowsGroupOrUser: string; errMsg: string = 'Already exists in Windows Groups/Users.');

procedure validateFTPCredentials(FTPCredentials: TFTPCredentials; errMsg: string = 'Invalid FTP credentials.');
procedure validateRequiredFTPProperties(FTPCredentials: TFTPCredentials; errMsg: string = 'FTP credentials were not being fully specified.');

procedure validateThatThereIsSpaceAvailableOnDrive(drive: char; requiredSpaceInBytes: int64; errMsg: string = 'There is not enough space available on the Drive.');

procedure validateThatDirNotExists(dirName: string; errMsg: string = 'Directory already exists.');
procedure validateThatDirExists(dirName: string; errMsg: string = 'Directory doesn''t exists.');

procedure validateThatFileExistsAndEmpty(fileName: string; errMsg: string = 'File doesn''t exists or it isn'' empty.');

procedure validateThatFileNotExists(fileName: string; errMsg: string = 'File already exists.');
procedure validateThatFileExists(fileName: string; errMsg: string = 'File doesn''t exists.');

procedure validateThatIXMLNodeExistsInIXMLNode(mainNode: IXMLNode; childNodeName: string; errMsg: string = 'Node not exists.');
procedure validateIXMLNodeName(mainNode: IXMLNode; expectedNodeName: string; errMsg: string = 'Node not expected.');
procedure validateThatAttributeExistsInIXMLNode(mainNode: IXMLNode; attributeName: string; errMsg: string = 'Attribute not exists in node.');

procedure validateThatIsAPath(path: string; errMsg: string = 'Path is not valid.');

procedure validateMD5File(fileName: string; MD5: string; errMsg: string = 'MD5 check failed.');

procedure validateThatRunUnderWine(errMsg: string = 'Program is not running under Wine.');
procedure validateThatNotRunUnderWine(errMsg: string = 'Program is running under Wine.');

procedure validateThatWindowsArchitectureIsX64(errMsg: string = 'Windows architecture not is x64.');

procedure validateThatUserIsAdmin(errMsg: string = 'User doesn''t have administrator privileges.');
procedure validateThatUserIsNotAdmin(errMsg: string = 'User have administrator privileges.');

procedure validateThatExistsKeyIn_HKEY_LOCAL_MACHINE(key: string; errMsg: string = 'Key doesn''t exists in HKEY_LOCAL_MACHINE.');
procedure validateThatNotExistsKeyIn_HKEY_LOCAL_MACHINE(key: string; errMsg: string = 'Key exists in HKEY_LOCAL_MACHINE.');

procedure validateThatIsWindowsSubDir(subDir: string; mainDir: string; errMsg: string = 'It is not a subfolder.');
procedure validateThatIsLinuxSubDir(subDir: string; mainDir: string; errMsg: string = 'It is not a subfolder.');
procedure validateThatIsSubDir(subDir: string; mainDir: string; trailingPathDelimiter: char = SPACE_STRING; errMsg: string = 'It is not a subfolder.');

procedure validateThatWindowExists(className: string = 'TMyForm'; captionForm: string = 'Caption of MyForm';
  errMsg: string = 'No window was found.');

procedure validateThatStringIsNotEmpty(value: string; errMsg: string = 'Value is empty.');

procedure exceptionIfCannotDeleteFile(fileName: string; errMsg: string = 'Cannot delete file.');

procedure validateThatEditIsNotEmpty(myForm: TForm; myEdit: TCustomEdit; myEditDisplayName: string = '';
  errMsg: string = 'The field cannot be empty.');

procedure tryToValidate(validatingMethod: TMethod; errorLabel: TLabel);

implementation

uses
  KLib.Utils, KLib.Windows, KLib.WindowsService, KLib.Indy, KLib.XML,
  System.SysUtils;

//############################----REGEX----##################################
procedure validateThatEmailIsValid(email: string; errMsg: string = 'Invalid email.');
var
  _errMsg: string;
begin
  if not checkIfEmailIsValid(email) then
  begin
    _errMsg := getDoubleQuotedString(email) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

//############################-----VCREDIST-----##################################
procedure validateVC_RedistIsInstalled(version: TVC_RedistVersion; errMsg: string = 'Microsoft Visual C++ Redistributable not correctly installed.');
begin
  if not checkIfVC_RedistIsInstalled(version) then
  begin
    raise Exception.Create(errMsg);
  end;
end;

procedure validateThatVC_Redist2013IsInstalled(errMsg: string = 'Microsoft Visual C++ Redistributable 2013 not correctly installed.');
begin
  if not checkIfVC_Redist2013IsInstalled then
  begin
    raise Exception.Create(errMsg);
  end;
end;

procedure validateThatVC_Redist2013X86IsInstalled(errMsg: string = 'Microsoft Visual C++ Redistributable 2013 x86 not correctly installed.');
begin
  if not checkIfVC_Redist2013X86IsInstalled then
  begin
    raise Exception.Create(errMsg);
  end;
end;

procedure validateThatVC_Redist2013X64IsInstalled(errMsg: string = 'Microsoft Visual C++ Redistributable 2013 x64 not correctly installed.');
begin
  if not checkIfVC_Redist2013X64IsInstalled then
  begin
    raise Exception.Create(errMsg);
  end;
end;

procedure validateThatVC_Redist2019X64IsInstalled(errMsg: string = 'Microsoft Visual C++ Redistributable 2019 x64 not correctly installed.');
begin
  if not checkIfVC_Redist2019X64IsInstalled then
  begin
    raise Exception.Create(errMsg);
  end;
end;

//##################################################################à
procedure validateThatServiceNotExists(nameService: string; errMsg: string = 'Service already exists.');
var
  _errMsg: string;
begin
  if TWindowsService.checkIfExists(nameService) then
  begin
    _errMsg := getDoubleQuotedString(nameService) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatServiceExists(nameService: string; errMsg: string = 'Service doesn''t exists.');
var
  _errMsg: string;
begin
  if not TWindowsService.checkIfExists(nameService) then
  begin
    _errMsg := getDoubleQuotedString(nameService) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatPortIsAvaliable(port: Word; host: string = LOCALHOST_IP_ADDRESS;
  errMsg: string = 'Port is not avaliable.');
var
  _errMsg: string;
begin
  if not checkIfPortIsAvaliable(port, host) then
  begin
    _errMsg := getDoubleQuotedString(host + ':' + IntToStr(port)) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatPortIsNotAvaliable(port: Word; host: string = LOCALHOST_IP_ADDRESS;
  errMsg: string = 'Port is avaliable.');
var
  _errMsg: string;
begin
  if checkIfPortIsAvaliable(port, host) then
  begin
    _errMsg := getDoubleQuotedString(host + ':' + IntToStr(port)) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatAddressIsLocalhost(address: string; errMsg: string = 'The address does not match with the localhost ip.');
var
  _errMsg: string;
begin
  if not checkIfAddressIsLocalhost(address) then
  begin
    _errMsg := getDoubleQuotedString(address) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatAddressIsNotLocalhost(address: string; errMsg: string = 'The address match with the localhost ip.');
var
  _errMsg: string;
begin
  if checkIfAddressIsLocalhost(address) then
  begin
    _errMsg := getDoubleQuotedString(address) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatWindowsGroupOrUserExists(windowsGroupOrUser: string; errMsg: string = 'Not exists in Windows Groups/Users.');
var
  _errMsg: string;
begin
  if not checkIfWindowsGroupOrUserExists(windowsGroupOrUser) then
  begin
    _errMsg := getDoubleQuotedString(windowsGroupOrUser) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatWindowsGroupOrUserNotExists(windowsGroupOrUser: string; errMsg: string = 'Already exists in Windows Groups/Users.');
var
  _errMsg: string;
begin
  if checkIfWindowsGroupOrUserExists(windowsGroupOrUser) then
  begin
    _errMsg := getDoubleQuotedString(windowsGroupOrUser) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateFTPCredentials(FTPCredentials: TFTPCredentials; errMsg: string = 'Invalid FTP credentials.');
begin
  if not checkFTPCredentials(FTPCredentials) then
  begin
    raise Exception.Create(errMsg);
  end;
end;

procedure validateRequiredFTPProperties(FTPCredentials: TFTPCredentials; errMsg: string = 'FTP credentials were not being fully specified.');
begin
  if not checkRequiredFTPProperties(FTPCredentials) then
  begin
    raise Exception.Create(errMsg);
  end;
end;

procedure validateThatThereIsSpaceAvailableOnDrive(drive: char; requiredSpaceInBytes: int64; errMsg: string = 'There is not enough space available on the Drive.');
var
  _errMsg: string;
begin
  if not checkIfThereIsSpaceAvailableOnDrive(drive, requiredSpaceInBytes) then
  begin
    _errMsg := getDoubleQuotedString(drive) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatDirNotExists(dirName: string; errMsg: string = 'Directory already exists.');
var
  _errMsg: string;
begin
  if DirectoryExists(dirName) then
  begin
    _errMsg := getDoubleQuotedString(dirName) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatDirExists(dirName: string; errMsg: string = 'Directory doesn''t exists.');
var
  _errMsg: string;
begin
  if not DirectoryExists(dirName) then
  begin
    _errMsg := getDoubleQuotedString(dirName) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatFileExistsAndEmpty(fileName: string; errMsg: string = 'File doesn''t exists or it isn'' empty.');
var
  _errMsg: string;
begin
  if not checkIfFileExistsAndEmpty(fileName) then
  begin
    _errMsg := getDoubleQuotedString(fileName) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatFileNotExists(fileName: string; errMsg: string = 'File already exists.');
var
  _errMsg: string;
begin
  if checkIfFileExists(fileName) then
  begin
    _errMsg := getDoubleQuotedString(fileName) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatFileExists(fileName: string; errMsg: string = 'File doesn''t exists.');
var
  _errMsg: string;
begin
  if not checkIfFileExists(fileName) then
  begin
    _errMsg := getDoubleQuotedString(fileName) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatIXMLNodeExistsInIXMLNode(mainNode: IXMLNode; childNodeName: string; errMsg: string = 'Node not exists.');
var
  _errMsg: string;
begin
  if not checkIfIXMLNodeExistsInIXMLNode(mainNode, childNodeName) then
  begin
    _errMsg := getDoubleQuotedString(childNodeName) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateIXMLNodeName(mainNode: IXMLNode; expectedNodeName: string; errMsg: string = 'Node not expected.');
var
  _errMsg: string;
begin
  if not checkIXMLNodeName(mainNode, expectedNodeName) then
  begin
    _errMsg := getDoubleQuotedString(expectedNodeName) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatAttributeExistsInIXMLNode(mainNode: IXMLNode; attributeName: string; errMsg: string = 'Attribute not exists in node.');
var
  _errMsg: string;
begin
  if not checkIfAttributeExistsInIXMLNode(mainNode, attributeName) then
  begin
    _errMsg := getDoubleQuotedString(attributeName) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatIsAPath(path: string; errMsg: string = 'Path is not valid.');
var
  _errMsg: string;
begin
  if not checkIfIsAPath(path) then
  begin
    _errMsg := getDoubleQuotedString(path) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateMD5File(fileName: string; MD5: string; errMsg: string = 'MD5 check failed.');
var
  _errMsg: string;
begin
  if not checkMD5File(fileName, MD5) then
  begin
    _errMsg := getDoubleQuotedString(fileName) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatRunUnderWine(errMsg: string = 'Program is not running under Wine.');
begin
  if not checkIfRunUnderWine then
  begin
    raise Exception.Create(errMsg);
  end;
end;

procedure validateThatNotRunUnderWine(errMsg: string = 'Program is running under Wine.');
begin
  if checkIfRunUnderWine then
  begin
    raise Exception.Create(errMsg);
  end;
end;

procedure validateThatWindowsArchitectureIsX64(errMsg: string = 'Windows architecture not is x64.');
begin
  if not checkIfWindowsArchitectureIsX64 then
  begin
    raise Exception.Create(errMsg);
  end;
end;

procedure validateThatUserIsAdmin(errMsg: string = 'User doesn''t have administrator privileges.');
begin
  if not checkIfUserIsAdmin then
  begin
    raise Exception.Create(errMsg);
  end;
end;

procedure validateThatUserIsNotAdmin(errMsg: string = 'User have administrator privileges.');
begin
  if checkIfUserIsAdmin then
  begin
    raise Exception.Create(errMsg);
  end;
end;

procedure validateThatExistsKeyIn_HKEY_LOCAL_MACHINE(key: string; errMsg: string = 'Key doesn''t exists in HKEY_LOCAL_MACHINE.');
var
  _errMsg: string;
begin
  if not checkIfExistsKeyIn_HKEY_LOCAL_MACHINE(key) then
  begin
    _errMsg := getDoubleQuotedString(key) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatNotExistsKeyIn_HKEY_LOCAL_MACHINE(key: string; errMsg: string = 'Key exists in HKEY_LOCAL_MACHINE.');
var
  _errMsg: string;
begin
  if checkIfExistsKeyIn_HKEY_LOCAL_MACHINE(key) then
  begin
    _errMsg := getDoubleQuotedString(key) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatIsWindowsSubDir(subDir: string; mainDir: string; errMsg: string = 'It is not a subfolder.');
begin
  if not checkIfIsWindowsSubDir(subDir, mainDir) then
  begin
    raise Exception.Create(errMsg);
  end;
end;

procedure validateThatIsLinuxSubDir(subDir: string; mainDir: string; errMsg: string = 'It is not a subfolder.');
begin
  if not checkIfIsLinuxSubDir(subDir, mainDir) then
  begin
    raise Exception.Create(errMsg);
  end;
end;

procedure validateThatIsSubDir(subDir: string; mainDir: string; trailingPathDelimiter: char = SPACE_STRING; errMsg: string = 'It is not a subfolder.');
begin
  if not checkIfIsSubDir(subDir, mainDir, trailingPathDelimiter) then
  begin
    raise Exception.Create(errMsg);
  end;
end;

procedure validateThatWindowExists(className: string = 'TMyForm'; captionForm: string = 'Caption of MyForm';
  errMsg: string = 'No window was found.');
var
  _errMsg: string;
begin
  if not checkIfWindowExists(className, captionForm) then
  begin
    _errMsg := getDoubleQuotedString(captionForm) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatStringIsNotEmpty(value: string; errMsg: string = 'Value is empty.');
begin
  if value = '' then
  begin
    raise Exception.Create(errMsg);
  end;
end;

procedure exceptionIfCannotDeleteFile(fileName: string; errMsg: string = 'Cannot delete file.');
var
  _errMsg: string;
begin
  if not DeleteFile(pchar(fileName)) then
  begin
    _errMsg := getDoubleQuotedString(fileName) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure validateThatEditIsNotEmpty(myForm: TForm; myEdit: TCustomEdit; myEditDisplayName: string = '';
  errMsg: string = 'The field cannot be empty.');
var
  _errMsg: string;
begin
  if myEdit.Text = '' then
  begin
    myForm.FocusControl(myEdit);
    _errMsg := getDoubleQuotedString(myEditDisplayName) + ' : ' + errMsg;
    raise Exception.Create(_errMsg);
  end;
end;

procedure tryToValidate(validatingMethod: TMethod; errorLabel: TLabel);
begin
  try
    validatingMethod;
    errorLabel.Visible := false;
  except
    on E: Exception do
    begin
      errorLabel.Caption := e.Message;
      errorLabel.Visible := true;
    end;
  end;
end;

end.
