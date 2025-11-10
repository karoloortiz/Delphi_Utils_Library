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

unit KLib.MyIdHTTPServer;

interface

uses
  KLib.MyEvent, KLib.Types, KLib.Constants,
  IdHTTPServer, IdContext, IdCustomHTTPServer,
  System.Generics.Collections, System.SysUtils, System.Classes,
  System.RegularExpressions, System.SyncObjs, System.JSON;

type
  TIdContext = IdContext.TIdContext;
  TIdHTTPRequestInfo = IdCustomHTTPServer.TIdHTTPRequestInfo;
  TIdHTTPResponseInfo = IdCustomHTTPServer.TIdHTTPResponseInfo;

  TMyRoute = class;
  TMyRouter = class;

  TMyRouteParams = TDictionary<string, string>;
  TMyQueryParams = TDictionary<string, string>;
  TMyHeaders = TDictionary<string, string>;
  TMyHTTPMethod = (hmGET, hmPOST, hmPUT, hmDELETE, hmPATCH, hmOPTIONS, hmHEAD, hmALL);

  TMyRouteHandler = reference to procedure(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo; routeParams: TMyRouteParams);
  TMyMiddleware = reference to procedure(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo; next: TProc);
  TMyErrorHandler = reference to procedure(error: Exception; requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo);

  TIdHTTPRequestInfoHelper = class helper for TIdHTTPRequestInfo
    function getBody: string;
    function getCleanPath: string;
    function getQueryParams: TMyQueryParams;
    function getHeaders: TMyHeaders;
    function getParam(paramName: string): string;
    function getQuery(queryName: string): string;
    function getHeader(headerName: string): string;
    function isJSON: Boolean;
    function isXML: Boolean;
    function parseJSON: TJSONObject;
  end;

  TIdHTTPResponseInfoHelper = class helper for TIdHTTPResponseInfo
    procedure status(code: Integer);
    procedure send(text: string);
    procedure json(jsonObject: TJSONObject); overload;
    procedure json(jsonString: string); overload;
    procedure jsonSuccess(data: TJSONObject = nil; message: string = '');
    procedure jsonError(message: string; code: Integer = 400);
    procedure setHeader(name, value: string);
    procedure setCorsHeaders;
    procedure redirect(url: string; code: Integer = 302);
    procedure sendFile(filePath: string);
  end;

  TMyRoute = class
  private
    path: string;
    method: TMyHTTPMethod;
    handlers: TList<TMyRouteHandler>;
    regex: TRegEx;
    paramNames: TList<string>;
    isParameterized: Boolean;
    procedure buildRegexPattern;
    function createParameterizedPattern: string;
    procedure extractParameterNames;
  public
    constructor create(routePath: string; routeMethod: TMyHTTPMethod);
    destructor Destroy; override;
    procedure addHandler(handler: TMyRouteHandler);
    function match(requestMethod: TMyHTTPMethod; requestPath: string; out routeParams: TMyRouteParams): Boolean;
    procedure executeHandlers(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo; routeParams: TMyRouteParams);
    property routePath: string read path;
    property httpMethod: TMyHTTPMethod read method;
  end;

  TMyRouter = class
  private
    routes: TObjectList<TMyRoute>;
    middlewares: TList<TMyMiddleware>;
    lock: TCriticalSection;
    basePath: string;
    function httpMethodFromString(methodStr: string): TMyHTTPMethod;
    function processMiddlewareChain(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean;
    function executeMatchingRoute(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean;
  public
    constructor create(routerBasePath: string = '');
    destructor Destroy; override;
    procedure use(middleware: TMyMiddleware); overload;
    procedure use(path: string; middleware: TMyMiddleware); overload;
    procedure use(router: TMyRouter); overload;
    procedure use(path: string; router: TMyRouter); overload;
    procedure addRoute(method: TMyHTTPMethod; path: string; handler: TMyRouteHandler);
    procedure addRoutes(method: TMyHTTPMethod; path: string; handlers: array of TMyRouteHandler);
    procedure get(path: string; handler: TMyRouteHandler);
    procedure post(path: string; handler: TMyRouteHandler);
    procedure put(path: string; handler: TMyRouteHandler);
    procedure delete(path: string; handler: TMyRouteHandler);
    procedure patch(path: string; handler: TMyRouteHandler);
    procedure options(path: string; handler: TMyRouteHandler);
    procedure head(path: string; handler: TMyRouteHandler);
    procedure all(path: string; handler: TMyRouteHandler);
    function handleRequest(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean;
    property baseRoutePath: string read basePath;
  end;

  TMyIdHTTPServer = class(TIdHTTPServer)
  private
    mainRouter: TMyRouter;
    errorHandler: TMyErrorHandler;
    isRunningEvent: TMyEvent;
    serverStatus: TStatus;
    statusLock: TCriticalSection;
    corsEnabled: Boolean;
    staticPaths: TDictionary<string, string>;

    function getIsRunning: Boolean;
    procedure setStatus(value: TStatus);
    procedure initializeDefaults;
    procedure handleIncomingRequest(context: TIdContext; requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo);
    procedure startServer(asyncMode: Boolean; port: Integer = 0);
    procedure handleCorsPrelight(responseInfo: TIdHTTPResponseInfo);
    function tryServeStaticFile(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean;
    procedure applyDefaultErrorHandling(error: Exception; requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo);
    function getMimeType(fileName: string): string;
    function isPathSecure(relativePath: string): Boolean;
  public
    rejectCallback: TCallback;
    onChangeStatus: TOnChangeStatus;
    defaultServerErrorJSONResponse: string;
    property status: TStatus read serverStatus write setStatus;
    property enableCors: Boolean read corsEnabled write corsEnabled;
    property running: Boolean read getIsRunning;

    constructor create; overload;
    constructor create(port: Integer; rejectCallback: TCallback = nil;
      defaultServerErrorJSONResponse: string = EMPTY_STRING;
      onChangeStatus: TOnChangeStatus = nil); overload;

    function getRouter: TMyRouter;
    procedure use(middleware: TMyMiddleware); overload;
    procedure use(path: string; middleware: TMyMiddleware); overload;
    procedure use(router: TMyRouter); overload;
    procedure use(path: string; router: TMyRouter); overload;
    procedure addRoute(method: TMyHTTPMethod; path: string; handler: TMyRouteHandler);
    procedure addRoutes(method: TMyHTTPMethod; path: string; handlers: array of TMyRouteHandler);
    procedure get(path: string; handler: TMyRouteHandler);
    procedure post(path: string; handler: TMyRouteHandler);
    procedure put(path: string; handler: TMyRouteHandler);
    procedure delete(path: string; handler: TMyRouteHandler);
    procedure patch(path: string; handler: TMyRouteHandler);
    procedure options(path: string; handler: TMyRouteHandler);
    procedure head(path: string; handler: TMyRouteHandler);
    procedure all(path: string; handler: TMyRouteHandler);
    procedure setErrorHandler(handler: TMyErrorHandler);
    procedure serveStatic(path: string; directory: string);

    procedure listen(port: Integer = 0);
    procedure listenAsync(port: Integer = 0);
    procedure stop(isRaiseExceptionEnabled: Boolean = True);
    procedure waitUntilRunning;

    destructor Destroy; override;
  end;

  // Express-like static file middleware
function staticFiles(directory: string; mountPath: string = ''): TMyMiddleware;

// Helper function
function getContentType(fileName: string): string;

implementation

uses
  KLib.Validate, KLib.Utils, IdTCPServer, IdSocketHandle, System.IOUtils, IdGlobal, System.StrUtils;

function getContentType(fileName: string): string;
var
  ext: string;
begin
  ext := LowerCase(TPath.GetExtension(fileName));

  if (ext = '.html') or (ext = '.htm') then
    Result := 'text/html'
  else if ext = '.css' then
    Result := 'text/css'
  else if ext = '.js' then
    Result := 'application/javascript'
  else if ext = '.json' then
    Result := 'application/json'
  else if ext = '.png' then
    Result := 'image/png'
  else if (ext = '.jpg') or (ext = '.jpeg') then
    Result := 'image/jpeg'
  else if ext = '.gif' then
    Result := 'image/gif'
  else if ext = '.svg' then
    Result := 'image/svg+xml'
  else if ext = '.ico' then
    Result := 'image/x-icon'
  else if (ext = '.yaml') or (ext = '.yml') then
    Result := 'application/x-yaml'
  else if ext = '.txt' then
    Result := 'text/plain'
  else if ext = '.pdf' then
    Result := 'application/pdf'
  else
    Result := 'application/octet-stream';
end;

function staticFiles(directory: string; mountPath: string = ''): TMyMiddleware;
begin
  Result := procedure(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo; next: TProc)
    var
      cleanPath: string;
      relativePath: string;
      filePath: string;
      fileStream: TFileStream;
      isSecure: Boolean;
    begin
      cleanPath := requestInfo.getCleanPath;

      // Strip mount path prefix
      if (mountPath <> '') then
      begin
        if cleanPath = mountPath then
          cleanPath := '/'
        else if cleanPath.StartsWith(mountPath + '/') then
          cleanPath := Copy(cleanPath, Length(mountPath) + 1, Length(cleanPath));
      end;

      // Convert URL path to file system path
      relativePath := cleanPath;
      if relativePath.StartsWith('/') then
        relativePath := Copy(relativePath, 2, Length(relativePath));
      relativePath := StringReplace(relativePath, '/', '\', [rfReplaceAll]);

      // Default to index.html if path is empty or ends with /
      if (relativePath = '') or relativePath.EndsWith('\') then
        relativePath := relativePath + 'index.html';

      // Security check
      isSecure := not(relativePath.Contains('..') or
        relativePath.Contains('~') or
        relativePath.StartsWith('/') or
        relativePath.Contains('\..'));

      if not isSecure then
      begin
        next();
        Exit;
      end;

      filePath := TPath.Combine(directory, relativePath);

      if TFile.Exists(filePath) then
      begin
        try
          fileStream := TFileStream.Create(filePath, fmOpenRead or fmShareDenyWrite);
          try
            if Assigned(responseInfo.ContentStream) then
              FreeAndNil(responseInfo.ContentStream);

            responseInfo.ContentStream := TMemoryStream.Create;
            responseInfo.ContentStream.CopyFrom(fileStream, fileStream.Size);
            responseInfo.ContentStream.Position := 0;

            responseInfo.ContentType := getContentType(filePath);
            responseInfo.status(200);
            Exit; // File served successfully
          finally
            FreeAndNil(fileStream);
          end;
        except
          // If error serving file, continue to next middleware
        end;
      end;

      // File not found or error, call next middleware
      next();
    end;
end;

{ TIdHTTPRequestInfoHelper }

function TIdHTTPRequestInfoHelper.getBody: string;
begin
  Result := '';

  if Assigned(PostStream) then
  begin
    Result := getStringFromStream(PostStream);
  end
  else if FormParams <> '' then
  begin
    Result := FormParams;
  end;
end;

function TIdHTTPRequestInfoHelper.getCleanPath: string;
var
  queryPos: Integer;
begin
  Result := Document;
  if Result = '' then
    Result := '/';

  queryPos := Pos('?', Result);
  if queryPos > 0 then
    Result := Copy(Result, 1, queryPos - 1);

  if not Result.StartsWith('/') then
    Result := '/' + Result;
end;

function TIdHTTPRequestInfoHelper.getQueryParams: TMyQueryParams;
var
  queryString: string;
  queryPos: Integer;
  pairs: TArray<string>;
  pair: string;
  equalPos: Integer;
  key, value: string;
begin
  Result := TMyQueryParams.Create;

  queryString := Document;
  queryPos := Pos('?', queryString);
  if queryPos > 0 then
  begin
    queryString := Copy(queryString, queryPos + 1, Length(queryString));
    pairs := queryString.Split(['&']);

    for pair in pairs do
    begin
      if pair.Trim <> '' then
      begin
        equalPos := Pos('=', pair);
        if equalPos > 0 then
        begin
          key := Copy(pair, 1, equalPos - 1).Trim;
          value := Copy(pair, equalPos + 1, Length(pair)).Trim;
          if key <> '' then
            Result.AddOrSetValue(key, value);
        end
        else
        begin
          key := pair.Trim;
          if key <> '' then
            Result.AddOrSetValue(key, '');
        end;
      end;
    end;
  end;
end;

function TIdHTTPRequestInfoHelper.getHeaders: TMyHeaders;
var
  i: Integer;
begin
  Result := TMyHeaders.Create;

  for i := 0 to RawHeaders.Count - 1 do
  begin
    if RawHeaders.Names[i] <> '' then
      Result.AddOrSetValue(RawHeaders.Names[i].ToLower, RawHeaders.ValueFromIndex[i]);
  end;
end;

function TIdHTTPRequestInfoHelper.getParam(paramName: string): string;
var
  params: TMyQueryParams;
begin
  Result := '';
  params := getQueryParams;
  try
    if params.ContainsKey(paramName) then
      Result := params[paramName];
  finally
    FreeAndNil(params);
  end;
end;

function TIdHTTPRequestInfoHelper.getQuery(queryName: string): string;
begin
  Result := getParam(queryName);
end;

function TIdHTTPRequestInfoHelper.getHeader(headerName: string): string;
begin
  Result := RawHeaders.Values[headerName];
end;

function TIdHTTPRequestInfoHelper.isJSON: Boolean;
begin
  Result := ContentType.ToLower.Contains('application/json');
end;

function TIdHTTPRequestInfoHelper.isXML: Boolean;
begin
  Result := ContentType.ToLower.Contains('application/xml') or ContentType.ToLower.Contains('text/xml');
end;

function TIdHTTPRequestInfoHelper.parseJSON: TJSONObject;
var
  body: string;
begin
  Result := nil;
  if isJSON then
  begin
    body := getBody;
    if body.Trim <> '' then
    begin
      try
        Result := TJSONObject.ParseJSONValue(body) as TJSONObject;
      except
        Result := nil;
      end;
    end;
  end;
end;

{ TIdHTTPResponseInfoHelper }

procedure TIdHTTPResponseInfoHelper.status(code: Integer);
begin
  ResponseNo := code;
  case code of
    200:
      ResponseText := 'OK';
    201:
      ResponseText := 'Created';
    400:
      ResponseText := 'Bad Request';
    401:
      ResponseText := 'Unauthorized';
    403:
      ResponseText := 'Forbidden';
    404:
      ResponseText := 'Not Found';
    405:
      ResponseText := 'Method Not Allowed';
    500:
      ResponseText := 'Internal Server Error';
  else
    ResponseText := 'Unknown';
  end;
end;

procedure TIdHTTPResponseInfoHelper.send(text: string);
begin
  ContentText := text;
  if ContentType = '' then
    ContentType := 'text/plain; charset=utf-8';
end;

procedure TIdHTTPResponseInfoHelper.json(jsonObject: TJSONObject);
begin
  if Assigned(jsonObject) then
    ContentText := jsonObject.ToString
  else
    ContentText := '{}';
  ContentType := 'application/json; charset=utf-8';
end;

procedure TIdHTTPResponseInfoHelper.json(jsonString: string);
begin
  ContentText := jsonString;
  ContentType := 'application/json; charset=utf-8';
end;

procedure TIdHTTPResponseInfoHelper.jsonSuccess(data: TJSONObject; message: string);
var
  response: TJSONObject;
begin
  response := TJSONObject.Create;
  try
    response.AddPair('success', TJSONTrue.Create);
    if message <> '' then
      response.AddPair('message', message);
    if Assigned(data) then
      response.AddPair('data', data.Clone as TJSONObject);
    json(response);
  finally
    FreeAndNil(response);
  end;
end;

procedure TIdHTTPResponseInfoHelper.jsonError(message: string; code: Integer);
var
  response: TJSONObject;
begin
  response := TJSONObject.Create;
  try
    response.AddPair('success', TJSONFalse.Create);
    response.AddPair('error', message);
    response.AddPair('code', TJSONNumber.Create(code));
    status(code);
    json(response);
  finally
    FreeAndNil(response);
  end;
end;

procedure TIdHTTPResponseInfoHelper.setHeader(name, value: string);
begin
  CustomHeaders.Values[name] := value;
end;

procedure TIdHTTPResponseInfoHelper.setCorsHeaders;
begin
  setHeader('Access-Control-Allow-Origin', '*');
  setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
  setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
end;

procedure TIdHTTPResponseInfoHelper.redirect(url: string; code: Integer);
begin
  status(code);
  setHeader('Location', url);
end;

procedure TIdHTTPResponseInfoHelper.sendFile(filePath: string);
var
  fileStream: TFileStream;
begin
  if TFile.Exists(filePath) then
  begin
    fileStream := TFileStream.Create(filePath, fmOpenRead or fmShareDenyWrite);
    try
      if Assigned(ContentStream) then
        FreeAndNil(ContentStream);
      ContentStream := TMemoryStream.Create;
      ContentStream.CopyFrom(fileStream, fileStream.Size);
      ContentStream.Position := 0;
      status(200);
    finally
      FreeAndNil(fileStream);
    end;
  end
  else
  begin
    jsonError('File not found', 404);
  end;
end;

{ TMyRoute }

constructor TMyRoute.create(routePath: string; routeMethod: TMyHTTPMethod);
begin
  if routePath = '' then
    path := '/'
  else
    path := routePath;

  if not path.StartsWith('/') then
    path := '/' + path;

  method := routeMethod;
  handlers := TList<TMyRouteHandler>.Create;
  paramNames := TList<string>.Create;
  buildRegexPattern;
end;

destructor TMyRoute.Destroy;
begin
  FreeAndNil(handlers);
  FreeAndNil(paramNames);
  inherited;
end;

procedure TMyRoute.extractParameterNames;
var
  currentPos: Integer;
  paramStart: Integer;
  paramEnd: Integer;
  paramName: string;
  hasWildcard: Boolean;
begin
  paramNames.Clear;
  currentPos := 1;

  while currentPos <= Length(path) do
  begin
    paramStart := PosEx(':', path, currentPos);
    if paramStart = 0 then
      Break;

    paramEnd := paramStart + 1;
    while (paramEnd <= Length(path)) and
      CharInSet(path[paramEnd], ['A' .. 'Z', 'a' .. 'z', '0' .. '9', '_']) do
      Inc(paramEnd);

    paramName := Copy(path, paramStart + 1, paramEnd - paramStart - 1);
    if paramName <> '' then
      paramNames.Add(paramName);

    currentPos := paramEnd;
  end;

  // Controlla se il path contiene wildcard
  hasWildcard := Pos('*', path) > 0;

  isParameterized := (paramNames.Count > 0) or hasWildcard;
end;

function TMyRoute.createParameterizedPattern: string;
var
  pattern: string;
begin
  pattern := path;

  if pattern = '' then
    pattern := '/';
  if not pattern.StartsWith('/') then
    pattern := '/' + pattern;

  // Sostituisci wildcard * con placeholder prima degli escape
  pattern := StringReplace(pattern, '*', '__WILDCARD__', [rfReplaceAll]);

  // Escape dei caratteri speciali PRIMA di processare i parametri
  pattern := StringReplace(pattern, '\', '\\', [rfReplaceAll]);
  pattern := StringReplace(pattern, '.', '\.', [rfReplaceAll]);
  pattern := StringReplace(pattern, '+', '\+', [rfReplaceAll]);
  pattern := StringReplace(pattern, '?', '\?', [rfReplaceAll]);
  pattern := StringReplace(pattern, '[', '\[', [rfReplaceAll]);
  pattern := StringReplace(pattern, ']', '\]', [rfReplaceAll]);
  pattern := StringReplace(pattern, '(', '\(', [rfReplaceAll]);
  pattern := StringReplace(pattern, ')', '\)', [rfReplaceAll]);
  pattern := StringReplace(pattern, '{', '\{', [rfReplaceAll]);
  pattern := StringReplace(pattern, '}', '\}', [rfReplaceAll]);
  pattern := StringReplace(pattern, '^', '\^', [rfReplaceAll]);

  // Sostituisci i parametri :paramName con pattern regex
  pattern := TRegEx.Replace(pattern, ':([a-zA-Z_][a-zA-Z0-9_]*)', '([^/]+)', [roIgnoreCase]);

  // Sostituisci placeholder wildcard con regex pattern
  pattern := StringReplace(pattern, '__WILDCARD__', '.*', [rfReplaceAll]);

  // Aggiungi ancora e fine per match esatto
  Result := '^' + pattern + '$';
end;

procedure TMyRoute.buildRegexPattern;
begin
  extractParameterNames;

  if isParameterized then
  begin
    // Solo se ci sono parametri, crea il regex
    regex := TRegEx.Create(createParameterizedPattern, [roIgnoreCase]);
  end;
  // Se non � parametrizzato, non serve il regex - usa confronto diretto
end;

procedure TMyRoute.addHandler(handler: TMyRouteHandler);
begin
  handlers.Add(handler);
end;

function TMyRoute.match(requestMethod: TMyHTTPMethod; requestPath: string; out routeParams: TMyRouteParams): Boolean;
var
  regexMatch: TMatch;
  i: Integer;
  normalizedPath: string;
  normalizedRequestPath: string;
begin
  Result := (method = hmALL) or (method = requestMethod);
  if not Result then
    Exit;

  routeParams := TMyRouteParams.Create;

  // Normalizza i path per il confronto
  normalizedPath := path;
  normalizedRequestPath := requestPath;

  if normalizedPath = '' then
    normalizedPath := '/';
  if normalizedRequestPath = '' then
    normalizedRequestPath := '/';

  if not normalizedPath.StartsWith('/') then
    normalizedPath := '/' + normalizedPath;
  if not normalizedRequestPath.StartsWith('/') then
    normalizedRequestPath := '/' + normalizedRequestPath;

  if isParameterized then
  begin
    regexMatch := regex.Match(normalizedRequestPath);
    Result := regexMatch.Success;

    if Result then
    begin
      try
        for i := 0 to paramNames.Count - 1 do
        begin
          if i + 1 < regexMatch.Groups.Count then
            routeParams.Add(paramNames[i], regexMatch.Groups[i + 1].Value);
        end;
      except
        FreeAndNil(routeParams);
        Result := False;
      end;
    end
    else
    begin
      FreeAndNil(routeParams);
    end;
  end
  else
  begin
    Result := SameText(normalizedPath, normalizedRequestPath);
    if not Result then
      FreeAndNil(routeParams);
  end;
end;

procedure TMyRoute.executeHandlers(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo; routeParams: TMyRouteParams);
var
  handler: TMyRouteHandler;
begin
  for handler in handlers do
    handler(requestInfo, responseInfo, routeParams);
end;

{ TMyRouter }

constructor TMyRouter.create(routerBasePath: string);
begin
  basePath := routerBasePath;
  routes := TObjectList<TMyRoute>.Create(True);
  middlewares := TList<TMyMiddleware>.Create;
  lock := TCriticalSection.Create;
end;

destructor TMyRouter.Destroy;
begin
  FreeAndNil(routes);
  FreeAndNil(middlewares);
  FreeAndNil(lock);
  inherited;
end;

function TMyRouter.httpMethodFromString(methodStr: string): TMyHTTPMethod;
begin
  methodStr := UpperCase(methodStr);
  if methodStr = 'GET' then
    Result := hmGET
  else if methodStr = 'POST' then
    Result := hmPOST
  else if methodStr = 'PUT' then
    Result := hmPUT
  else if methodStr = 'DELETE' then
    Result := hmDELETE
  else if methodStr = 'PATCH' then
    Result := hmPATCH
  else if methodStr = 'OPTIONS' then
    Result := hmOPTIONS
  else if methodStr = 'HEAD' then
    Result := hmHEAD
  else
    Result := hmGET;
end;

function TMyRouter.processMiddlewareChain(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean;
var
  middlewaresCopy: TArray<TMyMiddleware>;
  i: Integer;
  currentIndex: Integer;
  nextCalled: Boolean;
  next: TProc;
begin
  Result := True;

  lock.Enter;
  try
    SetLength(middlewaresCopy, middlewares.Count);
    for i := 0 to middlewares.Count - 1 do
      middlewaresCopy[i] := middlewares[i];
  finally
    lock.Leave;
  end;

  currentIndex := 0;
  next := procedure
    begin
      nextCalled := True;
      Inc(currentIndex);
    end;

  while currentIndex < Length(middlewaresCopy) do
  begin
    nextCalled := False;
    middlewaresCopy[currentIndex](requestInfo, responseInfo, next);

    if not nextCalled then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function TMyRouter.executeMatchingRoute(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean;
var
  requestMethod: TMyHTTPMethod;
  cleanPath: string;
  route: TMyRoute;
  routeParams: TMyRouteParams;
begin
  Result := False;
  requestMethod := httpMethodFromString(requestInfo.Command);
  cleanPath := requestInfo.getCleanPath;

  lock.Enter;
  try
    for route in routes do
    begin
      routeParams := nil;
      try
        if route.match(requestMethod, cleanPath, routeParams) then
        begin
          route.executeHandlers(requestInfo, responseInfo, routeParams);
          Result := True;
          Break;
        end;
      finally
        FreeAndNil(routeParams);
      end;
    end;
  finally
    lock.Leave;
  end;
end;

procedure TMyRouter.use(middleware: TMyMiddleware);
begin
  lock.Enter;
  try
    middlewares.Add(middleware);
  finally
    lock.Leave;
  end;
end;

procedure TMyRouter.use(path: string; middleware: TMyMiddleware);
var
  basePath: string;
  wrappedMiddleware: TMyRouteHandler;
begin
  basePath := path.TrimRight(['/']);

  wrappedMiddleware := procedure(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo; routeParams: TMyRouteParams)
    var
      cleanPath: string;
    begin
      cleanPath := requestInfo.getCleanPath;

      // Redirect exact basePath to trailing slash (Express behavior for static directories)
      if cleanPath = basePath then
      begin
        responseInfo.Location := basePath + '/';
        responseInfo.ResponseNo := 301;
        Exit;
      end;

      // Call middleware
      middleware(requestInfo, responseInfo,
        procedure
        begin
        end);
    end;

  // Match exact basePath (will redirect)
  all(basePath, wrappedMiddleware);

  // Match basePath with trailing slash and all subpaths
  all(basePath + '/*', wrappedMiddleware);
end;

procedure TMyRouter.use(router: TMyRouter);
var
  route: TMyRoute;
  middleware: TMyMiddleware;
  newRoute: TMyRoute;
  i: Integer;
  finalPath: string;
begin
  if not Assigned(router) then
    Exit;

  lock.Enter;
  try
    for route in router.routes do
    begin
      if router.basePath <> '' then
      begin
        finalPath := router.basePath;
        if route.routePath <> '/' then
          finalPath := finalPath + route.routePath;
      end
      else
      begin
        finalPath := route.routePath;
      end;

      finalPath := StringReplace(finalPath, '//', '/', [rfReplaceAll]);
      if (finalPath <> '/') and finalPath.EndsWith('/') then
        finalPath := Copy(finalPath, 1, Length(finalPath) - 1);

      newRoute := TMyRoute.Create(finalPath, route.httpMethod);
      for i := 0 to route.handlers.Count - 1 do
        newRoute.addHandler(route.handlers[i]);
      routes.Add(newRoute);
    end;

    for middleware in router.middlewares do
      middlewares.Add(middleware);
  finally
    lock.Leave;
  end;
end;

procedure TMyRouter.use(path: string; router: TMyRouter);
var
  route: TMyRoute;
  middleware: TMyMiddleware;
  newRoute: TMyRoute;
  fullPath: string;
  i: Integer;
begin
  if not Assigned(router) then
    Exit;

  lock.Enter;
  try
    for route in router.routes do
    begin
      fullPath := path.TrimRight(['/']) + '/' + route.routePath.TrimLeft(['/']);
      fullPath := StringReplace(fullPath, '//', '/', [rfReplaceAll]);

      newRoute := TMyRoute.Create(fullPath, route.httpMethod);
      for i := 0 to route.handlers.Count - 1 do
        newRoute.addHandler(route.handlers[i]);
      routes.Add(newRoute);
    end;

    for middleware in router.middlewares do
      middlewares.Add(middleware);
  finally
    lock.Leave;
  end;
end;

procedure TMyRouter.addRoute(method: TMyHTTPMethod; path: string; handler: TMyRouteHandler);
var
  route: TMyRoute;
begin
  lock.Enter;
  try
    route := TMyRoute.Create(path, method);
    route.addHandler(handler);
    routes.Add(route);
  finally
    lock.Leave;
  end;
end;

procedure TMyRouter.addRoutes(method: TMyHTTPMethod; path: string; handlers: array of TMyRouteHandler);
var
  route: TMyRoute;
  handler: TMyRouteHandler;
begin
  lock.Enter;
  try
    route := TMyRoute.Create(path, method);
    for handler in handlers do
      route.addHandler(handler);
    routes.Add(route);
  finally
    lock.Leave;
  end;
end;

procedure TMyRouter.get(path: string; handler: TMyRouteHandler);
begin
  addRoute(hmGET, path, handler);
end;

procedure TMyRouter.post(path: string; handler: TMyRouteHandler);
begin
  addRoute(hmPOST, path, handler);
end;

procedure TMyRouter.put(path: string; handler: TMyRouteHandler);
begin
  addRoute(hmPUT, path, handler);
end;

procedure TMyRouter.delete(path: string; handler: TMyRouteHandler);
begin
  addRoute(hmDELETE, path, handler);
end;

procedure TMyRouter.patch(path: string; handler: TMyRouteHandler);
begin
  addRoute(hmPATCH, path, handler);
end;

procedure TMyRouter.options(path: string; handler: TMyRouteHandler);
begin
  addRoute(hmOPTIONS, path, handler);
end;

procedure TMyRouter.head(path: string; handler: TMyRouteHandler);
begin
  addRoute(hmHEAD, path, handler);
end;

procedure TMyRouter.all(path: string; handler: TMyRouteHandler);
begin
  addRoute(hmALL, path, handler);
end;

function TMyRouter.handleRequest(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean;
begin
  Result := processMiddlewareChain(requestInfo, responseInfo);
  if Result then
    Result := executeMatchingRoute(requestInfo, responseInfo);
end;

{ TMyIdHTTPServer }

constructor TMyIdHTTPServer.create;
begin
  inherited create(nil);
  mainRouter := TMyRouter.Create;
  isRunningEvent := TMyEvent.Create;
  statusLock := TCriticalSection.Create;
  staticPaths := TDictionary<string, string>.Create;
  corsEnabled := True;
  initializeDefaults;
  setStatus(TStatus.created);
end;

constructor TMyIdHTTPServer.create(port: Integer; rejectCallback: TCallback;
defaultServerErrorJSONResponse: string; onChangeStatus: TOnChangeStatus);
begin
  create;
  Self.DefaultPort := port;
  Self.rejectCallback := rejectCallback;
  Self.defaultServerErrorJSONResponse := defaultServerErrorJSONResponse;
  Self.onChangeStatus := onChangeStatus;
end;

procedure TMyIdHTTPServer.initializeDefaults;
begin
  Self.OnCommandGet := handleIncomingRequest;
  Self.OnCommandOther := handleIncomingRequest;
  Self.KeepAlive := False;
  Self.ParseParams := False;
end;

function TMyIdHTTPServer.getRouter: TMyRouter;
begin
  Result := mainRouter;
end;

function TMyIdHTTPServer.getMimeType(fileName: string): string;
begin
  Result := getContentType(fileName);
end;

function TMyIdHTTPServer.isPathSecure(relativePath: string): Boolean;
begin
  Result := not(relativePath.Contains('..') or
    relativePath.Contains('~') or
    relativePath.StartsWith('/') or
    relativePath.Contains('\..'));
end;

procedure TMyIdHTTPServer.use(middleware: TMyMiddleware);
begin
  mainRouter.use(middleware);
end;

procedure TMyIdHTTPServer.use(path: string; middleware: TMyMiddleware);
begin
  mainRouter.use(path, middleware);
end;

procedure TMyIdHTTPServer.use(router: TMyRouter);
begin
  mainRouter.use(router);
end;

procedure TMyIdHTTPServer.use(path: string; router: TMyRouter);
begin
  mainRouter.use(path, router);
end;

procedure TMyIdHTTPServer.get(path: string; handler: TMyRouteHandler);
begin
  mainRouter.get(path, handler);
end;

procedure TMyIdHTTPServer.post(path: string; handler: TMyRouteHandler);
begin
  mainRouter.post(path, handler);
end;

procedure TMyIdHTTPServer.put(path: string; handler: TMyRouteHandler);
begin
  mainRouter.put(path, handler);
end;

procedure TMyIdHTTPServer.delete(path: string; handler: TMyRouteHandler);
begin
  mainRouter.delete(path, handler);
end;

procedure TMyIdHTTPServer.patch(path: string; handler: TMyRouteHandler);
begin
  mainRouter.patch(path, handler);
end;

procedure TMyIdHTTPServer.options(path: string; handler: TMyRouteHandler);
begin
  mainRouter.options(path, handler);
end;

procedure TMyIdHTTPServer.head(path: string; handler: TMyRouteHandler);
begin
  mainRouter.head(path, handler);
end;

procedure TMyIdHTTPServer.all(path: string; handler: TMyRouteHandler);
begin
  mainRouter.all(path, handler);
end;

procedure TMyIdHTTPServer.addRoute(method: TMyHTTPMethod; path: string; handler: TMyRouteHandler);
begin
  mainRouter.addRoute(method, path, handler);
end;

procedure TMyIdHTTPServer.addRoutes(method: TMyHTTPMethod; path: string; handlers: array of TMyRouteHandler);
begin
  mainRouter.addRoutes(method, path, handlers);
end;

procedure TMyIdHTTPServer.setErrorHandler(handler: TMyErrorHandler);
begin
  errorHandler := handler;
end;

procedure TMyIdHTTPServer.serveStatic(path: string; directory: string);
begin
  staticPaths.AddOrSetValue(path, directory);
end;

procedure TMyIdHTTPServer.handleCorsPrelight(responseInfo: TIdHTTPResponseInfo);
begin
  if corsEnabled then
  begin
    responseInfo.setCorsHeaders;
    responseInfo.status(200);
  end;
end;

function TMyIdHTTPServer.tryServeStaticFile(requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo): Boolean;
var
  cleanPath: string;
  staticPath: string;
  directory: string;
  filePath: string;
  relativePath: string;
  fileStream: TFileStream;
begin
  Result := False;
  cleanPath := requestInfo.getCleanPath;

  for staticPath in staticPaths.Keys do
  begin
    if cleanPath.StartsWith(staticPath) then
    begin
      // Redirect exact staticPath to version with trailing slash (like Express for directories)
      if cleanPath = staticPath then
      begin
        responseInfo.Location := staticPath + '/';
        responseInfo.ResponseNo := 301;
        Result := True;
        Exit;
      end;

      directory := staticPaths[staticPath];
      relativePath := Copy(cleanPath, Length(staticPath) + 1, Length(cleanPath));
      relativePath := StringReplace(relativePath, '/', '\', [rfReplaceAll]);

      // Remove leading backslash if present
      if relativePath.StartsWith('\') then
        relativePath := Copy(relativePath, 2, Length(relativePath));

      // Default to index.html if path is empty or ends with /
      if (relativePath = '') or relativePath.EndsWith('\') then
        relativePath := relativePath + 'index.html';

      if not isPathSecure(relativePath) then
        Exit;

      filePath := TPath.Combine(directory, relativePath);

      if TFile.Exists(filePath) then
      begin
        try
          fileStream := TFileStream.Create(filePath, fmOpenRead or fmShareDenyWrite);
          try
            if Assigned(responseInfo.ContentStream) then
              FreeAndNil(responseInfo.ContentStream);

            responseInfo.ContentStream := TMemoryStream.Create;
            responseInfo.ContentStream.CopyFrom(fileStream, fileStream.Size);
            responseInfo.ContentStream.Position := 0;
            responseInfo.ContentType := getMimeType(filePath);
            responseInfo.status(200);
            Result := True;
          finally
            FreeAndNil(fileStream);
          end;
        except
          Result := False;
        end;
        Break;
      end;
    end;
  end;
end;

procedure TMyIdHTTPServer.applyDefaultErrorHandling(error: Exception; requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo);
begin
  if Assigned(errorHandler) then
  begin
    errorHandler(error, requestInfo, responseInfo);
  end
  else
  begin
    responseInfo.status(500);
    if defaultServerErrorJSONResponse <> EMPTY_STRING then
    begin
      responseInfo.json(defaultServerErrorJSONResponse);
    end
    else
    begin
      responseInfo.jsonError('Internal Server Error: ' + error.Message, 500);
    end;

    if Assigned(rejectCallback) then
      rejectCallback(error.Message);
  end;
end;

procedure TMyIdHTTPServer.handleIncomingRequest(context: TIdContext; requestInfo: TIdHTTPRequestInfo; responseInfo: TIdHTTPResponseInfo);
var
  requestMethod: TMyHTTPMethod;
begin
  try
    if corsEnabled then
      responseInfo.setCorsHeaders;

    requestMethod := mainRouter.httpMethodFromString(requestInfo.Command);

    if requestMethod = hmOPTIONS then
    begin
      handleCorsPrelight(responseInfo);
      Exit;
    end;

    if tryServeStaticFile(requestInfo, responseInfo) then
      Exit;

    if not mainRouter.handleRequest(requestInfo, responseInfo) then
    begin
      responseInfo.status(404);
      responseInfo.jsonError('Route not found: ' + requestInfo.getCleanPath + ' Method: ' + requestInfo.Command, 404);
    end;
  except
    on E: Exception do
      applyDefaultErrorHandling(E, requestInfo, responseInfo);
  end;
end;

procedure TMyIdHTTPServer.listen(port: Integer);
begin
  startServer(False, port);
end;

procedure TMyIdHTTPServer.listenAsync(port: Integer);
begin
  startServer(True, port);
end;

procedure TMyIdHTTPServer.startServer(asyncMode: Boolean; port: Integer);
const
  ERROR_MSG = 'Port not assigned.';
var
  binding: TIdSocketHandle;
begin
  try
    if (DefaultPort = 0) and (port = 0) then
      raise Exception.Create(ERROR_MSG);

    if port > 0 then
      DefaultPort := port;

    validateThatPortIsAvaliable(DefaultPort);

    Bindings.Clear;
    binding := Bindings.Add;
    binding.Port := DefaultPort;
    binding.IP := '0.0.0.0';

    Active := True;
    isRunningEvent.enable;
    setStatus(TStatus.running);

    if not asyncMode then
      waitUntilRunning;
  except
    on E: Exception do
    begin
      setStatus(TStatus._null);
      if Assigned(rejectCallback) then
        rejectCallback(E.Message)
      else
        raise;
    end;
  end;
end;

procedure TMyIdHTTPServer.stop(isRaiseExceptionEnabled: Boolean);
const
  ERROR_MSG = 'Server is not running.';
begin
  try
    Active := False;
  except
    if isRaiseExceptionEnabled then
    begin
      raise Exception.Create(ERROR_MSG);
    end;
  end;
  isRunningEvent.disable;
  setStatus(TStatus.stopped);
end;

procedure TMyIdHTTPServer.waitUntilRunning;
begin
  while getIsRunning do
  begin
    isRunningEvent.waitFor(100);
  end;
end;

function TMyIdHTTPServer.getIsRunning: Boolean;
begin
  Result := isRunningEvent.value and Active;
end;

procedure TMyIdHTTPServer.setStatus(value: TStatus);
begin
  statusLock.Enter;
  try
    serverStatus := value;
    if Assigned(onChangeStatus) then
      onChangeStatus(serverStatus);
  finally
    statusLock.Leave;
  end;
end;

destructor TMyIdHTTPServer.Destroy;
begin
  try
    stop(False);
  except
    // Ignore errors during destruction
  end;

  FreeAndNil(mainRouter);
  FreeAndNil(isRunningEvent);
  FreeAndNil(statusLock);
  FreeAndNil(staticPaths);
  inherited;
end;

end.
