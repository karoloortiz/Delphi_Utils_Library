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

unit KLib.Xml;

interface

uses
  Xml.XMLIntf;

function getNewIXMLNode(mainNode: IXMLNode; childNodeName: string; childNodeText: string = ''): IXMLNode;
function getValidIXMLNodeFromIXMLDocument(XMLDocument: IXMLDocument; nodeName: string): IXMLNode;
function getValidIXMLNodeFromIXMLNode(mainNode: IXMLNode; childNodeName: string): IXMLNode;
function getIXMLNodeFromIXMLNode(mainNode: IXMLNode; childNodeName: string): IXMLNode;
function checkIfIXMLNodeExistsInIXMLNode(mainNode: IXMLNode; childNodeName: string): boolean;
function checkIXMLDocumentNodeName(XMLDocument: IXMLDocument; expectedNodeName: string): boolean;
function checkIXMLNodeName(mainNode: IXMLNode; expectedNodeName: string): boolean;
function getValidAttributeValueFromIXMLNode(mainNode: IXMLNode; attributeName: string): Variant;
function checkIfAttributeExistsInIXMLNode(mainNode: IXMLNode; attributeName: string): boolean;
function getAttributeValueFromIXMLNode(mainNode: IXMLNode; attributeName: string): Variant;

function getIXMLDocument(fileName: string): IXMLDocument;

function getResourceAsXSL(nameResource: string): IXMLDocument;

implementation

uses
  KLib.FileSystem, KLib.Validate, KLib.Types, KLib.Constants,
  Xml.XMLDoc,
  Winapi.ActiveX;

function getNewIXMLNode(mainNode: IXMLNode; childNodeName: string; childNodeText: string = ''): IXMLNode;
var
  childnode: IXMLNode;
begin
  childnode := mainNode.AddChild(childNodeName);
  if childNodeText <> '' then
  begin
    childnode.Text := childNodeText;
  end;

  Result := childnode;
end;

function getValidIXMLNodeFromIXMLDocument(XMLDocument: IXMLDocument; nodeName: string): IXMLNode;
var
  XMLNode: IXMLNode;

  _documentNode: IXMLNode;
begin
  _documentNode := XMLDocument.DocumentElement;
  XMLNode := getValidIXMLNodeFromIXMLNode(_documentNode, nodeName);

  Result := XMLNode;
end;

function getValidIXMLNodeFromIXMLNode(mainNode: IXMLNode; childNodeName: string): IXMLNode;
var
  childNode: IXMLNode;
begin
  validateThatIXMLNodeExistsInIXMLNode(mainNode, childNodeName);
  childNode := getIXMLNodeFromIXMLNode(mainNode, childNodeName);

  Result := childNode;
end;

function getIXMLNodeFromIXMLNode(mainNode: IXMLNode; childNodeName: string): IXMLNode;
var
  XMLNode: IXMLNode;
begin
  XMLNode := mainNode.ChildNodes.FindNode(childNodeName);

  Result := XMLNode;
end;

function checkIfIXMLNodeExistsInIXMLNode(mainNode: IXMLNode; childNodeName: string): boolean;
var
  nodeExists: boolean;

  _node: IXMLNode;
begin
  _node := getIXMLNodeFromIXMLNode(mainNode, childNodeName);
  nodeExists := Assigned(_node);

  Result := nodeExists;
end;

function checkIXMLDocumentNodeName(XMLDocument: IXMLDocument; expectedNodeName: string): boolean;
var
  nodeHasSameName: boolean;

  _documentNode: IXMLNode;
begin
  _documentNode := XMLDocument.DocumentElement;
  nodeHasSameName := checkIXMLNodeName(_documentNode, expectedNodeName);

  Result := nodeHasSameName;
end;

function checkIXMLNodeName(mainNode: IXMLNode; expectedNodeName: string): boolean;
var
  nodeHasSameName: boolean;
begin
  nodeHasSameName := mainNode.LocalName = expectedNodeName;

  Result := nodeHasSameName;
end;

function getValidAttributeValueFromIXMLNode(mainNode: IXMLNode; attributeName: string): Variant;
var
  attributeValue: Variant;
begin
  validateThatAttributeExistsInIXMLNode(mainNode, attributeName);
  attributeValue := getAttributeValueFromIXMLNode(mainNode, attributeName);

  Result := attributeValue;
end;

function checkIfAttributeExistsInIXMLNode(mainNode: IXMLNode; attributeName: string): boolean;
var
  attributeExists: boolean;
begin
  attributeExists := mainNode.HasAttribute(attributeName);

  Result := attributeExists;
end;

function getAttributeValueFromIXMLNode(mainNode: IXMLNode; attributeName: string): Variant;
var
  attributeValue: Variant;
begin
  attributeValue := mainNode.Attributes[attributeName];

  Result := attributeValue;
end;

function getIXMLDocument(fileName: string): IXMLDocument;
var
  XML: IXMLDocument;
begin
  CoInitialize(nil);
  try
    XML := LoadXMLDocument(fileName);
  finally
    CoUninitialize;
  end;

  Result := XML;
end;

function getResourceAsXSL(nameResource: string): IXMLDocument;
var
  XLS: IXMLDocument;

  _resource: TResource;
  _resourceAsString: string;
begin
  with _resource do
  begin
    name := nameResource;
    _type := XSL_TYPE;
  end;
  _resourceAsString := getResourceAsString(_resource);
  XLS := LoadXMLData(_resourceAsString);

  Result := XLS;
end;

end.
