In Messages.mc remove the lines containing:

Severity=Informational
Facility=Application

###############################
SOURCE: https://www.eurekalog.com/help/eurekalog/index.php?registering_event_source.php

Registering Event Source

Before your application can add events to system log - you must to register your application as source. If you fail to do this, then system will not be able to display your events correctly.

 

The event source is the name of the software that logs the event. It is often the name of the application or the name of a subcomponent of the application if the application is large. You can add a maximum of 16,384 event sources to the registry.

 



 

Event Viewer displays an event from the properly registered event source

 



 

The same event for unregistered event source

 

 

 

Preparing .res file for your application
To report events, you must first define your events in a message text file. Usually, you need only one event (its type will be "error") for all exceptions in your application. However, nothing stops you from having multiple events: you may want to use some "informational" or "warning" events for non-fatal/known exceptions. See this article for tips on construction of your message texts: Logging Guidelines.

 

The following example shows a sample message text file (Messages.mc):

 

MessageIdTypedef=DWORD

SeverityNames=(Success=0x0:STATUS_SEVERITY_SUCCESS

              Informational=0x1:STATUS_SEVERITY_INFORMATIONAL

              Warning=0x2:STATUS_SEVERITY_WARNING

              Error=0x3:STATUS_SEVERITY_ERROR

             )

FacilityNames=(System=0x0:FACILITY_SYSTEM

              Runtime=0x2:FACILITY_RUNTIME

              Stubs=0x3:FACILITY_STUBS

              Io=0x4:FACILITY_IO_ERROR_CODE

             )

LanguageNames=(English=0x409:MSG00409)

LanguageNames=(Italian=0x410:MSG00410)

MessageId=0x1

Severity=Error

Facility=Runtime

SymbolicName=mcEurekaLogErrorMessage

Language=English

There was an exception "%1" in the service.

See %2 file for more information.

.

Language=Italian

C'e stato un eccezione "%1" nel servizio.

Vedere il file %2 per ulteriori informazioni.

.

 

Warning: there must be line break at the last line with dot (.) in .mc file. In other words: you should add a blank line at the end of the file.

 

This file defines one event with ID #1, which is represented in two languages: English and Italian. This event has error type and uses two variable parts (%1 and %2) in its error text.

 

To compile the Unicode message text file, use the following command:

 

mc -U Messages.mc

 

MC.exe is Message Compiler tool, which is included with Visual Studio (Express edition does not include MC tool) or Windows SDK for Windows 7 (Windows SDK for Windows 8 does not include command line tools). Compiling .mc file will give you a C++ header file (.h file). Example of content from .h file for the above example of .mc file:
(e.g. C:\Program Files (x86)\Windows Kits\10\bin\10.0.18362.0\x64)
 

//
//  Values are 32 bit values laid out as follows:
//
//   3 3 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1
//   1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
//  +---+-+-+-----------------------+-------------------------------+
//  |Sev|C|R|     Facility          |               Code            |
//  +---+-+-+-----------------------+-------------------------------+
//
//  where
//
//      Sev - is the severity code
//
//          00 - Success
//          01 - Informational
//          10 - Warning
//          11 - Error
//
//      C - is the Customer code flag
//
//      R - is a reserved bit
//
//      Facility - is the facility code
//
//      Code - is the facility's status code
//
//
// Define the facility codes
//
#define FACILITY_SYSTEM                  0x0
#define FACILITY_STUBS                   0x3
#define FACILITY_RUNTIME                 0x2
#define FACILITY_IO_ERROR_CODE           0x4
 
 
//
// Define the severity codes
//
#define STATUS_SEVERITY_WARNING          0x2
#define STATUS_SEVERITY_SUCCESS          0x0
#define STATUS_SEVERITY_INFORMATIONAL    0x1
#define STATUS_SEVERITY_ERROR            0x3
 
 
//
// MessageId: mcEurekaLogErrorMessage
//
// MessageText:
//
// There was an exception "%1" in the service.
// See %2 file for more information.
//
#define mcEurekaLogErrorMessage          ((DWORD)0xC0020001L)

 

