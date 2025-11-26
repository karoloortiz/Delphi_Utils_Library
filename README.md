# KLib - Modern Delphi Utility Library

[![License](https://img.shields.io/badge/license-BSD--3--Clause-blue.svg)](LICENSE)
[![Delphi](https://img.shields.io/badge/Delphi-7%2B-red.svg)](https://www.embarcadero.com/products/delphi)
[![Version](https://img.shields.io/badge/version-4.0-green.svg)](https://github.com/karoloortiz/Delphi_Utils_Library)
![Express-like API](https://img.shields.io/badge/Express--like-REST%20API-green)
  ![Async/Await](https://img.shields.io/badge/Async-Promises-blue)

A comprehensive utility library for Delphi providing **async/await patterns**, **database abstractions**, **Windows services**, **Http server Express.js - like**, **networking**, **Utils functions** and **UI components**.

---

## ✨ Features

- 🔄 **Async/Promise** - JavaScript-style Promises with `then`/`catch`/`finally` chaining
- 🌐 **REST API Server** - Express.js-like HTTP server with routing, middleware, and helpers
- 🪟 **Windows Services** - Complete service framework with threading and HTTP adapters
- 🔧 **100+ Validation Functions** - Comprehensive validation library for files, services, networks
- 🎨 **UI Components** - Ready-to-use VCL forms (Message, Wait, RTF, Presentation)
- 📝 **Fluent String API** - Method chaining for string operations with C#-like extensions
- 🧵 **Threading** - Enhanced thread management with events and callbacks
- 📊 **JSON Serialization** - Attribute-based RTTI serialization with validation
- 🔌 **Dependency Injection** - Lightweight DI container with singleton/transient lifetimes
- 📅 **Date Range Utilities** - Advanced algorithms for splitting and processing date ranges
- 🖼️ **Helper Extensions** - Class helpers for arrays, string lists, and UI controls
- 🗄️ **Database** - Coming soon: MySQL, SQLite, PostgreSQL unified interface

---

## 🎯 Library Philosophy

### Born from Practical Experience

KLib emerged from years of real-world Delphi development, addressing a common challenge faced by developers: **repetitive code patterns** that resurface across multiple projects. Instead of rewriting the same validation logic, string utilities, async patterns, and service frameworks for every new application, KLib consolidates these solutions into a single, well-architected library.

### The DRY Principle in Action

**Don't Repeat Yourself** - this fundamental software development principle guided KLib's creation. By extracting common functionality that Delphi developers frequently reimplement, KLib provides:

- **Consistent implementations** of complex patterns
- **Battle-tested solutions** for recurring challenges
- **Maintainable codebase** with centralized improvements
- **Rapid development** through ready-to-use components

### Clean Code Foundation

Every component in KLib adheres to clean code principles:

```pascal
// Before: Repetitive validation code across projects
if not DirectoryExists('C:\Data') then
  raise Exception.Create('Directory not found');
if not FileExists('config.ini') then
  raise Exception.Create('Config file missing');
// ... more repetitive checks

// After: Clean, expressive validation
validateThatDirectoryExists('C:\Data');
validateThatFileExists('config.ini');
validateThatServiceIsRunning('MySQL');
```

### Unified Solution for Common Challenges

KLib addresses the fragmentation of utility code that typically spreads across:
- **Copy-pasted code snippets** between projects
- **Inconsistent implementations** of similar functionality
- **Reinvented solutions** for solved problems
- **Disconnected utility functions** without unified architecture

---

## 🚀 Why Choose KLib?

### Enterprise-Grade Delphi Solutions

KLib delivers **modern programming paradigms** to Delphi development, bringing patterns typically found in JavaScript, C#, and Python to the Object Pascal ecosystem.

#### 1. JavaScript-Style Promises for Delphi
Full ES6 Promise implementation for asynchronous programming:
```pascal
TPromise.Create(procedure(resolve, reject: TCallBack)
  begin
    // Background work
    DoHeavyProcessing();
    resolve('Done!');
  end)
  ._then(procedure(result: string)
    begin
      ShowMessage(result);
    end)
  ._catch(procedure(error: string)
    begin
      LogError(error);
    end)
  ._finally;

// Promise.All - wait for multiple operations
TPromise.all([FetchUsers, FetchOrders, FetchProducts])
  ._then(procedure(msg: string)
    begin
      RefreshUI();
    end)
  ._finally;
```
**Clean asynchronous code** without callback nesting complexity.

---

#### 2. Fluent String API
Method chaining for string operations with C#-inspired syntax:
```pascal
uses KLib.mystring;

var sql: mystring;
sql := 'SELECT * FROM users WHERE id = :id AND status = :status';
sql.setParamAsInteger('id', 123)
   .setParamAsString('status', 'active')
   .saveToFile('query.sql');

// HTML escaping + quoting in one line
var safeHTML := userInput.escapeHTML().doubleQuote();

// Encryption/decryption built-in
var encrypted := password.encrypt('mySecretKey');
var decrypted := encrypted.decrypt('mySecretKey');
```
**Streamlined string manipulation** with reduced intermediate variable overhead.

---

#### 3. Comprehensive Validation Framework
Extensive validation library with 100+ functions:
```pascal
uses KLib.Validate;

// Service validation
validateThatServiceExists('MyWindowsService');
validateThatServiceIsRunning('MySQL');

// Security validation
validateThatUserIsAdmin();
validateThatUserBelongsToGroup('Administrators');

// Path validation
validateThatDirectoryExists('C:\Data');
validateThatFileExists('config.ini');
validateThatPathExists('\\server\share');

// FTP/Network validation
validateThatFTPCredentialsAreValid(host, user, pass);
validateThatPortIsOpen('localhost', 8080);

// XML validation
validateThatXMLIsWellFormed(xmlString);
```
**Production-ready validation** eliminating repetitive validation code.

---

#### 4. Attribute-Based JSON Serialization
RTTI-powered serialization with built-in validation:
```pascal
uses KLib.Generics.JSON, KLib.Generics.Attributes;

type
  TUserDTO = record
    [Required]
    [CustomName('user_id')]
    id: Integer;

    [Required]
    [MinValue(3)]
    [MaxValue(50)]
    username: string;

    [DefaultValue('user@example.com')]
    email: string;

    [Ignore]  // Won't be serialized
    internalFlag: Boolean;
  end;

var
  user: TUserDTO;
  json: string;
begin
  // Automatic validation + serialization
  json := TJSONGenerics.getJSONAsString<TUserDTO>(user);

  // Automatic deserialization + validation
  user := TJSONGenerics.getParsedJSON<TUserDTO>(json);
end;
```
**Declarative data contracts** with automatic validation enforcement.

---

#### 5. Zero-Boilerplate Windows Services
Streamlined Windows service creation:
```pascal
procedure TMyService.ServiceCreate(Sender: TObject);
begin
  serviceApp := TThreadAdapter.Create(
    procedure  // Your service logic
    begin
      while not TMyThread(TThread.CurrentThread).isStopped do
      begin
        ProcessQueue();
        Sleep(5000);
      end;
    end,
    procedure(error: string)  // Error handling
    begin
      LogToEventLog(error);
    end
  );
end;

// Install: MyService.exe --install
// Uninstall: MyService.exe --uninstall
```
**Rapid service development** focusing on business logic rather than infrastructure.

---

#### 6. Date Range Processing
Advanced date algorithms for business applications:
```pascal
uses KLib.DateTimeUtils;

// Split date range into months
var months := splitByMonths(StartDate, EndDate);

// Divide date range into N parts
var divisions := divideDateRange(StartDate, EndDate, 10);

for var period in months do
begin
  GenerateReport(period.StartDate, period.EndDate);
end;
```
**Enterprise reporting utilities** for common date range challenges.

---

#### 7. Express.js-Style REST API
Modern HTTP server with familiar web framework patterns:
```pascal
uses KLib.MyIdHTTPServer;

var app := TMyIdHTTPServer.create(8080);
var router := app.getRouter;

// RESTful routes with parameters
router.get('/api/users/:id', procedure(req, res, params)
begin
  var userId := params['id'];
  var user := GetUserById(userId);
  res.jsonSuccess(user);
end);

router.post('/api/users', procedure(req, res, params)
begin
  var userData := req.parseJSON;
  CreateUser(userData);
  res.jsonSuccess(nil, 'User created');
end);

// Middleware support
app.use(procedure(req, res, next)
begin
  LogRequest(req.Document);
  next();
end);

// CORS, static files, error handling
app.enableCors := true;
```
**Web-developer friendly** API patterns for building REST services.

---

#### 8. Class Helper Extensions
Extend built-in Delphi types with useful methods:
```pascal
uses KLib.ArrayHelper, KLib.StringListHelper;

// Array helpers
if myArray.Contains(searchValue) then
  index := myArray.IndexOf(searchValue);

// StringList helpers
myList.AddIfNotExists('unique-value');
var items := myList.ToArray;
```
**Enhanced productivity** with intuitive extension methods.

---

#### 9. Dependency Injection Container
Lightweight DI container with lifetime management:
```pascal
uses KLib.DiContainer;

// Register services
Container.RegisterSingleton<ILogger>(TFileLogger);
Container.RegisterTransient<IRepository>(TUserRepository);

// Resolve dependencies
var logger := Container.Resolve<ILogger>;
var repo := Container.Resolve<IRepository>;
```
**Testable architecture** with minimal configuration overhead.

---

### Production-Ready Quality

- ✅ **Memory Safe**: All resources properly managed with `FreeAndNil`
- ✅ **Thread Safe**: Promise operations run in isolated threads with automatic COM initialization
- ✅ **Exception Safe**: try-finally blocks throughout the codebase
- ✅ **Battle Tested**: Production-proven in enterprise environments since 2020
- ✅ **Clear BSD License**: Commercial-friendly licensing without restrictions

---

## 🚀 Quick Start

### Promises & Async Programming

```pascal
uses KLib.Promise, KLib.Asyncify;

// Simple promise
procedure ExecuteAsync;
var
  promise: TPromise;
begin
  promise := TPromise.Create(
    procedure(resolve: TCallBack; reject: TCallBack)
    begin
      // Do work in background thread
      Sleep(1000);
      resolve('Done!');
    end,
    procedure(value: string)  // then
    begin
      ShowMessage('Success: ' + value);
    end,
    procedure(value: string)  // catch
    begin
      ShowMessage('Error: ' + value);
    end
  );
end;

// Promise chaining
TPromise.Create(...)
  ._then(procedure(value: string)
    begin
      // Step 1
    end)
  ._then(procedure(value: string)
    begin
      // Step 2
    end)
  ._finally;

// Promise.All - wait for multiple operations
TPromise.all([Job1, Job2, Job3])
  ._then(procedure(value: string)
    begin
      ShowMessage('All completed!');
    end)
  ._finally;
```

### Windows Services Development

```pascal
uses KLib.MyService, KLib.ServiceApp.ThreadAdapter;

// Create a Windows service with background thread
procedure TMyCustomService.ServiceCreate(Sender: TObject);
begin
  serviceApp := TThreadAdapter.Create(
    procedure  // Main executor
    begin
      while not TMyThread(TThread.CurrentThread).isStopped do
      begin
        // Your service logic here
        Sleep(1000);
      end;
    end,
    procedure(msg: string)  // Reject callback
    begin
      LogError(msg);
    end
  );
end;
```

### Professional UI Components

```pascal
uses KLib.MessageForm, KLib.WaitForm;

// Show message dialog
var
  params: TMessageFormCreate;
  result: TMessageFormResult;
begin
  params.title := 'Confirm Action';
  params.text := 'Are you sure?';
  params.confirmButtonCaption := 'Yes';
  params.cancelButtonCaption := 'No';
  params.colorRGB := '52, 152, 219';  // Blue theme

  result := TMessageForm.showMessage(params);
  if result.isConfirmButtonPressed then
    ShowMessage('Confirmed!');
end;

// Execute with loading dialog
TWaitForm.showExecuteMethodAndWait(
  procedure
  begin
    // Long-running operation
    ProcessLargeFile();
  end,
  'Processing, please wait...'
);
```

---

## 📦 Installation

### Option 1: Manual Installation

1. Clone or download this repository
2. Add `src/boundaries/Delphi_Utils_Library` to your Delphi library path
3. Add required units to your `uses` clause

### Option 2: Git Submodule Integration

```bash
git submodule add https://github.com/karoloortiz/Delphi_Utils_Library.git libs/klib
```

Add `libs/klib` to your Delphi library path.

---

## ⚙️ Optional Dependencies

### UI Components Requirements

Define these conditionals in your project options for enhanced UI components:

**Project Options → Delphi Compiler → Conditional defines:**
```
KLIB_RAIZE
```

**Supported third-party libraries:**
- **DevExpress VCL** (v15.2.4+) - Advanced UI controls - [DevExpress](https://www.devexpress.com/)
- **Raize Components** - Professional VCL components - [Raize Software](https://www.raize.com/)

> **Note:** FormUtils components require these symbols AND corresponding libraries. Core KLib functionality works without third-party dependencies.

### Network Security Requirements

- **OpenSSL Libraries** - HTTPS/SSL support - [Indy OpenSSL Binaries](https://github.com/IndySockets/OpenSSL-Binaries)
Clone repo with assets (git lfs), and add KLib.Assets.rc to your project.

---

## 📚 Core Modules

### Async & Threading
| Unit | Description |
|------|-------------|
| `KLib.Promise` | ES6-style Promise implementation |
| `KLib.Promise.All` | Wait for multiple promises |
| `KLib.Asyncify` | Convert any method to async |
| `KLib.AsyncMethod` | Object-oriented async wrapper |
| `KLib.AsyncMethods` | Parallel execution manager |
| `KLib.MyThread` | Enhanced thread with stop support |
| `KLib.ListOfThreads` | Thread pool management |
| `KLib.MyEvent` | Custom event synchronization |

### Windows Services
| Unit | Description |
|------|-------------|
| `KLib.MyService` | Base Windows service class |
| `KLib.WindowsService` | Service installation/management |
| `KLib.ServiceApp.ThreadAdapter` | Thread-based service adapter |
| `KLib.ServiceApp.HttpServerAdapter` | HTTP server adapter |
| `KLib.Windows.EventLog` | Windows Event Log integration |

### UI Forms (VCL)
| Unit | Description |
|------|-------------|
| `KLib.MessageForm` | Customizable message dialog |
| `KLib.WaitForm` | Loading/progress form |
| `KLib.RTFForm` | RTF viewer with confirmation |
| `KLib.PresentationForm` | Multi-slide presentation/wizard |

### Networking (Indy)
| Unit | Description |
|------|-------------|
| `KLib.MyIdHTTP` | Enhanced HTTP client |
| `KLib.MyIdHTTPServer` | HTTP server wrapper |
| `KLib.MyIdFTP` | FTP client wrapper |
| `KLib.Indy` | Indy utilities |

### Data & Serialization
| Unit | Description |
|------|-------------|
| `KLib.Generics.Json` | Generic Json serialization |
| `KLib.Generics.Ini` | Generic INI mapping |
| `KLib.Generics.ShellParams` | Command-line parsing |
| `KLib.XML` | XML utilities |
| `KLib.IniFiles` | INI file helpers |

### Utilities
| Unit | Description |
|------|-------------|
| `KLib.Utils` | General utilities |
| `KLib.Common` | Common functions |
| `KLib.FileSystem` | FileSystem functions |
| `KLib.DateTimeUtils` | Date / time utils functions |
| `KLib.StringUtils` | String utils functions |
| `KLib.Csv` | Csv utils functions |
| `KLib.Common` | Common functions |
| `KLib.Types` | Common types and interfaces |
| `KLib.Constants` | Application constants |
| `KLib.Validate` | Validation utilities |
| `KLib.mystring` | String manipulation |
| `KLib.sqlstring` | SQL string helpers |
| `KLib.Math` | Math utilities |
| `KLib.Graphics` | Color and image helpers |
| `KLib.MyEncoding` | Encoding utilities |
| `KLib.ArrayHelper` | Array extensions |
| `KLib.StringListHelper` | TStringList extensions |
| `KLib.CheckBoxHelper` | TCheckBox extensions |

### Windows Integration
| Unit | Description |
|------|-------------|
| `KLib.Windows` | Windows API utilities |
| `KLib.MemoryRam` | Memory/Ram info |
| `KLib.VC_Redist` | Visual C++ Redistributable |
| `KLib.ZplPrinter` | ZPL printer support |

### Dependency Injection
| Unit | Description |
|------|-------------|
| `KLib.DiContainer` | DI container (Singleton/Transient) |

---

## 📖 Examples & Documentation

Explore the `examples/` directory for comprehensive implementations:

- **Async Examples** - Promises, Promise.All, async methods
- **Service Examples** - Windows service templates
- **Form Examples** - UI component demos
- **Database Examples** - Coming soon

---

## 🛠️ Compatibility Matrix

- **Delphi Versions:** Delphi 7 and later (tested up to Delphi 11.x)
- **Platforms:** Windows (Win32, Win64)
- **Framework:** VCL (FireMonkey/FMX not supported)

---

## 🤝 Contributing

We welcome community contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the **Clear BSD License** - see the [LICENSE](LICENSE) file for details.

```
Copyright (c) 2020 by Karol De Nery Ortiz LLave. All rights reserved.
zitrokarol@gmail.com
```

---

## 💡 Support

If KLib enhances your Delphi projects:

- ⭐ **Star this repository** on GitHub
- 🐛 **Report issues** via [GitHub Issues](https://github.com/karoloortiz/Delphi_Utils_Library/issues)
- 💬 **Contact:** zitrokarol@gmail.com

---

## 🗺️ Development Roadmap

- [ ] Complete database unification (MySQL, SQLite, PostgreSQL)
  https://github.com/karoloortiz/Delphi_MySQL_Library
  https://github.com/karoloortiz/Delphi_SQLServer_Library
  https://github.com/karoloortiz/Delphi_SQLite_Library
  https://github.com/karoloortiz/Delphi_PostgreSQL_Library

- [ ] Docusaurus documentation site
- [ ] More examples and demos
- [ ] REST client utilities
- [ ] JSON schema validation

---

**Professional Delphi utilities for modern development**

**Made with ❤️ for the Delphi community**