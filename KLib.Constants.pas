{
  KLib Version = 3.0
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

unit KLib.Constants;

interface

uses
  KLib.Types;

const
  DATE_FORMAT = 'yyyy-mm-dd';
  DATE_FORMAT_ITALIAN = 'dd/mm/yyyy';
  DATETIME_FORMAT = 'yyyy-mm-dd hh:nn:ss';
  DATETIME_FORMAT_ITALIAN = 'dd/mm/yyyy hh:nn:ss';
  TIMESTAMP_FORMAT = 'yyyymmddhhnnss';

  SEMICOLON_DELIMITER = ';';

  DECIMAL_SEPARATOR_IT = ',';
  MYSQL_DECIMAL_SEPARATOR = '.';

  WINDOWS_PATH_DELIMITER = '\';
  LINUX_PATH_DELIMITER = '/';

  LOCALHOST_IP_ADDRESS = '127.0.0.1';
  FTP_DEFAULT_PORT = 21;

  _1_MB_IN_BYTES = 1048576;

  CMD_EXE_NAME = 'cmd.exe';
  //Sysnative is a virtual folder to accessing the 64-bit System32 folder from a 32-bit application
  WINDOWS_SYSTEM32_PATH = 'C:\Windows\Sysnative';

  PNG_TYPE = 'PNG';
  ZIP_TYPE = 'ZIP';
  XSL_TYPE = 'XSL';
  XML_TYPE = 'XML';
  EXE_TYPE = 'EXE';
  JSON_TYPE = 'JSON';
  RTF_TYPE = 'RTF';
  DLL_TYPE = 'DLL';

  EVERYONE_GROUP = 'Everyone';
  USERS_GROUP = 'Users';

  SERVICES_REGKEY = '\SYSTEM\CurrentControlSet\Services';
  EVENTLOG_APPLICATION_REGKEY = SERVICES_REGKEY + '\EventLog\Application';

  C_DRIVE = 'C';

  APPLICATION_JSON_CONTENT_TYPE = 'application/json';

  RANDOM_STRING = '99~@(To4h7KeFSX|{T2M';
  SPACE_STRING = ' ';
  EMPTY_STRING = '';

  EMPTY_ARRAY_OF_STRINGS: TArrayOfStrings = [];

  AUTO_CLEAN = true;
  RUN_AS_ADMIN = true;
  FORCE = true;
  FORCE_OVERWRITE = true;
  FORCE_DELETE = true;
  FORCE_CREATION = true;
  FORCE_SUSPEND = true;
  RAISE_EXCEPTION = true;
  IGNORE_EMPTY_STRINGS = true;
  MODAL_MODE = true;
  CASE_SENSITIVE = true;

  NOT_AUTO_CLEAN = false;
  DISABLE = false;
  NOT_FORCE = false;
  NOT_FORCE_OVERWRITE = false;
  RAISE_EXCEPTION_DISABLED = false;
  NOT_IGNORE_EMPTY_STRINGS = false;
  NOT_MODAL_MODE = false;
  NOT_CASE_SENSITIVE = false;

  //Keystroke Message Flag
  //https://docs.microsoft.com/en-us/windows/win32/inputdev/about-keyboard-input
  //https://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html
  //Keystroke Message Flag impostato ad 1835009 (DECIMAL VALUE) che in binario corrisponde a 0000000000111000000000000000001
  // l_param
  //i valori dallo 0 al 15 specificano il numero di volte che e' stato premuto il tasto
  //(nel nostro caso 0000000000000001)
  //i valori dal 16-23 specificano lo scan code e questo dipende dal produtttore OEM
  //(nel nostro caso 00011100) tastiera Logitech K120
  //il valore 24 se settato a 1 indica se il tasto premuto e' uno steso, come ad esempio un tasto funzione o numerico
  //(nel nostro caso 0)
  //i valori dal 25-28 sono riservati
  //(nel nostro caso 0000)
  //il valore 24 se settato a 1 indica se il tasto premuto il pulsante ALT
  //(nel nostro caso 0)
  //il valore 30 se settato a 1 indica che lo stato precedente del tasto era key_down
  //(nel nostro caso 0)
  //il valore 31 se settato a 1 indica che lo stato transitorio del tasto e' stato appena rilasciato
  //(nel nostro caso 0)

  KF_CODE_ENTER = 1835009;

  REGEX_VALID_EMAIL =
    '([!#-''*+/-9=?A-Z^-~-]+(\.[!#-''*+/-9=?A-Z^-~-]+)*|"([]!#-[^-~ \t]|(\\[\t -~]))+")@([0'
    + '-9A-Za-z]([0-9A-Za-z-]{0,61}[0-9A-Za-z])?(\.[0-9A-Za-z]([0-9A-Za-z-]{0,61}[0-9A-Za-z])'
    + '?)*|\[((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1'
    + '-9]?[0-9])){3}|IPv6:((((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){6}|::((0|[1-9A-Fa-f][0-9A-Fa-'
    + 'f]{0,3}):){5}|[0-9A-Fa-f]{0,4}::((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){4}|(((0|[1-9A-Fa-f]'
    + '[0-9A-Fa-f]{0,3}):)?(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}))?::((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}'
    + '):){3}|(((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){0,2}(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}))?::((0|'
    + '[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){2}|(((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){0,3}(0|[1-9A-Fa-'
    + 'f][0-9A-Fa-f]{0,3}))?::(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):|(((0|[1-9A-Fa-f][0-9A-Fa-f]{0,'
    + '3}):){0,4}(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}))?::)((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):(0|[1-9'
    + 'A-Fa-f][0-9A-Fa-f]{0,3})|(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4]'
    + '[0-9]|1[0-9]{2}|[1-9]?[0-9])){3})|(((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}):){0,5}(0|[1-9A-Fa-'
    + 'f][0-9A-Fa-f]{0,3}))?::(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3})|(((0|[1-9A-Fa-f][0-9A-Fa-f]{0,3'
    + '}):){0,6}(0|[1-9A-Fa-f][0-9A-Fa-f]{0,3}))?::)|(?!IPv6:)[0-9A-Za-z-]*[0-9A-Za-z]:[!-Z^-'
    + '~]+)])';

  REGEX_ONLY_LETTERS_NUMBERS_AND__ = '^[a-zA-Z0-9_.]*$';

implementation

end.