You can safely delete this file (you can also look inside to analyze if everything had gone as expected). Note the constant for mcEurekaLogErrorMessage ($C0020001). This is a full ident of your event. This constant includes event kind ($C for "Error") and facility ID ($2 for "Facility RunTime"), as well as event's ID itself (1).

 

Important: Remember this constant as you would need to enter it into your configuration. If you're using the sample above (severity = error, facility = runtime) then this number will always have form of $C002XXXX (where XXXX is hexadecimal representation of event's ID) .

 

You will also get a set of .bin files (MSG00409.bin, MSG00410.bin, etc.) - one for each language, and a .rc file - template for resource compiler. Example of .rc file for our case:

 

LANGUAGE 0x10,0x1

1 11 "MSG00410.bin"

LANGUAGE 0x9,0x1

1 11 "MSG00409.bin"

 

Next, you should compile auto-generated .rc file with the following command:

 

rc -r Messages.rc

 

RC.exe is Microsoft resource compiler tool, which can be found in the same location as MC.exe. You can also use resource compiler included with Delphi or C++ Builder IDE. Compiling .rc file will give you the .res file. You can delete .rc and .bin files after obtaining .res file.

 

Now you can include .res file into your application: "Project" / "Add to project" or {$R Messages.res} (Delphi only).

 

Note: instead of manually compiling .rc file - you can instruct Delphi IDE to automatically compile it into .res file. You can do this by placing the following line into your project source file:

 

{$R 'Messages.res' 'Messages.rc'}

 

Of course, this approach means that you must keep all .rc and .bin files around.

 

Tip: you can use the following command batch file to fully regenerate .res file from .mc file with deleting all temp/intermediate files:

 

@echo off

del Messages.res > NUL

mc -u -U Messages.mc

del Messages.h > NUL

rc -r Messages.rc

del Messages.rc > NUL

del MSG*.bin > NUL

 

(you may need to adjust paths to mc/rc tools)

 

Note: you can look at NT Service Application demo which is shipped with EurekaLog.

 

 

Registering resource file
Once you obtained .res file and included it into your application (typically: you include .res file into .exe file, but you can also include .res file into standalone DLL), now you can register your executable as event source. You can do this by adding a certain registry subkey, for example:

 

uses
  Registry;
 
procedure TServiceForm.ServiceAfterInstall(Sender: TService);
const
  EVENTLOG_AUDIT_FAILURE    = $0010;
  EVENTLOG_AUDIT_SUCCESS    = $0008;
  EVENTLOG_ERROR_TYPE       = $0001;
  EVENTLOG_INFORMATION_TYPE = $0004;
  EVENTLOG_WARNING_TYPE     = $0002;
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(KEY_ALL_ACCESS);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey
       ('\SYSTEM\CurrentControlSet\Services\Eventlog\Application\' + Name, True) then
    begin

 
      // Indicate where to look for message texts
      Reg.WriteString
        ('\SYSTEM\CurrentControlSet\Services\Eventlog\Application\' + Name, 
        'EventMessageFile', ParamStr(0));

 
      // Indicate which message types can be reported
      TRegistry(Reg).WriteInteger('TypesSupported', 
        EVENTLOG_ERROR_TYPE or EVENTLOG_INFORMATION_TYPE or EVENTLOG_WARNING_TYPE);

 
    end;
  finally
    FreeAndNil(Reg);
  end;
end;

 
procedure TServiceForm.ServiceBeforeUninstall(Sender: TService);
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(KEY_ALL_ACCESS);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    Reg.EraseSection('\SYSTEM\CurrentControlSet\Services\Eventlog\Application\' + Name);
  finally
    FreeAndNil(Reg);
  end;
end;

 

This sample code assumes that your application is Win32 service application, so we can use Pre/Post-install events to register/unregister our application file as event source. It also assumes that messages (.res file) are included into main executable (.exe file). You can replace ParamStr(0) with another name (like resource DLL).

 

There are 3 standard logs (Application, System and Security) and arbitrary number of custom logs. Normally, your application would use "Application" standard log. The above code snippet assumes that. You may also use custom log for your application.

 

Please note that this code example uses service name as event source name. This name must be specified later in dialog options.

 

Note: you can look at NT Service Application demo which is shipped with EurekaLog.