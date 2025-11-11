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

//todo to complete

unit KLib.DiContainer;

interface

uses
  System.Generics.Collections, System.Rtti, System.TypInfo, System.SysUtils, System.SyncObjs;

type
  EDIContainer = class(Exception)
  end;

  TServiceLifetime = (Singleton, Transient);

  IServiceRegistration = interface
    ['{CE1C4F31-7A0F-4E0A-9E99-6C8A7B5F6E7D}']
    function getLifetime: TServiceLifetime;
    function createInstance: TObject;
  end;

  TServiceRegistration = class(TInterfacedObject, IServiceRegistration)
  private
    _lifetime: TServiceLifetime;
    _implementationType: TClass;
    _factoryFunc: TFunc<TObject>;
    _singletonInstance: TObject;
    _criticalSection: TCriticalSection;
  public
    constructor Create(lifetime: TServiceLifetime; implementationType: TClass; factoryFunc: TFunc<TObject>);
    destructor Destroy; override;

    function getLifetime: TServiceLifetime;
    function createInstance: TObject;
  end;

  TDIContainer = class
  private
    _criticalSection: TCriticalSection;
    _registrations: TDictionary<string, IServiceRegistration>;
    _resolutionStack: TList<string>;

    function internalResolve(const serviceName: string): TObject;
    function getServiceRegistration(const serviceName: string): IServiceRegistration;
    function findSuitableConstructor(rttiType: TRttiType): TRttiMethod;
    function isInResolutionStack(const serviceName: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure registerType(serviceType: TClass; implementationType: TClass;
      lifetime: TServiceLifetime = TServiceLifetime.Transient); overload;

    procedure registerType(implementationType: TClass;
      lifetime: TServiceLifetime = TServiceLifetime.Transient); overload;

    procedure registerFactory(serviceType: TClass;
      factoryFunc: TFunc<TObject>;
      lifetime: TServiceLifetime = TServiceLifetime.Transient);

    function resolve(serviceType: TClass): TObject; overload;
    function resolve<T: class>: T; overload;

    function tryResolve(serviceType: TClass; out instance: TObject): Boolean; overload;
    function tryResolve<T: class>(out instance: T): Boolean; overload;
  end;

implementation

{ TServiceRegistration }

constructor TServiceRegistration.Create(lifetime: TServiceLifetime;
  implementationType: TClass; factoryFunc: TFunc<TObject>);
begin
  inherited Create;
  _lifetime := lifetime;
  _implementationType := implementationType;
  _factoryFunc := factoryFunc;
  _criticalSection := TCriticalSection.Create;
end;

destructor TServiceRegistration.Destroy;
begin
  FreeAndNil(_singletonInstance);
  FreeAndNil(_criticalSection);
  inherited;
end;

function TServiceRegistration.getLifetime: TServiceLifetime;
begin
  Result := _lifetime;
end;

function TServiceRegistration.createInstance: TObject;
begin
  case _lifetime of
    Transient:
      Result := _factoryFunc();
    Singleton:
      begin
        _criticalSection.Enter;
        try
          if not Assigned(_singletonInstance) then
            _singletonInstance := _factoryFunc();
          Result := _singletonInstance;
        finally
          _criticalSection.Leave;
        end;
      end;
  else
    raise EDIContainer.Create('Invalid service lifetime');
  end;
end;

{ TDIContainer }

constructor TDIContainer.Create;
begin
  inherited;
  _criticalSection := TCriticalSection.Create;
  _registrations := TDictionary<string, IServiceRegistration>.Create;
  _resolutionStack := TList<string>.Create;
end;

destructor TDIContainer.Destroy;
begin
  FreeAndNil(_registrations);
  FreeAndNil(_resolutionStack);
  FreeAndNil(_criticalSection);
  inherited;
end;

function TDIContainer.isInResolutionStack(const serviceName: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to _resolutionStack.Count - 1 do
  begin
    if _resolutionStack[i] = serviceName then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TDIContainer.findSuitableConstructor(rttiType: TRttiType): TRttiMethod;
var
  _method: TRttiMethod;
begin
  Result := nil;

  // First try to find a constructor with parameters
  for _method in rttiType.GetMethods do
  begin
    if _method.IsConstructor and (Length(_method.GetParameters) > 0) then
      Exit(_method);
  end;

  // If not found, try to find any constructor
  for _method in rttiType.GetMethods do
  begin
    if _method.IsConstructor then
      Exit(_method);
  end;
end;

procedure TDIContainer.registerType(serviceType: TClass; implementationType: TClass;
  lifetime: TServiceLifetime);
var
  _rttiContext: TRttiContext;
  _rttiType: TRttiType;
  _ctor: TRttiMethod;
  _serviceName: string;
begin
  _serviceName := serviceType.ClassName;

  if _registrations.ContainsKey(_serviceName) then
    raise EDIContainer.CreateFmt('Service already registered: %s', [_serviceName]);

  _rttiContext := TRttiContext.Create;
  try
    _rttiType := _rttiContext.GetType(implementationType);
    _ctor := findSuitableConstructor(_rttiType);

    if not Assigned(_ctor) then
      raise EDIContainer.CreateFmt('No suitable constructor found for: %s', [implementationType.ClassName]);

    _registrations.Add(_serviceName,
      TServiceRegistration.Create(lifetime, implementationType,
        function: TObject
        var
          _params: TArray<TRttiParameter>;
          _instances: TArray<TObject>;
          _paramValues: TArray<TValue>;
          _i: Integer;
          _paramType: TClass;
        begin
          _params := _ctor.GetParameters;
          SetLength(_instances, Length(_params));
          SetLength(_paramValues, Length(_params));
          try
            for _i := 0 to High(_params) do
            begin
              // Get the class type from the parameter
              _paramType := TRttiInstanceType(_params[_i].ParamType).MetaclassType;
              _instances[_i] := resolve(_paramType);
              _paramValues[_i] := TValue.From<TObject>(_instances[_i]);
            end;

            Result := _ctor.Invoke(implementationType, _paramValues).AsObject;
          finally
            // We don't free instances here as they might be singletons
            // The container manages their lifetime
          end;
        end));
  finally
    // RttiContext is managed and doesn't need to be freed
  end;
end;

procedure TDIContainer.registerType(implementationType: TClass; lifetime: TServiceLifetime);
begin
  registerType(implementationType, implementationType, lifetime);
end;

procedure TDIContainer.registerFactory(serviceType: TClass;
  factoryFunc: TFunc<TObject>; lifetime: TServiceLifetime);
var
  _serviceName: string;
begin
  _serviceName := serviceType.ClassName;

  _criticalSection.Enter;
  try
    if _registrations.ContainsKey(_serviceName) then
      raise EDIContainer.CreateFmt('Service already registered: %s', [_serviceName]);

    _registrations.Add(_serviceName,
      TServiceRegistration.Create(lifetime, nil, factoryFunc));
  finally
    _criticalSection.Leave;
  end;
end;

function TDIContainer.resolve(serviceType: TClass): TObject;
var
  _serviceName: string;
begin
  _serviceName := serviceType.ClassName;

  _criticalSection.Enter;
  try
    // Check for circular dependencies
    if isInResolutionStack(_serviceName) then
      raise EDIContainer.CreateFmt('Circular dependency detected: %s', [_serviceName]);

    _resolutionStack.Add(_serviceName);
    try
      Result := internalResolve(_serviceName);
    finally
      _resolutionStack.Delete(_resolutionStack.Count - 1);
    end;
  finally
    _criticalSection.Leave;
  end;
end;

function TDIContainer.resolve<T>: T;
begin
  Result := T(resolve(TClass(T)));
end;

function TDIContainer.tryResolve(serviceType: TClass; out instance: TObject): Boolean;
var
  _serviceName: string;
begin
  _serviceName := serviceType.ClassName;

  _criticalSection.Enter;
  try
    Result := _registrations.ContainsKey(_serviceName);
    if Result then
      instance := resolve(serviceType)
    else
      instance := nil;
  finally
    _criticalSection.Leave;
  end;
end;

function TDIContainer.tryResolve<T>(out instance: T): Boolean;
var
  _obj: TObject;
begin
  Result := tryResolve(TClass(T), _obj);
  if Result then
    instance := T(_obj)
  else
    instance := nil;
end;

function TDIContainer.internalResolve(const serviceName: string): TObject;
var
  _registration: IServiceRegistration;
begin
  _registration := getServiceRegistration(serviceName);
  Result := _registration.createInstance;
end;

function TDIContainer.getServiceRegistration(const serviceName: string): IServiceRegistration;
begin
  if not _registrations.TryGetValue(serviceName, Result) then
    raise EDIContainer.CreateFmt('Service not registered: %s', [serviceName]);
end;

end.
