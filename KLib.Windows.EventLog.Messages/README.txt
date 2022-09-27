1) Create Messages.mc file like this (MessageId are constants values used in KLib.Windows.EventLog)

#Messages.mc

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
SymbolicName=INFO
Language=English
Information: "%1"
.
Language=Italian
Informazione: "%1"
.

MessageId=0x2
SymbolicName=WARNING
Language=English
Warning: "%1"
.
Language=Italian
Avviso: "%1"
.

MessageId=0x3
SymbolicName=ERROR
Language=English
Error: "%1"
.
Language=Italian
Errore: "%1"
.

---- include last empty line

2) Compile with mc.exe -> mc.exe -U Messages.mc (e.g. file path:"C:\Program Files (x86)\Windows Kits\10\bin\10.0.18362.0\x64\mc.exe")
3) Copy all files generated and include Messages.rc file in delphi project as resource file.
4) Call TEventLog.addEventApplicationToRegistry to registry Event LOG.