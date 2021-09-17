unit KLib.XML;

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

function getResourceAsXSL(nameResource: string): IXMLDocument;

implementation

uses
  KLib.Utils, KLib.Validate, KLib.Types, KLib.Constants,
  Xml.XMLDoc;

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
  _result: IXMLNode;
begin
  _result := mainNode.ChildNodes.FindNode(childNodeName);
  Result := _result;
end;

function checkIfIXMLNodeExistsInIXMLNode(mainNode: IXMLNode; childNodeName: string): boolean;
var
  _node: IXMLNode;
  _result: boolean;
begin
  _node := getIXMLNodeFromIXMLNode(mainNode, childNodeName);
  _result := Assigned(_node);
  Result := _result;
end;

function checkIXMLDocumentNodeName(XMLDocument: IXMLDocument; expectedNodeName: string): boolean;
var
  _result: boolean;
  _documentNode: IXMLNode;
begin
  _documentNode := XMLDocument.DocumentElement;
  _result := checkIXMLNodeName(_documentNode, expectedNodeName);
  Result := _result;
end;

function checkIXMLNodeName(mainNode: IXMLNode; expectedNodeName: string): boolean;
var
  _result: boolean;
begin
  _result := mainNode.LocalName = expectedNodeName;
  Result := _result;
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
  _result: boolean;
begin
  _result := mainNode.HasAttribute(attributeName);
  Result := _result;
end;

function getAttributeValueFromIXMLNode(mainNode: IXMLNode; attributeName: string): Variant;
var
  attributeValue: Variant;
begin
  attributeValue := mainNode.Attributes[attributeName];
  Result := attributeValue;
end;

function getResourceAsXSL(nameResource: string): IXMLDocument;
var
  _resource: TResource;
  _resourceAsString: string;
  xls: IXMLDocument;
begin
  with _resource do
  begin
    name := nameResource;
    _type := XSL_TYPE;
  end;
  _resourceAsString := getResourceAsString(_resource);
  xls := LoadXMLData(_resourceAsString);
  Result := xls;
end;

end.
