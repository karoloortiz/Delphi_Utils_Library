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

unit KLib.Generics.Attributes;

interface

uses
  KLib.Types;

type
  FileNameAttribute = class(TCustomAttribute)
  public
    value: string;

    constructor Create(const value: string);
  end;

  TSettingStringsAttributeType = (_null, single_quotted, double_quotted);

  SettingStringsAttribute = class(TCustomAttribute)
  public
    value: TSettingStringsAttributeType;
    //todo add lowercase, uppercase, casesensitive
    constructor Create(const value: TSettingStringsAttributeType);
  end;

  //  SettingDoubleAttribute = class(TCustomAttribute)       //TODO
  //  public
  //    value: char;
  //
  //    constructor Create(const value: char);
  //  end;

  SectionNameAttribute = class(TCustomAttribute)
  public
    value: string;

    constructor Create(const value: string);
  end;

  CustomNameAttribute = class(TCustomAttribute)
  public
    value: string;

    constructor Create(const value: string);
  end;

  BooleanAsStringAttribute = class(TCustomAttribute)
  public
    true: string;
    false: string;

    constructor Create(const trueValue: string; const falseValue: string);
  end;

  ParamNameAttribute = class(TCustomAttribute)
  public
    value: string;

    constructor Create(const value: string);
  end;

  DefaultValueAttribute = class(TCustomAttribute)
  public
    value: string;

    constructor Create(const value: string);
  end;

  SettingStringDequoteAttribute = class(TCustomAttribute)
  public
    constructor Create;
  end;

  ValidateFullPathAttribute = class(TCustomAttribute)
  public
    constructor Create;
  end;

  IgnoreAttribute = class(TCustomAttribute)
  public
    constructor Create;
  end;

  MinAttribute = class(TCustomAttribute)
  public
    value: Double;

    constructor Create(const value: Double);
  end;

  MaxAttribute = class(TCustomAttribute)
  public
    value: Double;

    constructor Create(const value: Double);
  end;

  RequiredAttribute = class(TCustomAttribute)
  public
    constructor Create;
  end;

implementation

uses
  System.Variants;

constructor FileNameAttribute.Create(const value: string);
begin
  Self.value := value;
end;

constructor SettingStringsAttribute.Create(const value: TSettingStringsAttributeType);
begin
  Self.value := value;
end;

constructor SectionNameAttribute.Create(const value: string);
begin
  Self.value := value;
end;

constructor CustomNameAttribute.Create(const value: string);
begin
  Self.value := value;
end;

constructor BooleanAsStringAttribute.Create(const trueValue: string; const falseValue: string);
begin
  Self.true := trueValue;
  Self.false := falseValue;
end;

constructor ParamNameAttribute.Create(const value: string);
begin
  Self.value := value;
end;

constructor DefaultValueAttribute.Create(const value: string);
begin
  Self.value := value;
end;

constructor SettingStringDequoteAttribute.Create;
begin
end;

constructor ValidateFullPathAttribute.Create;
begin
end;

constructor IgnoreAttribute.Create;
begin
end;

constructor MinAttribute.Create(const value: Double);
begin
  Self.value := value;
end;

constructor MaxAttribute.Create(const value: Double);
begin
  Self.value := value;
end;

constructor RequiredAttribute.Create;
begin
end;

end.
