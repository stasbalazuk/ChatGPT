{*******************************************************}
{       RTTI                                            }
{       (C) 2013      YangYxd                           }

unit YxdRtti;

interface

{$IF RTLVersion>=24}
{$LEGACYIFEND ON}
{$IFEND}

{$DEFINE USEYxdStr}               // �Ƿ�ʹ��YxdStr��Ԫ
{$DEFINE USEIniSerialize}         // ʹ��INI���л�ģ��
{$DEFINE USEXmlSerialize}         // ʹ��XML���л�ģ��
{$DEFINE USEJsonSerialize}        // ʹ��Json���л�ģ��
{$DEFINE USEDataSet}              // �Ƿ�ʹ��DataSet���л�����


{$IF RTLVersion>=26}
{$DEFINE USE_UNICODE}
{$IFEND}

{$IF RTLVersion>=10}
{$IFNDEF VER150}
{$DEFINE HELPER_SUPPORT}
{$ENDIF}
{$IFEND}

uses
  {$IFDEF USEYxdStr}YxdStr, {$ENDIF}
  {$IFDEF MSWINDOWS}Windows, {$ENDIF}
  {$IFDEF USE_UNICODE}Generics.Collections, Rtti, {$ENDIF}
  {$IFDEF USE_UNICODE}Soap.EncdDecd, {$ELSE}Base64, {$ENDIF}
  {$IF CompilerVersion > 27}System.NetEncoding, {$IFEND}
  {$IFDEF USEDataSet}DB, DBClient, {$ENDIF}
  {$IFDEF USEJsonSerialize}YxdJson, {$ENDIF}   
  SysUtils, Classes, Variants, TypInfo, Math, DateUtils;

type
  /// <summary>
  /// ���л�����
  /// </summary>
  TSerializeType = (afXML,{XML��ʽ} afIni,{ini�ļ�} afJson {json��ʽ});

  {$IFDEF USE_UNICODE}
  TValueArray = array of TValue;
  {$ENDIF}

  {$IFDEF USE_UNICODE}
  /// <summary>
  /// ע���ඨ�壺�ֶ�����
  /// </summary>
  FieldNameAttribute = class(TCustomAttribute)
  private
    FName: string;
  public
    constructor Create(const AName: string);
    property Name: string read FName;
  end;
  {$ENDIF}

  {$IFDEF USEDataSet}
  {$IFDEF HELPER_SUPPORT}
  // DataSet Helper
  TDateSetHelper = class helper for TDataSet
    function Exist(const FieldName: string): Boolean;
    function GetBoolean(const FieldName: string; DefaultValue: Boolean = False): Boolean;
    function GetInt(const FieldName: string; DefaultValue: Integer = 0): Integer;
    function GetDWORD(const FieldName: string; DefaultValue: Cardinal = 0): Cardinal;
    function GetFloat(const FieldName: string; DefaultValue: Double = 0): Double;
    function GetDateTime(const FieldName: string): TDateTime;
    function GetVariant(const FieldName: string): Variant;
    function GetString(const FieldName: string): string;
    function GetWideString(const FieldName: string): WideString;
  end;
  {$ENDIF}
  {$ENDIF}

type
  PSerializeStack = ^TSerializeStack;
  TSerializeStack = record
    Next: PSerializeStack;
    Value: Boolean;
  end;

  /// <summary>
  /// ���л�д��������
  /// </summary>
  TSerializeWriter = class
  protected
    FStack: PSerializeStack;
    procedure Push(const Value: Boolean);
    function Pop(): Boolean;
  protected
    procedure BeginRoot; virtual; abstract;
    procedure EndRoot; virtual; abstract;

    procedure BeginData(const Name: string; const IsArray: Boolean); virtual; abstract;
    procedure EndData(); virtual; abstract;

    procedure Add(const Value: string); overload; virtual; abstract;
    procedure Add(const Value: Integer); overload; virtual; abstract;
    procedure Add(const Value: Cardinal); overload; virtual; abstract;
    procedure Add(const Value: Double); overload; virtual; abstract;
    procedure Add(const Value: Boolean); overload; virtual; abstract;
    procedure Add(const Value: Variant); overload; virtual; abstract;
    procedure AddTime(const Value: TDateTime); overload; virtual; abstract;
    procedure AddInt64(const Value: Int64); overload; virtual; abstract;

    procedure WriteString(const Name, Value: string); virtual; abstract;
    procedure WriteInt(const Name: string; const Value: Integer); virtual; abstract;
    procedure WriteInt64(const Name: string; const Value: Int64); virtual; abstract;
    procedure WriteUInt(const Name: string; const Value: Cardinal); virtual; abstract;
    procedure WriteDateTime(const Name: string; const Value: TDateTime); virtual; abstract;
    procedure WriteBoolean(const Name: string; const Value: Boolean); virtual; abstract;
    procedure WriteFloat(const Name: string; const Value: Double); overload; virtual; abstract;
    procedure WriteVariant(const Name: string; const Value: Variant); overload; virtual; abstract;

    procedure WriteNull(const Name: string); virtual; abstract;
  public
    procedure SaveToFile(const AFileName: string); 
    function SaveToStream(AStream: TStream): Integer; virtual;
    {$IFNDEF USE_UNICODE}
    function ToString(): string; virtual;
    {$ENDIF}
    function IsArray: Boolean; virtual;
  end;

type
  TYxdSerialize = class
  protected
    class procedure LoadCollection(AIn: JSONBase; ACollection: TCollection);
    class function ArrayItemTypeName(ATypeName: JSONString): JSONString;
    class function ArrayItemType(ArrType: PTypeInfo): PTypeInfo;
  public
    class function GetObjectTypeInfo(AObj: TObject): PTypeInfo;

    class procedure Serialize(Writer: TSerializeWriter; const Key: string; ASource: TObject); overload;
    class procedure Serialize(Writer: TSerializeWriter; const Key: string; ASource: Pointer; AType: PTypeInfo); overload;
    {$IFDEF USEDataSet}
    class procedure Serialize(Writer: TSerializeWriter; const Key: string; ADataSet: TDataSet;
      const PageIndex, PageSize: Integer; Base64Blob: Boolean = True); overload;
    {$ENDIF}
    {$IFDEF USE_UNICODE}
    class procedure Serialize(Writer: TSerializeWriter; const Key: string; AInstance: TValue); overload;
    {$ENDIF}
    class procedure Serialize(Writer: TSerializeWriter; AJson: JSONBase; IsBegin: Boolean = True); overload;

    class procedure ReadValue(AIn: JSONBase; ADest: Pointer; aType: {$IFDEF USE_UNICODE}PTypeInfo{$ELSE}PTypeInfo{$ENDIF}); overload;
    {$IFDEF USEDataSet}
    class procedure ReadValue(AIn: TDataSet; ADest: Pointer; aType: {$IFDEF USE_UNICODE}PTypeInfo{$ELSE}PTypeInfo{$ENDIF}); overload;
    {$ENDIF}
    class procedure ReadObject(AIn: JSONBase; ADest: TObject);
    class procedure WriteValue(AOut: JSONBase; const Key: JSONString; ASource: Pointer; AType: PTypeInfo); overload;
    {$IFDEF USEDataSet}

    class function ReadDataSet(AIn: JSONBase; ADest: TDataSet): Integer;

    class procedure WriteDataSet(AOut: JSONBase; const Key: JSONString; ADataSet: TDataSet;
      const PageIndex, PageSize: Integer; Base64Blob: Boolean = True);
    {$ENDIF}
    {$IFDEF USE_UNICODE}
    class procedure ReadValue(AIn: JSONBase; AInstance: TValue); overload;
    class procedure ReadRecord<T>(AIn: JSONBase; out AInstance: T); overload;
    {$IFDEF USEDataSet}
    class procedure ReadValue(AIn: TDataSet; AInstance: TValue); overload;
    class procedure ReadRecord<T>(AIn: TDataSet; out AInstance: T); overload;
    {$ENDIF}
    class function WriteToValue(AIn: PJSONValue): TValue; overload;
    class function WriteToValue(AIn: JSONBase): TValue; overload;
    class procedure WriteValue(AOut: JSONBase; const Key: JSONString; AInstance: TValue); overload;
    {$ENDIF}
    class procedure WriteBlobStream(Writer: TSerializeWriter; const Data: Pointer; const Size: Int64; Base64Blob: Boolean = True);
    /// Blog
    class function BlobStreamToString(const Data: Pointer; const Size: Int64; Base64Blob: Boolean = True): JSONString; overload;
    class function BlobStreamToString(Data: TStream; Base64Blob: Boolean = True): JSONString; overload;
    class function BlobStreamToString(const Data: TBytes; Base64Blob: Boolean = True): JSONString; overload;
    class function IsBlob(P: PJSONChar; HighL: Integer): Boolean;
    class function BlobStringToStream(Data: Pointer; Size: Integer): TMemoryStream;
  end;

type
  /// <summary>
  /// MsgPack
  /// </summary>
  TMsgPackSerializeWriter = class(TSerializeWriter)
  private
    FData: TMemoryStream;
    FIsArray: Boolean;
    FDoEscape: Boolean;
  protected
    procedure WriteName(const Name: string); {$IFDEF USEINLINE}inline;{$ENDIF}
    
    procedure BeginRoot; override;
    procedure EndRoot; override;

    procedure BeginData(const Name: string; const IsArray: Boolean); override;
    procedure EndData(); override;

    procedure Add(const Value: string); overload; override;
    procedure Add(const Value: Integer); overload; override;
    procedure Add(const Value: Cardinal); overload; override;
    procedure Add(const Value: Double); overload; override;
    procedure Add(const Value: Boolean); overload; override;
    procedure Add(const Value: Variant); overload; override;
    procedure AddTime(const Value: TDateTime); overload; override;
    procedure AddInt64(const Value: Int64); overload; override;

    procedure WriteString(const Name, Value: string); override;
    procedure WriteInt(const Name: string; const Value: Integer); override;
    procedure WriteInt64(const Name: string; const Value: Int64); override;
    procedure WriteUInt(const Name: string; const Value: Cardinal); override;
    procedure WriteDateTime(const Name: string; const Value: TDateTime); override;
    procedure WriteBoolean(const Name: string; const Value: Boolean); override;
    procedure WriteFloat(const Name: string; const Value: Double); override;
    procedure WriteVariant(const Name: string; const Value: Variant); override;

    procedure WriteNull(const Name: string); override;
  public
    constructor Create;
    destructor Destroy; override;

    function SaveToStream(AStream: TStream): Integer; override;
    function ToString(): string; override;
    function IsArray: Boolean; override;
    property DoEscape: Boolean read FDoEscape write FDoEscape;
  end;

function EncodeBase64(const Input: Pointer; Size: Integer): string;

implementation

const
  CSBlobs: JSONString = '[blob]<';
  CSBlobBase64: PJSONChar = '[BS]';
  CSBlobsLen: Integer = 7;
  CSBlobBase64Len: Integer = 4;
var
  CSPBlobs: PJSONChar;
  CSPBlobs2, CSPBlobs3: PJSONChar;

resourcestring
  SUnsupportPropertyType = 'UnsupportPropertyType';
  SMissRttiTypeDefine = 'SMiss %s RttiTypeDefine (array[0..1] of ByteTByteArr=array[0..1]TByteArr)';
  SArrayTypeMissed = 'TypeMissed';
  SErrorJsonType = 'JsonType';
  SObjectChildNeedName = 'Object %s Child %d NeedName';

type TPointerStream = class(TCustomMemoryStream);

function EncodeBase64(const Input: Pointer; Size: Integer): string;
{$IFDEF USE_UNICODE}
var
  FBase64: TBase64Encoding;
begin
  FBase64 := TBase64Encoding.Create(-1);
  try
    Result := FBase64.EncodeBytesToString(Input, Size);
  finally
    FreeAndNil(FBase64);
  end;
{$ELSE}
begin
  Result := string(Base64Encode(Input^, Size));
{$ENDIF}
end;

{ FiledNameAttribute }

{$IFDEF USE_UNICODE}
constructor FieldNameAttribute.Create(const AName: string);
begin
  FName := AName;
end; 
{$ENDIF}

{$IFDEF USE_UNICODE}
//����XE6��System.rtti��TValue��tkSet���ʹ����Bug
function SetAsOrd(AValue: TValue): Int64;
var
  ATemp: Integer;
begin
  AValue.ExtractRawData(@ATemp);
  case GetTypeData(AValue.TypeInfo).OrdType of
    otSByte:
      Result := PShortint(@ATemp)^;
    otUByte:
      Result := PByte(@ATemp)^;
    otSWord:
      Result := PSmallint(@ATemp)^;
    otUWord:
      Result := PWord(@ATemp)^;
    otSLong:
      Result := PInteger(@ATemp)^;
    otULong:
      Result := PCardinal(@ATemp)^;
  else
    Result := 0
  end;
end;
{$ENDIF}

{ TDateSetHelper }

{$IFDEF USEDataSet}
{$IFDEF HELPER_SUPPORT}
function TDateSetHelper.Exist(const FieldName: string): Boolean;
begin
  Result := FindField(FieldName) <> nil;
end;

function TDateSetHelper.GetBoolean(const FieldName: string;
  DefaultValue: Boolean): Boolean;
var
  F: TField;
begin
  F := FindField(FieldName);
  if Assigned(F) then
    Result := F.AsBoolean
  else
    Result := DefaultValue;
end;

function TDateSetHelper.GetDateTime(const FieldName: string): TDateTime;
var
  F: TField;
begin
  F := FindField(FieldName);
  if Assigned(F) then
    Result := F.AsDateTime
  else
    Result := 0;
end;

function TDateSetHelper.GetDWORD(const FieldName: string;
  DefaultValue: Cardinal): Cardinal;
var
  F: TField;
begin
  F := FindField(FieldName);
  if Assigned(F) then
    Result := F.AsInteger
  else
    Result := DefaultValue;
end;

function TDateSetHelper.GetFloat(const FieldName: string;
  DefaultValue: Double): Double;
var
  F: TField;
begin
  F := FindField(FieldName);
  if Assigned(F) then
    Result := F.AsFloat
  else
    Result := DefaultValue;
end;

function TDateSetHelper.GetInt(const FieldName: string;
  DefaultValue: Integer): Integer;
var
  F: TField;
begin
  F := FindField(FieldName);
  if Assigned(F) and (not F.IsNull) then
    Result := F.AsInteger
  else
    Result := DefaultValue;
end;

function TDateSetHelper.GetString(const FieldName: string): string;
var
  F: TField;
begin
  F := FindField(FieldName);
  if Assigned(F) and (not F.IsNull) then
    Result := F.AsString
  else
    Result := '';
end;

function TDateSetHelper.GetVariant(const FieldName: string): Variant;
var
  F: TField;
begin
  F := FindField(FieldName);
  if Assigned(F) then
    Result := F.AsVariant
  else
    Result := vaNull;
end;

function TDateSetHelper.GetWideString(const FieldName: string): WideString;
var
  F: TField;
begin
  F := FindField(FieldName);
  if Assigned(F) then
    Result := F.AsWideString
  else
    Result := '';
end;
{$ENDIF}
{$ENDIF}

{ TSerializeWriter }

function TSerializeWriter.IsArray: Boolean;
begin
  if FStack <> nil then
    Result := FStack.Value
  else
    Result := False;
end;

function TSerializeWriter.Pop: Boolean;
var
  ALast: PSerializeStack;
begin
  if Assigned(FStack) then begin
    ALast := FStack;
    Result := ALast.Value;
    FStack := ALast.Next;
    Dispose(ALast);
  end else
    Result := False;
end;

procedure TSerializeWriter.Push(const Value: Boolean);
var
  AItem: PSerializeStack;
begin
  New(AItem);
  AItem.Next := FStack;
  AItem.Value := Value;
  FStack := AItem;
end;

{$IFNDEF USE_UNICODE} 
function TSerializeWriter.ToString: string;
begin
  Result := Self.ClassName;
end;
{$ENDIF}

procedure TSerializeWriter.SaveToFile(const AFileName: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStream(Stream);  
  finally
    FreeAndNil(Stream);
  end;
end;

function TSerializeWriter.SaveToStream(AStream: TStream): Integer; 
var
  Data: string;
  {$IFDEF UNICODE}
  UData: AnsiString;
  {$ENDIF}
begin
  if not Assigned(AStream) then
    raise Exception.Create('�� Stream �');
  Data := ToString;
  if Length(Data) > 0 then begin
    {$IFDEF UNICODE}
    UData := {$IFDEF USEYxdStr}YxdStr{$ELSE}YxdJson{$ENDIF}.Utf8Encode(Data);
    Result := {$IFDEF NEXTGEN}UData.Length{$ELSE}Length(UData){$ENDIF};
    if Result > 0 then
      AStream.WriteBuffer(PAnsiChar(UData)^, Result);
    {$ELSE}
    Result := Length(Data) {$IFDEF UNICODE} shl 1 {$ENDIF};
    AStream.WriteBuffer(PChar(Data)^, Result);
    {$ENDIF}
  end else
    Result := 0;
end;

{ TYxdSerialize }

class function TYxdSerialize.ArrayItemType(ArrType: PTypeInfo): PTypeInfo;
var
  ATypeData: PTypeData;
begin
  Result := nil;
  if (ArrType <> nil) and (ArrType.Kind in [tkArray,tkDynArray]) then begin
    ATypeData := GetTypeData(ArrType);
    if (ATypeData <> nil) then
      Result := ATypeData.elType2^;
    if Result = nil then begin
      if ATypeData.BaseType^ = TypeInfo(Byte) then
        Result := TypeInfo(Byte);
    end;
  end;
end;

class function TYxdSerialize.ArrayItemTypeName(ATypeName: JSONString): JSONString;
var
  p, ps: PJSONChar;
  ACount: Integer;
begin
  p := PJSONChar(ATypeName);
  if StartWith(p, 'TArray<', true) then begin
    Inc(p, 7);
    ps := p;
    ACount := 1;
    while ACount >0 do begin
      if p^ = '>' then
        Dec(ACount)
      else if p^ = '<' then
        Inc(ACount);
      Inc(p);
    end;
    Result := StrDupX(ps, p-ps-1);
  end else
    Result:='';
end;

class function TYxdSerialize.GetObjectTypeInfo(AObj: TObject): PTypeInfo;
begin
  if Assigned(AObj) then
    Result := AObj.ClassInfo
  else
    Result := nil;
end;

class function TYxdSerialize.IsBlob(P: PJSONChar; HighL: Integer): Boolean;
begin
  {$IFDEF USE_UNICODE}
  Result := (HighL >= (CSBlobsLen shl 1))
      and (PInt64(p)^ = PInt64(CSPBlobs)^)
      and (PCardinal(IntPtr(P)+8)^ = PCardinal(CSPBlobs2)^)
      and (PWORD(IntPtr(P)+12)^ = PWORD(CSPBlobs3)^)
      and (PJSONChar(IntPtr(P) + HighL - 1)^ = '>');
  {$ELSE}
  Result := (HighL >= CSBlobsLen)
      and (PDWORD(p)^ = PDWORD(CSPBlobs)^)
      and (PWORD(IntPtr(P)+4)^ = PWORD(CSPBlobs2)^)
      and (PByte(IntPtr(P)+6)^ = PByte(CSPBlobs3)^)
      and (PJSONChar(IntPtr(P) + HighL)^ = '>');
  {$ENDIF}
end;

class procedure TYxdSerialize.Serialize(Writer: TSerializeWriter; const Key: string;
  ASource: Pointer; AType: PTypeInfo);

  procedure AddCollection(Writer: TSerializeWriter; ACollection:TCollection);
  var
    J: Integer;
  begin
    for J := 0 to ACollection.Count-1 do
      Serialize(Writer, '', ACollection.Items[J]{$IFNDEF USE_UNICODE}, GetObjectTypeInfo(ACollection.Items[J]){$ENDIF});
  end;

  {$IFDEF USE_UNICODE}
  procedure AddRecord(Writer: TSerializeWriter);
  var
    AObj: TObject;
    AValue: TValue;
    AFieldItem: TRttiField;
    AContext: TRttiContext;
    AFields: TArray<TRttiField>;
    ARttiType: TRttiType;
    AFieldName: string;
    AFieldAttrItem: TCustomAttribute;
    II, J: Integer;
  begin
    AContext := TRttiContext.Create;
    ARttiType := AContext.GetType(AType);
    AFields := ARttiType.GetFields;
    //����Ǵӽṹ�壬���¼���Ա������Ƕ�����ֻ��¼�乫�������ԣ����⴦��TStrings��TCollection
    for J := Low(AFields) to High(AFields) do begin
      AFieldItem := AFields[J];
      if AFieldItem.FieldType <> nil then begin

        AFieldName := AFieldItem.Name;
        if AFieldItem.GetAttributes <> nil then begin
          for AFieldAttrItem in AFieldItem.GetAttributes do
            if AFieldAttrItem is FieldNameAttribute then begin
              AFieldName := FieldNameAttribute(AFieldAttrItem).Name;
              Break;
            end;
        end;

        case AFieldItem.FieldType.TypeKind of
          tkInteger:
            Writer.WriteInt(AFieldName, AFieldItem.GetValue(ASource).AsInteger);
          {$IFNDEF NEXTGEN}tkString,tkLString,tkWString,{$ENDIF !NEXTGEN}tkUString:
            Writer.WriteString(AFieldName, AFieldItem.GetValue(ASource).AsString);
          tkEnumeration:
            begin
              if GetTypeData(AFieldItem.FieldType.Handle).BaseType^ = TypeInfo(Boolean) then
                Writer.WriteBoolean(AFieldName, AFieldItem.GetValue(ASource).AsBoolean)
              else if JsonRttiEnumAsInt then
                Writer.WriteInt64(AFieldName, AFieldItem.GetValue(ASource).AsOrdinal)
              else
                Writer.WriteString(AFieldName, AFieldItem.GetValue(ASource).ToString);
            end;
          tkSet:
            begin
              if JsonRttiEnumAsInt then
                Writer.WriteInt(AFieldName, SetAsOrd(AFieldItem.GetValue(ASource)))
              else
                Writer.WriteString(AFieldName, AFieldItem.GetValue(ASource).ToString);
            end;
          tkChar,tkWChar:
            Writer.WriteString(AFieldName, AFieldItem.GetValue(ASource).ToString);
          tkFloat:
            begin
              if (AFieldItem.FieldType.Handle = TypeInfo(TDateTime)) or
                (AFieldItem.FieldType.Handle = TypeInfo(TTime)) or
                (AFieldItem.FieldType.Handle = TypeInfo(TDate))
                 then
                Writer.WriteDateTime(AFieldName, AFieldItem.GetValue(ASource).AsExtended)
              else
                Writer.WriteFloat(AFieldName, AFieldItem.GetValue(ASource).AsExtended);
            end;
          tkInt64:
            Writer.WriteInt64(AFieldName, AFieldItem.GetValue(ASource).AsInt64);
          tkVariant:
            Writer.WriteVariant(AFieldName, AFieldItem.GetValue(ASource).AsVariant);
          tkArray, tkDynArray:
            begin
              Writer.BeginData(AFieldName, True);
              AValue := AFieldItem.GetValue(ASource);
              for II := 0 to AValue.GetArrayLength - 1 do
                Serialize(Writer, '', AValue.GetArrayElement(II));
              Writer.EndData;
            end;
          tkClass:
            begin
              AObj := AFieldItem.GetValue(ASource).AsObject;
              if (AObj is TStrings) then
                Writer.WriteString(AFieldName, TStrings(AObj).Text)
              else if AObj is TCollection then begin
                Writer.BeginData(AFieldName, True);
                AddCollection(Writer, AObj as TCollection);
                Writer.EndData;
              end else
                Serialize(Writer, AFieldName, AObj, AFieldItem.FieldType.Handle);
            end;
          tkRecord:
            Serialize(Writer, AFieldName, Pointer(IntPtr(ASource) + AFieldItem.Offset),
              AFieldItem.FieldType.Handle);
        end;
      end else
        raise Exception.CreateFmt(SMissRttiTypeDefine, [AFieldName]);
    end;
  end;
  {$ENDIF}

  procedure AddStrings(Writer: TSerializeWriter; Data: TStrings);
  var
    I: Integer;
  begin
    for I := 0 to Data.Count - 1 do
      Writer.Add(Data[I]);
  end;

  procedure AddObject(Writer: TSerializeWriter);
  var
    AName: JSONString;
    APropList: PPropList;
    ACount: Integer;
    AObj, AChildObj: TObject;
    J: Integer;
  begin
    AObj := ASource;
    ACount := GetPropList(AType, APropList);
    try
      for J := 0 to ACount - 1 do begin
        if APropList[J].PropType^.Kind in [tkMethod{$IFDEF USE_UNICODE}, tkProcedure{$ENDIF}] then
          Continue;
        if APropList[J].PropType^.Kind in
          [tkInterface{$IFDEF USE_UNICODE}, tkClassRef, tkPointer{$ENDIF}]
        then begin
          if IsDefaultPropertyValue(AObj, APropList[J], nil) then
            Continue;
        end;
        {$IF RTLVersion>25}
        AName := APropList[J].NameFld.ToString;
        {$ELSE}
        AName := String(APropList[J].Name);
        {$IFEND}
        case APropList[J].PropType^.Kind of
          tkClass:
            begin
              AChildObj := Pointer(GetOrdProp(AObj, APropList[J]));
              if AChildObj is TStrings then
                Writer.WriteString(AName, (AChildObj as TStrings).Text)
              else if AChildObj is TCollection then begin
                Writer.BeginData(AName, True);
                AddCollection(Writer, AChildObj as TCollection);
                Writer.EndData;
              end else if Assigned(AChildObj) then
                Serialize(Writer, AName, AChildObj);
            end;
          tkInteger:
            begin
              Writer.WriteInt(AName, GetOrdProp(AObj,APropList[J]));
            end;
          tkChar,tkString,tkWChar, tkLString, tkWString{$IFDEF USE_UNICODE}, tkUString{$ENDIF}:
            Writer.WriteString(AName, GetStrProp(AObj,APropList[J]));
          tkEnumeration:
            begin
              if GetTypeData(APropList[J]^.PropType^)^.BaseType^ = TypeInfo(Boolean) then
                Writer.WriteBoolean(AName, GetOrdProp(AObj,APropList[J])<>0)
              else if JsonRttiEnumAsInt then
                Writer.WriteInt(AName, GetOrdProp(AObj,APropList[J]))
              else
                Writer.WriteString(AName, GetEnumProp(AObj,APropList[J]));
            end;
          tkSet:
            begin
              if JsonRttiEnumAsInt then
                Writer.WriteInt(AName, GetOrdProp(AObj, APropList[J]))
              else
                Writer.WriteString(AName, GetSetProp(AObj,APropList[J], True));
            end;
          tkFloat:
            begin
              Writer.WriteFloat(AName, GetFloatProp(AObj, APropList[J]));
            end;
          tkVariant:
            begin
              {$IFDEF NEXTGEN}
              Writer.WriteVariant(AName, GetPropValue(AObj, APropList[J]));
              {$ELSE}
              Writer.WriteVariant(AName, GetPropValue(AObj, string(APropList[J].Name)));
              {$ENDIF}
            end;
          tkInt64:
            Writer.WriteInt64(AName, GetInt64Prop(AObj,APropList[J]));
          tkRecord, tkArray, tkDynArray: //��¼�����顢��̬��������ϵͳҲ�����棬Ҳû�ṩ����̫�õĽӿ�
            raise Exception.Create(SUnsupportPropertyType);
        end;
      end;
    finally
      FreeMem(APropList);
    end;
  end;

  {$IFDEF USE_UNICODE}
  procedure AddArray(Writer: TSerializeWriter);
  var
    I: Integer;
    AValue: TValue;
  begin
    TValue.Make(ASource, AType, AValue);
    Writer.BeginData(Key, True);
    for I := 0 to AValue.GetArrayLength - 1 do
      Serialize(Writer, '', AValue.GetArrayElement(I));
    Writer.EndData;
  end;
  {$ENDIF}

begin
  if not Assigned(ASource) then Exit;
  case AType.Kind of
    {$IFDEF USE_UNICODE}
    tkRecord:
      begin
        Writer.BeginData(Key, False);
        AddRecord(Writer);
        Writer.EndData;
      end;
    {$ENDIF}
    tkClass:
      begin
        if TObject(ASource) is TStrings then begin
          if (Key = '')  then begin
            if Writer.IsArray then
              AddStrings(Writer, TStrings(ASource))
            else
              Writer.WriteString('text', TStrings(ASource).Text);
          end else
            Writer.WriteString(Key, TStrings(ASource).Text);
        end else if TObject(ASource) is TCollection then begin
          AddCollection(Writer, TCollection(ASource))
        {$IFDEF USEDataSet}
        end else if TObject(ASource) is TDataSet then begin
          Serialize(Writer, Key, TDataSet(ASource), 0, -1)
        {$ENDIF}
        end else begin
          if Writer.IsArray then
            Writer.BeginData(Key, True)
          else 
            Writer.BeginData(Key, False);
          AddObject(Writer);
          Writer.EndData;
        end;
      end;
    {$IFDEF USE_UNICODE}
    tkDynArray, tkArray:
      begin
        Writer.BeginData(Key, True);
        AddArray(Writer);
        Writer.EndData;
      end;
    {$ENDIF}
  end;
end;

class procedure TYxdSerialize.Serialize(Writer: TSerializeWriter; const Key: string; ASource: TObject);
begin
  {$IFNDEF USE_UNICODE}
  Serialize(Writer, Key, ASource, GetObjectTypeInfo(ASource));
  {$ELSE}
  Serialize(Writer, Key, TValue(ASource));
  {$ENDIF}
end;

class procedure TYxdSerialize.Serialize(Writer: TSerializeWriter; AJson: JSONBase; IsBegin: Boolean);

  procedure DoSerialize(Writer: TSerializeWriter; AJson: JSONBase);
  var
    I: Integer;
    Item: PJSONValue;
    IsArray: Boolean;
  begin
    if not Assigned(AJson) then
      Exit;
    if AJson.Count > 0 then begin
      IsArray := AJson.IsJSONArray;
      if IsBegin then
        Writer.BeginData(AJson.Name, IsArray);

      for I := 0 to AJson.Count - 1 do begin
        Item := AJson.Items[I];
        if Item = nil then Continue;
        case Item.FType of
          jdtObject:
            begin
              if Item.GetObject <> nil then begin
                if not Item.GetObject.IsJSONArray then begin
                  if (not IsArray) and (Length(Item.FName) = 0) then
                    raise Exception.CreateFmt(SObjectChildNeedName, [Item.FName, I]);
                end;
                DoSerialize(Writer, Item.GetObject);
              end;
            end;
          jdtString:
            begin
              Writer.WriteString(Item.FName, Item.AsString);
            end;
          jdtInteger:
            begin
              Writer.WriteInt(Item.FName, Item.AsInteger);
            end;
          jdtFloat:
            begin
              Writer.WriteFloat(Item.FName, Item.AsFloat);
            end;
          jdtBoolean:
            begin
              Writer.WriteBoolean(Item.FName, Item.AsBoolean);
            end;
          jdtDateTime:
            begin
              if StrictJson then
                Writer.WriteDateTime(Item.FName, Item.AsDateTime)
              else
                Writer.WriteString(Item.FName, Item.ToString)
            end;
          jdtBytes:
            begin
              Writer.WriteString(Item.FName, Item.AsString);
            end;
          jdtNull, jdtUnknown:
            Writer.WriteNull(Item.FName);
        else
          Writer.WriteNull(Item.FName);
        end;
      end;
      if IsBegin then
        Writer.EndData;
    end else if IsBegin then begin
      Writer.BeginData(AJson.Name, AJson.IsJSONArray);
      Writer.EndData;
    end;
  end;

begin
  if not Assigned(AJson) then
    Exit;
  if IsBegin then   
    Writer.BeginRoot;
  DoSerialize(Writer, AJson);
  if IsBegin then
    Writer.EndRoot;
end;

{$IFDEF USE_UNICODE}
class procedure TYxdSerialize.Serialize(Writer: TSerializeWriter; const Key: string; AInstance: TValue);
var
  I,C:Integer;
begin
  case AInstance.Kind of
    tkClass:
      Serialize(Writer, Key, aInstance.AsObject, AInstance.TypeInfo);
    tkRecord:
      Serialize(Writer, Key, aInstance.GetReferenceToRawData, aInstance.TypeInfo);
    tkArray, tkDynArray:
      begin
        Writer.BeginData(Key, True);
        C := aInstance.GetArrayLength;
        for I := 0 to C-1 do
          Serialize(Writer, '', AInstance.GetArrayElement(I));
        Writer.EndData;
      end;
    tkInteger:
      Writer.WriteInt(Key, AInstance.AsInteger);
    tkInt64:
      Writer.WriteInt64(Key, AInstance.AsInt64);
    tkChar, tkString,tkWChar, tkLString, tkWString, tkUString:
      Writer.WriteString(Key, AInstance.ToString);
    tkEnumeration:
      begin
        if GetTypeData(AInstance.TypeInfo)^.BaseType^ = TypeInfo(Boolean) then
          Writer.WriteBoolean(Key, aInstance.AsBoolean)
        else if JsonRttiEnumAsInt then
          Writer.WriteInt(Key, aInstance.AsOrdinal)
        else
          Writer.WriteString(Key, aInstance.ToString)
      end;
    tkSet:
      if JsonRttiEnumAsInt then
        Writer.WriteInt(Key, aInstance.AsInteger)
      else
        Writer.WriteString(Key, aInstance.ToString);
    tkVariant:
      Writer.WriteInt(Key, aInstance.AsVariant);
  end;
end;
{$ENDIF}

{$IFDEF USEDataSet}
class procedure TYxdSerialize.Serialize(Writer: TSerializeWriter; const Key: string;
  ADataSet: TDataSet; const PageIndex, PageSize: Integer; Base64Blob: Boolean);
var
  BlobStream: TMemoryStream;

  procedure WriteBold(Writer: TSerializeWriter; Field: TField);
  begin
    if not Assigned(BlobStream) then
      BlobStream := TMemoryStream.Create
    else
      BlobStream.Position := 0;
    TBlobField(Field).SaveToStream(BlobStream);
    WriteBlobStream(Writer, BlobStream, BlobStream.Position, Base64Blob);
  end;

  procedure AddDataSetRow(Writer: TSerializeWriter; DS: TDataSet);
  var
    I: Integer;
    Field: TField;
  begin
    for I := 0 to DS.Fields.Count - 1 do begin
      Field := DS.Fields[I];
      // �ж��ֶ��Ƿ���Ҫ����
      if Field.IsNull then begin
        if Field.IsBlob then
          WriteBold(Writer, Field)
        else
          Writer.Add(null)
      end else begin
        case Field.DataType of
          ftBoolean:
            Writer.Add(Field.AsBoolean);
          ftDate, ftTime, ftDateTime, ftTimeStamp{$IFDEF USE_UNICODE}, ftTimeStampOffset{$ENDIF}:
            Writer.AddTime(Field.AsDateTime);
          ftInteger, ftWord, ftSmallint{$IFDEF USE_UNICODE}, ftShortint{$ENDIF}:
            Writer.Add(Field.AsInteger);
          ftLargeint, ftAutoInc:
            Writer.Add({$IFDEF USE_UNICODE}Field.AsLargeInt{$ELSE}Field.AsInteger{$ENDIF});
          ftFloat, ftBCD: // ftSingle
            Writer.Add(Field.AsFloat);
          ftCurrency:
            Writer.Add(Field.AsCurrency);
          ftString, ftWideString, ftGuid:
            Writer.Add(Field.AsString);
          ftBlob, ftGraphic, ftMemo, ftTypedBinary:
            begin
              WriteBold(Writer, Field);
            end;
        else
          Writer.Add(Field.AsString);
        end;
      end;
    end;
  end;

  procedure AddDataSetMeta(Writer: TSerializeWriter; Field: TField);
  begin
    Writer.Add(Field.FieldName);
    if Field.DataType = ftAutoInc then
      Writer.Add(Ord(ftLargeint))
    else
      Writer.Add(Ord(Field.DataType));
    Writer.Add(Field.Size);
    Writer.Add(Field.Required);
    Writer.Add(Field.DisplayLabel);
  end;

  procedure AddDataSet(Writer: TSerializeWriter; DS: TDataSet);
  var
    I: Integer;
    Field: TField;
    MoveIndex, StepIndex: Integer;
  begin
    Writer.BeginData('meta', True);
    for I := 0 to DS.Fields.Count - 1 do begin
      Field := DS.Fields[I];
      Writer.BeginData('', True);
      AddDataSetMeta(Writer, Field);
      Writer.EndData;
    end;
    Writer.EndData;

    BlobStream := nil;
    DS.DisableControls;
    try
      DS.First;
      // ��ҳ�ƶ���¼
      if (PageIndex > 0) and (PageSize > 0) then begin
        MoveIndex := (PageIndex - 1) * PageSize;
        DS.MoveBy(MoveIndex);
      end;
      StepIndex := 0;
      Writer.BeginData('data', True);
      while not DS.Eof do begin
        Writer.BeginData('', True);
        AddDataSetRow(Writer, DS);
        if (PageSize > 0) then begin
          Inc(StepIndex);
          if StepIndex >= PageSize then
            Break;
        end;
        Writer.EndData;
        DS.Next;
      end;
      Writer.EndData;
    finally
      DS.EnableControls;
      if Assigned(BlobStream) then
        BlobStream.Free;
    end;
  end;

begin
  Writer.BeginData(Key, False);
  AddDataSet(Writer, ADataSet);
  Writer.EndData;
end;
{$ENDIF}

class procedure TYxdSerialize.LoadCollection(aIn: JSONBase; ACollection: TCollection);
var
  I: Integer;
  {$IFNDEF USE_UNICODE}
  Item: TCollectionItem;
  {$ENDIF}
begin
  if not Assigned(aIn) then Exit;  
  for I := 0 to aIn.Count - 1 do begin
    {$IFDEF USE_UNICODE}
    readValue(aIn, ACollection.Add);
    {$ELSE}
    Item := ACollection.Add;
    readValue(aIn, Item, GetObjectTypeInfo(Item));
    {$ENDIF}
  end;
end;

class function TYxdSerialize.BlobStreamToString(Data: TStream; Base64Blob: Boolean): JSONString;
var
  M: TMemoryStream;
begin
  if Assigned(Data) then begin
    if (Data is TMemoryStream) then
      Result := BlobStreamToString(TMemoryStream(Data).Memory, Data.Size, Base64Blob)
    else begin
      M := TMemoryStream.Create;
      try
        M.LoadFromStream(Data);
        Result := BlobStreamToString(M.Memory, M.Size, Base64Blob);
      finally
        M.Free;
      end;
    end;
  end else
    Result := '';
end;

class function TYxdSerialize.BlobStreamToString(const Data: TBytes;
  Base64Blob: Boolean): JSONString;
begin
  if Length(Data) > 0 then begin
    Result := BlobStreamToString(@Data[0], Length(Data), Base64Blob)
  end else
    Result := '';
end;

class function TYxdSerialize.BlobStringToStream(Data: Pointer; Size: Integer): TMemoryStream;
var
  I: Integer;
  {$IFDEF USE_UNICODE}
  BSStream: TPointerStream;
  {$ENDIF}
  p: {$IFDEF USE_UNICODE}PByte{$ELSE}PAnsiChar{$ENDIF};
  {$IFNDEF USE_UNICODE}
  BStmp: JSONString;
  {$ENDIF}
  Buf: TBytes;
begin
  Result := nil;
  P := Data;
  I := Size - 1;
  {$IFDEF USE_UNICODE}
  Inc(P, CSBlobsLen shl 1);
  if (I >= (CSBlobsLen + CSBlobBase64Len) shl 1) and
    (PInt64(p)^ = PInt64(CSBlobBase64)^) then
  begin
    Inc(p, CSBlobBase64Len shl 1);
    BSStream := TPointerStream.Create;
    BSStream.SetPointer(p, I-((CSBlobsLen shl 1)+1)-8);
    BSStream.Position := 0;
    Result := TMemoryStream.Create;
    try
      DecodeStream(BSStream, Result);
    finally
      BSStream.Free;
    end;
  end else begin
    {$IFDEF USEYxdStr}YxdStr{$ELSE}YxdJson{$ENDIF}.HexToBin(Pointer(p),
      (I-(CSBlobsLen shl 1)-1) shr 1, Buf);
    if Length(Buf) > 0 then begin
      Result := TMemoryStream.Create;
      Result.WriteBuffer(Buf[0], Length(Buf));
    end;
  end;
  {$ELSE}
  Inc(p, CSBlobsLen);
  if (I >= (CSBlobsLen + CSBlobBase64Len)) and (PDWORD(p)^ = PDWORD(CSBlobBase64)^) then begin
    Inc(p, CSBlobBase64Len);
    BStmp := Base64Decode(p^, I-CSBlobsLen-CSBlobBase64Len);
    Result := TMemoryStream.Create;
    Result.WriteBuffer(BSTmp[1], Length(BStmp));
  end else begin
    {$IFDEF USEYxdStr}YxdStr{$ELSE}YxdJson{$ENDIF}.HexToBin(p, Size-CSBlobsLen, Buf);
    if Length(Buf) > 0 then begin
      Result := TMemoryStream.Create;
      Result.WriteBuffer(Buf[0], Length(Buf));
    end;
  end;
  {$ENDIF}
end;

class function TYxdSerialize.BlobStreamToString(const Data: Pointer;
  const Size: Int64; Base64Blob: Boolean): JSONString;
begin
  {$IFDEF USE_UNICODE}
  if Base64Blob then begin
    Result := CSBlobs + CSBlobBase64 + JSONString(EncodeBase64(Data, Size)) + '>';
  end else
    Result := (CSBlobs + {$IFDEF USEYxdStr}YxdStr{$ELSE}YxdJson{$ENDIF}.BinToHex(Data, Size) + '>');
  {$ELSE}
  if Base64Blob then
    Result := (CSBlobs + CSBlobBase64 + Base64Encode(Data^, Size) + '>')
  else begin
    Result := (CSBlobs + {$IFDEF USEYxdStr}YxdStr{$ELSE}YxdJson{$ENDIF}.BinToHex(Data, Size) + '>');
  end;
  {$ENDIF}
end;

class procedure TYxdSerialize.WriteBlobStream(Writer: TSerializeWriter; const Data: Pointer; const Size: Int64; Base64Blob: Boolean);
begin
  Writer.Add(BlobStreamToString(Data, Size, Base64Blob));
end;

{$IFDEF USEDataSet}
class function TYxdSerialize.ReadDataSet(AIn: JSONBase; ADest: TDataSet): Integer;
var
  BlobStream: TStream;
  {$IFDEF USE_UNICODE} BSStream: TPointerStream;{$ENDIF}

  function GetBlodValue(Field: TField; Item: PJSONValue; var Buf: TBytes): Integer;
  var
    I: Integer;
    p: {$IFDEF USE_UNICODE}PByte{$ELSE}PAnsiChar{$ENDIF};
    {$IFNDEF USE_UNICODE}BStmp: JSONString;{$ELSE}BStmp: TMemoryStream;{$ENDIF}
  begin
    Result := 0;
    I := High(Item.FValue);
    if I > -1 then begin
      p := @Item.FValue[0];
      {$IFDEF USE_UNICODE}
      if IsBlob(Pointer(p), I) then begin
        Inc(p, CSBlobsLen shl 1);
        if (I >= (CSBlobsLen + CSBlobBase64Len) shl 1) and
          (PInt64(p)^ = PInt64(CSBlobBase64)^) then begin
          Inc(p, CSBlobBase64Len shl 1);
          if not Assigned(BSStream) then
            BSStream := TPointerStream.Create;
          BSStream.SetPointer(p, I-((CSBlobsLen shl 1)+1)-8);
          BSStream.Position := 0;
          BStmp := TMemoryStream.Create;
          try
            DecodeStream(BSStream, BStmp);
            if Assigned(BlobStream) then
              BlobStream.Free;
            BlobStream := ADest.CreateBlobStream(Field, bmWrite);
            BlobStream.Write(BSTmp.Memory^, BSTmp.Size);
            BlobStream.Free;
            BlobStream := nil;
          finally
            BStmp.Free;
          end;
          Result := 2;
        end else begin
          {$IFDEF USEYxdStr}YxdStr{$ELSE}YxdJson{$ENDIF}.HexToBin(Pointer(p),
            (I-(CSBlobsLen shl 1)-1) shr 1, Buf);
          Result := 1;
        end;
      {$ELSE}
      if IsBlob(p, I) then begin
        Inc(p, CSBlobsLen);
        if (I >= (CSBlobsLen + CSBlobBase64Len)) and (PDWORD(p)^ = PDWORD(CSBlobBase64)^) then begin
          Inc(p, CSBlobBase64Len);
          BStmp := Base64Decode(p^, I-CSBlobsLen-CSBlobBase64Len);
          if Assigned(BlobStream) then
            BlobStream.Free;
          BlobStream := ADest.CreateBlobStream(Field, bmWrite);
          BlobStream.Size := 0;
          if Length(BSTmp) > 0 then
            BlobStream.WriteBuffer(BSTmp[1], Length(BStmp));
          BlobStream.Free;
          BlobStream := nil;
          Result := 2;
        end else begin
          {$IFDEF USEYxdStr}YxdStr{$ELSE}YxdJson{$ENDIF}.HexToBin(p, High(Item.FValue)-CSBlobsLen, Buf);
          Result := 1;
        end;
      {$ENDIF}
      end;
    end;
  end;

  procedure AddObjectMeta(Item: PJSONValue);
  begin
    case Item.FType of
      jdtString:
        begin
          if (Item.Size > 0) and IsBlob(@Item.FValue[0], High(Item.FValue)) then
            ADest.FieldDefs.Add(Item.FName, ftBlob, 20)
          else
            ADest.FieldDefs.Add(Item.FName, ftString, 30);
        end;
      jdtInteger:
        ADest.FieldDefs.Add(Item.FName, ftInteger);
      jdtFloat:
        ADest.FieldDefs.Add(Item.FName, ftFloat);
      jdtBoolean:
        ADest.FieldDefs.Add(Item.FName, ftBoolean);
      jdtDateTime:
        ADest.FieldDefs.Add(Item.FName, ftDateTime);
      jdtNull: ;
    else
      ADest.FieldDefs.Add(Item.FName, ftVariant);
    end;
  end;

  procedure AddItem(Field: TField; DataType: TFieldType; Item: PJSONValue);
  var
    Buf: TBytes;
  begin
    if Item.FType = jdtNull then begin
      Field.Value := NULL;
      Exit;
    end;
    case DataType of
      ftDate, ftTime, ftDateTime, ftTimeStamp{$IFDEF USE_UNICODE}, ftTimeStampOffset{$ENDIF}:
        Field.Value := Item.TryAsDatetime;
      ftBlob, ftGraphic, ftMemo, ftTypedBinary:
        begin
          case GetBlodValue(Field, Item, Buf) of
            0: Field.Value := Item.GetString;
            1:
              begin
                if Assigned(BlobStream) then
                  BlobStream.Free;
                BlobStream := ADest.CreateBlobStream(Field, bmWrite);
                BlobStream.Position := 0;
                BlobStream.WriteBuffer(Buf[0], Length(Buf));
                BlobStream.Free;
                BlobStream := nil;
              end;
          end;
        end
      else case Item.FType of
        jdtBoolean:
          Field.Value := Item.AsBoolean;
        jdtInteger:
          Field.Value := Item.AsInteger;
        jdtFloat:
          Field.Value := Item.AsFloat;
        jdtDateTime:
          Field.Value := Item.TryAsDatetime;
        jdtString:
          begin
            case GetBlodValue(Field, Item, Buf) of
              0: Field.Value := Item.GetString;
              1: Field.Value := Buf;
            end;
          end;
      end;
    end;
  end;

var
  FldName: string;
  Meta, MetaItem, Data: JSONArray;
  Item, ItemChild: PJSONValue;
  ItemObject: JSONBase;
  Field: TField;
  I, J: Integer;
begin
  Result := -1;
  if (not Assigned(aDest)) or (not Assigned(AIn)) then Exit;
  ADest.DisableControls;
  ADest.FieldDefs.DataSet.Close;
  ADest.FieldDefs.Clear;

  if (AIn.IsJSONArray) then begin
    Meta := nil;
    Data := JSONArray(aIn);
  end else begin
    Meta := JSONObject(AIn).GetJsonArray('meta');
    Data := JSONObject(AIn).GetJsonArray('data');
    if not Assigned(Data) then
      Data := JSONObject(AIn).GetJsonArray('rows');
  end;
  
  Result := 0;
  BlobStream := nil;
  {$IFDEF USE_UNICODE}BSStream := nil;{$ENDIF}
  if (not Assigned(Meta)) and (not Assigned(Data)) then Exit;
  try
    if (not Assigned(Meta)) then begin // û��Meta���ݣ��������ֶ��л�ȡ
      ItemObject := Data.GetJsonObject(0);
      if not Assigned(ItemObject) then
        Exit;
      for J := 0 To ItemObject.Count - 1 do begin
        Item := ItemObject[J];
        if Item.FType = jdtNull then begin
          if Length(Item.FName) > 0 then  // ����һ����¼�в���
            for i := 1 to Data.Count - 1 do begin
              ItemObject := Data.GetJsonObject(I);
              if (ItemObject = nil) then Continue;
              ItemChild := JSONObject(ItemObject).GetItem(Item.FName);
              if (ItemChild = nil) or (ItemChild.FType = jdtNull) then Continue;
              AddObjectMeta(ItemChild);
              Break;
            end;
        end else
          AddObjectMeta(Item);
      end;
    end else begin
      for I := 0 to Meta.Count - 1 do begin
        MetaItem := Meta[I].AsJsonArray;
        if MetaItem = nil then Continue;
        ADest.FieldDefs.Add(
          MetaItem.Items[0].GetString,
          TFieldType(MetaItem.Items[1].AsInteger),
          MetaItem.Items[2].AsInteger,
          MetaItem.Items[3].AsBoolean);
      end;
    end;

    if not ADest.Active then begin
      if (ADest is TClientDataSet) or (ADest.ClassName = 'TClientDataSet') then begin
        TClientDataSet(ADest).CreateDataSet;
      end else
        ADest.Open;
    end; 
    
    try
      for J := 0 To Data.Count - 1 do begin
        Item := Data[J];
        ItemObject := Item.GetObject;
        if ItemObject = nil then Continue;
        // ����ģʽ
        if ItemObject.IsJSONArray then begin
          ADest.Append;
          for I := 0 to ItemObject.Count - 1 do begin
            FldName := ADest.Fields[i].FieldName;
            AddItem(ADest.Fields[i], ADest.FieldDefs.Items[i].DataType, ItemObject.Items[i]);
          end;
          ADest.Post;
        end else begin  // ����ģʽ
          ADest.Append;
          for I := 0 To ItemObject.Count - 1 do begin 
            ItemChild := ItemObject[I];
            Field := ADest.FindField(ItemChild.FName);
            if not Assigned(Field) then
              Continue;
            FldName := ItemChild.FName;
            AddItem(Field, ADest.FieldDefs.Items[Field.Index].DataType, ItemChild); 
          end;
          ADest.Post;
        end;
      end;
    except
      raise Exception.CreateFmt('json���ֶ�(%s)��ֵ�����ݼ������쳣��', [FldName]);
    end;
  finally
    if ADest.Active then
      ADest.First;
    ADest.EnableControls;
    if Assigned(BlobStream) then
      BlobStream.Free;
    {$IFDEF USE_UNICODE}
    if Assigned(BSStream) then
      BSStream.Free;
    {$ENDIF}
  end;
  Result := ADest.RecordCount;
end;
{$ENDIF}

class procedure TYxdSerialize.readObject(aIn: JSONBase; aDest: TObject);
begin
  if not Assigned(aDest) then Exit;
  {$IFDEF USE_UNICODE}
  readValue(aIn, aDest);
  {$ELSE}
  readValue(aIn, aDest, GetObjectTypeInfo(aDest));
  {$ENDIF}
end;

{$IFDEF USE_UNICODE}
class procedure TYxdSerialize.readRecord<T>(aIn: JSONBase; out aInstance: T);
begin
  readValue(aIn, @aInstance, TypeInfo(T));
end;
{$ENDIF}

{$IFDEF USE_UNICODE} {$IFDEF USEDataSet}
class procedure TYxdSerialize.readRecord<T>(aIn: TDataSet; out aInstance: T);
begin
  readValue(aIn, @aInstance, TypeInfo(T));
end;
{$ENDIF}{$ENDIF}

{$IFDEF USE_UNICODE}
class procedure TYxdSerialize.readValue(aIn: JSONBase; aInstance: TValue);
begin
  if aInstance.IsEmpty then
    Exit;
  if aInstance.Kind = tkRecord then
    readValue(aIn, aInstance.GetReferenceToRawData, aInstance.TypeInfo)
  else if aInstance.Kind = tkClass then
    readValue(aIn, aInstance.AsObject, aInstance.TypeInfo);
end;
{$ENDIF}

{$IFDEF USE_UNICODE} {$IFDEF USEDataSet}
class procedure TYxdSerialize.readValue(aIn: TDataSet; aInstance: TValue);
begin
  if aInstance.IsEmpty then
    Exit;
  if aInstance.Kind = tkRecord then
    readValue(aIn, aInstance.GetReferenceToRawData, aInstance.TypeInfo)
  else if aInstance.Kind = tkClass then
    readValue(aIn, aInstance.AsObject, aInstance.TypeInfo);
end;
{$ENDIF}{$ENDIF}

{$IFDEF USEDataSet}
class procedure TYxdSerialize.ReadValue(AIn: TDataSet; ADest: Pointer;
  aType: PTypeInfo);

  function StrToDateTimeDef(const V: string; const DefaultValue: TDateTime): TDateTime;
  begin
    if not(ParseDateTime(PJSONChar(V), Result) or
      ParseJsonTime(PJSONChar(V), Result) or ParseWebTime(PJSONChar(V), Result)) then
      Result := DefaultValue;
  end;

  {$IFDEF USE_UNICODE}
  procedure ToRecord;
  var
    AContext: TRttiContext;
    AFieldItem: TRttiField;
    AFields: TArray<TRttiField>;
    ARttiType: TRttiType;
    ABaseAddr: Pointer;
    AFieldName: string;
    AFieldAttrItem: TCustomAttribute;
    AChild: TField;
    J: Integer;
  begin
    AContext := TRttiContext.Create;
    ARttiType := AContext.GetType(AType);
    ABaseAddr := ADest;
    AFields := ARttiType.GetFields;
    for J := Low(AFields) to High(AFields) do begin
      AFieldItem := AFields[J];
      if AFieldItem.FieldType <> nil then begin
        AFieldName := AFieldItem.Name;
        if AFieldItem.GetAttributes <> nil then begin
          for AFieldAttrItem in AFieldItem.GetAttributes do             
            if AFieldAttrItem is FieldNameAttribute then begin
              AFieldName := FieldNameAttribute(AFieldAttrItem).Name;
              Break;
            end;                 
        end;

        AChild := AIn.FindField(AFieldName);
        if AChild = nil then begin
          case AFieldItem.FieldType.TypeKind of
            tkInteger, tkFloat, tkInt64:
              AFieldItem.SetValue(ABaseAddr, 0);
            {$IFNDEF NEXTGEN}
            tkString:
              PShortString(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := '';
            {$ENDIF !NEXTGEN}
            tkUString{$IFNDEF NEXTGEN},tkLString,tkWString{$ENDIF !NEXTGEN}:
              AFieldItem.SetValue(ABaseAddr, '');
            tkEnumeration:
              AFieldItem.SetValue(ABaseAddr, 0);
            tkSet:
              begin
                case GetTypeData(AFieldItem.FieldType.Handle).OrdType of
                  otSByte: PShortint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := 0;
                  otUByte: PByte(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := 0;
                  otSWord: PSmallint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := 0;
                  otUWord: PWord(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := 0;
                  otSLong: PInteger(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := 0;
                  otULong: PCardinal(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := 0;
                end;
              end;
            tkChar, tkWChar:
              AFieldItem.SetValue(ABaseAddr, '');
            tkVariant:
              PVariant(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := NULL;
          end;
        end else begin
          case AFieldItem.FieldType.TypeKind of
            tkInteger:
              begin
                if AChild.DataType in [ftString, ftWideString] then
                  AFieldItem.SetValue(ABaseAddr, StrToIntDef(AChild.AsString, 0))
                else
                  AFieldItem.SetValue(ABaseAddr, AChild.AsInteger);
              end;
            {$IFNDEF NEXTGEN}
            tkString:
              PShortString(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := ShortString(AChild.AsString);
            {$ENDIF !NEXTGEN}
            tkUString{$IFNDEF NEXTGEN},tkLString,tkWString{$ENDIF !NEXTGEN}:
              AFieldItem.SetValue(ABaseAddr, AChild.AsString);
            tkEnumeration:
              begin
                if GetTypeData(AFieldItem.FieldType.Handle)^.BaseType^ = TypeInfo(Boolean) then
                  AFieldItem.SetValue(ABaseAddr, AChild.AsBoolean)
                else begin
                  case GetTypeData(AFieldItem.FieldType.Handle).OrdType of
                    otSByte:
                      begin
                        if AChild.DataType = ftInteger then
                          PShortint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                        else
                          PShortint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := GetEnumValue(AFieldItem.FieldType.Handle, AChild.AsString);
                      end;
                    otUByte:
                      begin
                        if AChild.DataType = ftInteger then
                          PByte(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                        else
                          PByte(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := GetEnumValue(AFieldItem.FieldType.Handle, AChild.AsString);
                      end;
                    otSWord:
                      begin
                        if AChild.DataType = ftInteger then
                          PSmallint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                        else
                          PSmallint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := GetEnumValue(AFieldItem.FieldType.Handle, AChild.AsString);
                      end;
                    otUWord:
                      begin
                        if AChild.DataType = ftInteger then
                          PWord(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                        else
                          PWord(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := GetEnumValue(AFieldItem.FieldType.Handle, AChild.AsString);
                      end;
                    otSLong:
                      begin
                        if AChild.DataType = ftInteger then
                          PInteger(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                        else
                          PInteger(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := GetEnumValue(AFieldItem.FieldType.Handle, AChild.AsString);
                      end;
                    otULong:
                      begin
                        if AChild.DataType = ftInteger then
                          PCardinal(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                        else
                          PCardinal(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := GetEnumValue(AFieldItem.FieldType.Handle, AChild.AsString);
                      end;
                  end;
                end;
              end;
            tkSet:
              begin
                case GetTypeData(AFieldItem.FieldType.Handle).OrdType of
                  otSByte:
                    begin
                      if AChild.DataType = ftInteger then
                        PShortint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                      else
                        PShortint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := StringToSet(AFieldItem.FieldType.Handle, AChild.AsString);
                    end;
                  otUByte:
                    begin
                      if AChild.DataType = ftInteger then
                        PByte(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                      else
                        PByte(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := StringToSet(AFieldItem.FieldType.Handle, AChild.AsString);
                    end;
                  otSWord:
                    begin
                      if AChild.DataType = ftInteger then
                        PSmallint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                      else
                        PSmallint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := StringToSet(AFieldItem.FieldType.Handle, AChild.AsString);
                    end;
                  otUWord:
                    begin
                      if AChild.DataType = ftInteger then
                        PWord(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                      else
                        PWord(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := StringToSet(AFieldItem.FieldType.Handle, AChild.AsString);
                    end;
                  otSLong:
                    begin
                      if AChild.DataType = ftInteger then
                        PInteger(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                      else
                        PInteger(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := StringToSet(AFieldItem.FieldType.Handle, AChild.AsString);
                    end;
                  otULong:
                    begin
                      if AChild.DataType = ftInteger then
                        PCardinal(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                      else
                        PCardinal(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := StringToSet(AFieldItem.FieldType.Handle, AChild.AsString);
                    end;
                end;
              end;
            tkChar, tkWChar:
              AFieldItem.SetValue(ABaseAddr, AChild.AsString);
            tkFloat:
              if (AFieldItem.FieldType.Handle = TypeInfo(TDateTime)) or
                (AFieldItem.FieldType.Handle = TypeInfo(TTime)) or
                (AFieldItem.FieldType.Handle = TypeInfo(TDate))
              then begin
                if AChild.DataType in [ftString, ftWideString] then begin
                  AFieldItem.SetValue(ABaseAddr, StrToDateTimeDef(AChild.AsString, 0))
                end else
                  AFieldItem.SetValue(ABaseAddr, AChild.AsDateTime)
              end else
                AFieldItem.SetValue(ABaseAddr, AChild.AsFloat);
            tkInt64:
              begin
                if AChild.DataType in [ftString, ftWideString] then
                  AFieldItem.SetValue(ABaseAddr, StrToIntDef(AChild.AsString, 0))
                else
                  AFieldItem.SetValue(ABaseAddr, AChild.AsLargeInt);
              end;
            tkVariant:
              PVariant(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsVariant;
          end;
        end;
      end;
    end;
  end;
  {$ENDIF}

  procedure ToObject;
  var
    AProp: PPropInfo;
    AObj: TObject;
    AChild: TField;
    J: Integer;
  begin
    AObj := aDest;
    for J := 0 to aIn.FieldCount - 1 do begin
      AChild := aIn.Fields.Fields[J];
      AProp := GetPropInfo(AObj, AChild.Name);
      if AProp <> nil then begin
        case AProp.PropType^.Kind of
          tkInteger:
            SetOrdProp(AObj, AProp, AChild.AsInteger);
          tkChar,tkString,tkWChar, tkLString, tkWString{$IFDEF USE_UNICODE}, tkUString{$ENDIF}:
            SetStrProp(AObj, AProp, AChild.AsString);
          tkEnumeration:
            begin
              if GetTypeData(AProp.PropType^)^.BaseType^ = TypeInfo(Boolean) then
                SetOrdProp(AObj, AProp, Integer(AChild.AsBoolean))
              else if AChild.DataType = ftInteger then
                SetOrdProp(AObj, AProp, AChild.AsInteger)
              else
                SetEnumProp(AObj, AProp, AChild.AsString);
            end;
          tkSet:
            begin
              if AChild.DataType = ftInteger then
                SetOrdProp(AObj, AProp, AChild.AsInteger)
              else
                SetSetProp(AObj, AProp, AChild.AsString);
            end;
          tkFloat:
            SetFloatProp(AObj, AProp, AChild.AsFloat);
          {$IFDEF USE_UNICODE}
          tkInt64:
            SetInt64Prop(AObj, AProp, AChild.AsLargeInt);
          {$ENDIF}
          tkVariant:
            SetVariantProp(AObj, AProp, AChild.AsVariant);
        end;
      end;
    end;
  end;

begin
  if (aDest <> nil) and (Assigned(aIn)) then begin
    {$IFDEF USE_UNICODE}
    if aType.Kind = tkRecord then
      ToRecord
    else if aType.Kind = tkClass then
      ToObject
    {$ELSE}
    if aType.Kind = tkClass then
      ToObject
    {$ENDIF}
    else
      raise Exception.Create(SUnsupportPropertyType);
  end;
end; 
{$ENDIF}

class procedure TYxdSerialize.readValue(aIn: JSONBase; aDest: Pointer;
  aType: PTypeInfo);

  procedure LoadClass(AObj: TObject; AChild: PJSONValue);
  begin
    if AObj is TStrings then
      (AObj as TStrings).Text := AChild.AsString
    else if AObj is TCollection then
      LoadCollection(AChild.AsJsonArray, AObj as TCollection)
    else if AObj <> nil then
      readValue(AChild.AsJsonObject, AObj{$IFNDEF USE_UNICODE}, GetObjectTypeInfo(AObj){$ENDIF});
  end;

  {$IFDEF USE_UNICODE}
  procedure ToRecord;
  var
    AContext: TRttiContext;
    AFieldItem: TRttiField;
    AFields: TArray<TRttiField>;
    ARttiType: TRttiType;
    ABaseAddr: Pointer;
    AChild: PJSONValue;
    J: Integer;
    AFieldAttrItem: TCustomAttribute;
    AFieldName: string;
  begin
    AContext := TRttiContext.Create;
    ARttiType := AContext.GetType(AType);
    ABaseAddr := ADest;
    AFields := ARttiType.GetFields;
    for J := Low(AFields) to High(AFields) do begin
      AFieldItem := AFields[J];
      if AFieldItem.FieldType <> nil then begin
        if aIn.IsJSONArray then
          AChild := JSONArray(aIn).Items[J]
        else begin
          AFieldName := AFieldItem.Name;
          if AFieldItem.GetAttributes <> nil then begin
            for AFieldAttrItem in AFieldItem.GetAttributes do
              if AFieldAttrItem is FieldNameAttribute then begin
                AFieldName := FieldNameAttribute(AFieldAttrItem).Name;
                Break;
              end;
          end;
          AChild := JSONObject(aIn).getItem(AFieldName);
        end;
        if AChild = nil then begin
          case AFieldItem.FieldType.TypeKind of
            tkInteger, tkFloat, tkInt64:
              AFieldItem.SetValue(ABaseAddr, 0);
            {$IFNDEF NEXTGEN}
            tkString:
              PShortString(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := '';
            {$ENDIF !NEXTGEN}
            tkUString{$IFNDEF NEXTGEN},tkLString,tkWString{$ENDIF !NEXTGEN}:
              AFieldItem.SetValue(ABaseAddr, '');
            tkEnumeration:
              AFieldItem.SetValue(ABaseAddr, 0);
            tkSet:
              begin
                case GetTypeData(AFieldItem.FieldType.Handle).OrdType of
                  otSByte: PShortint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := 0;
                  otUByte: PByte(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := 0;
                  otSWord: PSmallint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := 0;
                  otUWord: PWord(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := 0;
                  otSLong: PInteger(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := 0;
                  otULong: PCardinal(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := 0;
                end;
              end;
            tkChar, tkWChar:
              AFieldItem.SetValue(ABaseAddr, '');
            tkVariant:
              PVariant(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := NULL;
          end;
        end else begin
          case AFieldItem.FieldType.TypeKind of
            tkInteger:
              AFieldItem.SetValue(ABaseAddr, AChild.AsInteger);
            {$IFNDEF NEXTGEN}
            tkString:
              PShortString(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := ShortString(AChild.AsString);
            {$ENDIF !NEXTGEN}
            tkUString{$IFNDEF NEXTGEN},tkLString,tkWString{$ENDIF !NEXTGEN}:
              AFieldItem.SetValue(ABaseAddr, AChild.AsString);
            tkEnumeration:
              begin
                if GetTypeData(AFieldItem.FieldType.Handle)^.BaseType^ = TypeInfo(Boolean) then
                  AFieldItem.SetValue(ABaseAddr, AChild.AsBoolean)
                else begin
                  case GetTypeData(AFieldItem.FieldType.Handle).OrdType of
                    otSByte:
                      begin
                        if AChild.FType = jdtInteger then
                          PShortint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                        else
                          PShortint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := GetEnumValue(AFieldItem.FieldType.Handle, AChild.AsString);
                      end;
                    otUByte:
                      begin
                        if AChild.FType = jdtInteger then
                          PByte(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                        else
                          PByte(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := GetEnumValue(AFieldItem.FieldType.Handle, AChild.AsString);
                      end;
                    otSWord:
                      begin
                        if AChild.FType = jdtInteger then
                          PSmallint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                        else
                          PSmallint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := GetEnumValue(AFieldItem.FieldType.Handle, AChild.AsString);
                      end;
                    otUWord:
                      begin
                        if AChild.FType = jdtInteger then
                          PWord(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                        else
                          PWord(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := GetEnumValue(AFieldItem.FieldType.Handle, AChild.AsString);
                      end;
                    otSLong:
                      begin
                        if AChild.FType = jdtInteger then
                          PInteger(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                        else
                          PInteger(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := GetEnumValue(AFieldItem.FieldType.Handle, AChild.AsString);
                      end;
                    otULong:
                      begin
                        if AChild.FType = jdtInteger then
                          PCardinal(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                        else
                          PCardinal(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := GetEnumValue(AFieldItem.FieldType.Handle, AChild.AsString);
                      end;
                  end;
                end;
              end;
            tkSet:
              begin
                case GetTypeData(AFieldItem.FieldType.Handle).OrdType of
                  otSByte:
                    begin
                      if AChild.FType = jdtInteger then
                        PShortint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                      else
                        PShortint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := StringToSet(AFieldItem.FieldType.Handle, AChild.AsString);
                    end;
                  otUByte:
                    begin
                      if AChild.FType = jdtInteger then
                        PByte(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                      else
                        PByte(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := StringToSet(AFieldItem.FieldType.Handle, AChild.AsString);
                    end;
                  otSWord:
                    begin
                      if AChild.FType = jdtInteger then
                        PSmallint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                      else
                        PSmallint(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := StringToSet(AFieldItem.FieldType.Handle, AChild.AsString);
                    end;
                  otUWord:
                    begin
                      if AChild.FType = jdtInteger then
                        PWord(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                      else
                        PWord(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := StringToSet(AFieldItem.FieldType.Handle, AChild.AsString);
                    end;
                  otSLong:
                    begin
                      if AChild.FType = jdtInteger then
                        PInteger(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                      else
                        PInteger(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := StringToSet(AFieldItem.FieldType.Handle, AChild.AsString);
                    end;
                  otULong:
                    begin
                      if AChild.FType = jdtInteger then
                        PCardinal(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsInteger
                      else
                        PCardinal(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := StringToSet(AFieldItem.FieldType.Handle, AChild.AsString);
                    end;
                end;
              end;
            tkChar, tkWChar:
              AFieldItem.SetValue(ABaseAddr, AChild.AsString);
            tkFloat:
              if (AFieldItem.FieldType.Handle = TypeInfo(TDateTime)) or
                (AFieldItem.FieldType.Handle = TypeInfo(TTime)) or
                (AFieldItem.FieldType.Handle = TypeInfo(TDate))
              then
                if AChild.FType in [jdtNull, jdtUnknown] then
                  AFieldItem.SetValue(ABaseAddr, 0)
                else if AChild.FType = jdtInteger then begin
                  case JsonIntToTimeStyle of
                    tsDeny:
                      raise Exception.CreateFmt(SBadConvert, [Achild.AsString, JsonTypeName[Ord(jdtDateTime)]]);
                    tsSecondsFrom1970: //unix
                      begin
                        if (JsonTimeZone >= -12) and (JsonTimeZone <= 12) then
                          AFieldItem.SetValue(ABaseAddr, IncHour(UnixToDateTime(AChild.AsInt64), JsonTimeZone))
                        else
                          AFieldItem.SetValue(ABaseAddr, UnixToDateTime(AChild.AsInt64));
                      end;
                    tsSecondsFrom1899:
                      begin
                        if (JsonTimeZone >= -12) and (JsonTimeZone <= 12) then
                          AFieldItem.SetValue(ABaseAddr, IncHour(AChild.AsInt64 / 86400, JsonTimeZone))
                        else
                          AFieldItem.SetValue(ABaseAddr, AChild.AsInt64 / 86400);
                      end;
                    tsMsFrom1970:
                      begin
                        if (JsonTimeZone >= -12) and (JsonTimeZone <= 12) then
                          AFieldItem.SetValue(ABaseAddr, IncHour(IncMilliSecond(UnixDateDelta, AChild.AsInt64), JsonTimeZone))
                        else
                          AFieldItem.SetValue(ABaseAddr, IncMilliSecond(UnixDateDelta, AChild.AsInt64));
                      end;
                    tsMsFrom1899:
                      begin
                        if (JsonTimeZone >= -12) and (JsonTimeZone <= 12) then
                          AFieldItem.SetValue(ABaseAddr, IncHour(AChild.AsInt64 / 86400000, JsonTimeZone))
                        else
                          AFieldItem.SetValue(ABaseAddr, AChild.AsInt64 / 86400000);
                      end;
                  end;
                end else
                  AFieldItem.SetValue(ABaseAddr, AChild.TryAsDatetime)
              else
                AFieldItem.SetValue(ABaseAddr, AChild.AsFloat);
            tkInt64:
              AFieldItem.SetValue(ABaseAddr, AChild.AsInt64);
           tkVariant:
              PVariant(IntPtr(ABaseAddr)+AFieldItem.Offset)^ := AChild.AsVariant;
           tkArray, tkDynArray:
              readValue(AChild.AsJsonArray, Pointer(IntPtr(ABaseAddr)+AFieldItem.Offset),AFieldItem.FieldType.Handle);
           tkClass:
              LoadClass(AFieldItem.GetValue(ABaseAddr).AsObject, AChild);
           tkRecord:
              readValue(AChild.AsJsonObject, Pointer(IntPtr(ABaseAddr)+AFieldItem.Offset),AFieldItem.FieldType.Handle);
          end;
        end;
      end;
    end;
  end;
  {$ENDIF}
  
  procedure ToObject;
  var
    AProp: PPropInfo;
    AObj, AChildObj: TObject;
    AChild: PJSONValue;
    J: Integer;
  begin
    AObj := aDest;
    for J := 0 to aIn.Count - 1 do begin
      AChild := aIn.Items[J];
      AProp := GetPropInfo(AObj, AChild.FName);
      if AProp <> nil then begin
        case AProp.PropType^.Kind of
          tkClass:
            begin
              AChildObj:=Pointer(GetOrdProp(AObj,AProp));
              if AChildObj is TStrings then
                (AChildObj as TStrings).Text:=AChild.AsString
              else if AChildObj is TCollection then
                LoadCollection(AChild.AsJsonObject, AChildObj as TCollection)
              else
                readValue(AChild.AsJsonObject, AChildObj{$IFNDEF USE_UNICODE}, GetObjectTypeInfo(AChildObj){$ENDIF});
            end;
          tkRecord, tkArray, tkDynArray://tkArray,tkDynArray���͵�����û����,tkRecord����
            readValue(AChild.AsJsonObject, Pointer(GetOrdProp(AObj, AProp)), AProp.PropType^);
          tkInteger:
            SetOrdProp(AObj, AProp, AChild.AsInteger);
          tkChar,tkString,tkWChar, tkLString, tkWString{$IFDEF USE_UNICODE}, tkUString{$ENDIF}:
            SetStrProp(AObj, AProp, AChild.AsString);
          tkEnumeration:
            begin
              if GetTypeData(AProp.PropType^)^.BaseType^ = TypeInfo(Boolean) then
                SetOrdProp(AObj, AProp, Integer(AChild.AsBoolean))
              else if AChild.FType = jdtInteger then
                SetOrdProp(AObj, AProp, AChild.AsInteger)
              else
                SetEnumProp(AObj, AProp, AChild.AsString);
            end;
          tkSet:
            begin
              if AChild.FType = jdtInteger then
                SetOrdProp(AObj, AProp, AChild.AsInteger)
              else
                SetSetProp(AObj, AProp, AChild.AsString);
            end;
          tkVariant:
            SetVariantProp(AObj, AProp, AChild.AsVariant);
          tkInt64:
            SetInt64Prop(AObj, AProp, AChild.AsInt64);
        end;
      end;
    end;
  end;

  procedure SetDynArrayLen(arr:Pointer; AType:PTypeInfo; ALen:NativeInt);
  var
    pmem: Pointer;
  begin
    pmem := PPointer(arr)^;
    DynArraySetLength(pmem, AType, 1, @ALen);
    PPointer(arr)^ := pmem;
  end;

  {$IFDEF USE_UNICODE}
  procedure ToArray;
  var
    AContext: TRttiContext;
    ASubType: TRttiType;
    S: JSONString;
    pd, pi: PByte;
    ASubTypeInfo: PTypeInfo;
    AChild: PJSONValue;
    I, AOffset: Integer;
  begin
    AContext := TRttiContext.Create;
    {$IF RTLVersion>25}
    S := ArrayItemTypeName(AType.NameFld.ToString);
    {$ELSE}
    S := ArrayItemTypeName(string(AType.Name));
    {$IFEND}
    ASubType := AContext.FindType(S);
    ASubTypeInfo := ASubType.Handle;
    if ASubType <> nil then begin
      SetDynArrayLen(ADest, AType, aIn.Count);
      pd := PPointer(ADest)^;
      for I := 0 to aIn.Count - 1 do begin
        AOffset := I * GetTypeData(AType).elSize;
        pi := Pointer(IntPtr(pd)+AOffset);
        AChild := aIn.Items[I];
        case ASubType.TypeKind of
          tkInteger:
            begin
              case GetTypeData(ASubTypeInfo).OrdType of
                otSByte:
                  PShortint(pi)^ := AChild.AsInteger;
                otUByte:
                  pi^ := AChild.AsInteger;
                otSWord:
                  PSmallint(pi)^ := AChild.AsInteger;
                otUWord:
                  PWord(pi)^ := AChild.AsInteger;
                otSLong:
                  PInteger(pi)^ := AChild.AsInteger;
                otULong:
                  PCardinal(pi)^ := AChild.AsInteger;
              end;
            end;
          {$IFNDEF NEXTGEN}
          tkChar:
            pi^ := Ord(PAnsiChar(AnsiString(AChild.AsString))[0]);
          {$ENDIF !NEXTGEN}
          tkEnumeration:
            begin
              if GetTypeData(ASubTypeInfo)^.BaseType^ = TypeInfo(Boolean) then
                PBoolean(pi)^ := AChild.AsBoolean
              else
                begin
                case GetTypeData(ASubTypeInfo)^.OrdType of
                  otSByte:
                    begin
                      if AChild.FType = jdtInteger then
                        PShortint(pi)^ := AChild.AsInteger
                      else
                        PShortint(pi)^ := GetEnumValue(ASubTypeInfo, AChild.AsString);
                    end;
                  otUByte:
                    begin
                      if AChild.FType = jdtInteger then
                        pi^ := AChild.AsInteger
                      else
                        pi^ := GetEnumValue(ASubTypeInfo, AChild.AsString);
                    end;
                  otSWord:
                    begin
                      if AChild.FType = jdtInteger then
                        PSmallint(pi)^ := AChild.AsInteger
                      else
                        PSmallint(pi)^ := GetEnumValue(ASubTypeInfo, AChild.AsString);
                    end;
                  otUWord:
                    begin
                      if AChild.FType = jdtInteger then
                        PWord(pi)^ := AChild.AsInteger
                      else
                        PWord(pi)^ := GetEnumValue(ASubTypeInfo, AChild.AsString);
                    end;
                  otSLong:
                    begin
                      if AChild.FType = jdtInteger then
                        PInteger(pi)^ := AChild.AsInteger
                      else
                        PInteger(pi)^ := GetEnumValue(ASubTypeInfo, AChild.AsString);
                    end;
                  otULong:
                    begin
                      if AChild.FType = jdtInteger then
                        PCardinal(pi)^ := AChild.AsInteger
                      else
                        PCardinal(pi)^ := GetEnumValue(ASubTypeInfo, AChild.AsString);
                    end;
                end;
              end;
            end;
          tkFloat:
            case GetTypeData(ASubTypeInfo)^.FloatType of
              ftSingle:
                PSingle(pi)^ := AChild.AsFloat;
              ftDouble:
                PDouble(pi)^ := AChild.AsFloat;
              ftExtended:
                PExtended(pi)^ := AChild.AsFloat;
              ftComp:
                PComp(pi)^ := AChild.AsFloat;
              ftCurr:
                PCurrency(pi)^ := AChild.AsFloat;
            end;
          {$IFNDEF NEXTGEN}
          tkString:
            PShortString(pi)^:=ShortString(AChild.AsString);
          {$ENDIF !NEXTGEN}
          tkSet:
            begin
              case GetTypeData(ASubTypeInfo)^.OrdType of
                otSByte:
                  begin
                    if AChild.FType = jdtInteger then
                      PShortint(pi)^ := AChild.AsInteger
                    else
                      PShortint(pi)^ := StringToSet(ASubTypeInfo, AChild.AsString);
                  end;
                otUByte:
                  begin
                    if AChild.FType = jdtInteger then
                      pi^ := AChild.AsInteger
                    else
                      pi^ := StringToSet(ASubTypeInfo, AChild.AsString);
                  end;
                otSWord:
                  begin
                    if AChild.FType = jdtInteger then
                      PSmallint(pi)^ := AChild.AsInteger
                    else
                      PSmallint(pi)^ := StringToSet(ASubTypeInfo, AChild.AsString);
                  end;
                otUWord:
                  begin
                    if AChild.FType = jdtInteger then
                      PWord(pi)^ := AChild.AsInteger
                    else
                      PWord(pi)^ := StringToSet(ASubTypeInfo, AChild.AsString);
                  end;
                otSLong:
                  begin
                    if AChild.FType = jdtInteger then
                      PInteger(pi)^ := AChild.AsInteger
                    else
                      PInteger(pi)^ := StringToSet(ASubTypeInfo, AChild.AsString);
                  end;
                otULong:
                  begin
                    if AChild.FType = jdtInteger then
                      PCardinal(pi)^ := AChild.AsInteger
                    else
                      PCardinal(pi)^ := StringToSet(ASubTypeInfo, AChild.AsString);
                  end;
              end;
            end;
          tkClass:
            LoadClass(PPointer(pi)^, AChild);
          tkWChar:
            PWideChar(pi)^ := PWideChar(AChild.AsString)[0];
          {$IFNDEF NEXTGEN}
          tkLString:
            PAnsiString(pi)^ := AnsiString(AChild.AsString);
          tkWString:
            PWideString(pi)^ := AChild.AsString;
          {$ENDIF}
          tkVariant:
            PVariant(pi)^ := AChild.AsVariant;
          tkArray,tkDynArray:
            readValue(AChild.AsJsonObject, pi, ASubTypeInfo);
          tkRecord:
            readValue(AChild.AsJsonObject, pi, ASubTypeInfo);
          tkInt64:
            PInt64(pi)^ := AChild.AsInt64;
          tkUString:
            PUnicodeString(pi)^ := AChild.AsString;
        end;
      end;
    end else
      raise Exception.Create(SArrayTypeMissed);
  end;
  {$ENDIF}

  {$IFDEF USE_UNICODE}
  function GetFixedArrayItemType:PTypeInfo;
  var
    pType: PPTypeInfo;
  begin
    pType := GetTypeData(AType)^.ArrayData.ElType;
    if pType = nil then
      Result := nil
    else
      Result := pType^;
  end;

  procedure ToFixedArray;
  var
    pi: Pointer;
    ASubType: PTypeInfo;
    AChild: PJSONValue;
    I, C, ASize: Integer;
  begin
    C := GetTypeData(AType).ArrayData.ElCount;
    ASubType := GetFixedArrayItemType;
    if ASubType = nil then Exit;
    ASize:=GetTypeData(ASubType).elSize;
    for I := 0 to C-1 do begin
      pi := Pointer(IntPtr(ADest)+ASize*I);
      AChild := aIn.Items[I];
      case ASubType.Kind of
        tkInteger:
          begin
            case GetTypeData(ASubType).OrdType of
              otSByte:
                PShortint(pi)^ := AChild.AsInteger;
              otUByte:
                PByte(pi)^ := AChild.AsInteger;
              otSWord:
                PSmallint(pi)^ := AChild.AsInteger;
              otUWord:
                PWord(pi)^ := AChild.AsInteger;
              otSLong:
                PInteger(pi)^ := AChild.AsInteger;
              otULong:
                PCardinal(pi)^ := AChild.AsInteger;
            end;
          end;
        {$IFNDEF NEXTGEN}
        tkChar:
          PByte(pi)^ := Ord(PAnsiChar(AnsiString(AChild.AsString))[0]);
        {$ENDIF !NEXTGEN}
        tkEnumeration:
          begin
            if GetTypeData(ASubType)^.BaseType^ = TypeInfo(Boolean) then
              PBoolean(pi)^ := AChild.AsBoolean
            else begin
              case GetTypeData(ASubType)^.OrdType of
                otSByte:
                  begin
                    if AChild.FType = jdtInteger then
                      PShortint(pi)^ := AChild.AsInteger
                    else
                      PShortint(pi)^ := GetEnumValue(ASubType, AChild.AsString);
                  end;
                otUByte:
                  begin
                    if AChild.FType = jdtInteger then
                      PByte(pi)^ := AChild.AsInteger
                    else
                      PByte(pi)^ := GetEnumValue(ASubType, AChild.AsString);
                  end;
                otSWord:
                  begin
                    if AChild.FType = jdtInteger then
                      PSmallint(pi)^ := AChild.AsInteger
                    else
                      PSmallint(pi)^ := GetEnumValue(ASubType, AChild.AsString);
                  end;
                otUWord:
                  begin
                    if AChild.FType = jdtInteger then
                      PWord(pi)^ := AChild.AsInteger
                    else
                      PWord(pi)^ := GetEnumValue(ASubType, AChild.AsString);
                  end;
                otSLong:
                  begin
                    if AChild.FType = jdtInteger then
                      PInteger(pi)^ := AChild.AsInteger
                    else
                      PInteger(pi)^ := GetEnumValue(ASubType, AChild.AsString);
                  end;
                otULong:
                  begin
                    if AChild.FType = jdtInteger then
                      PCardinal(pi)^ := AChild.AsInteger
                    else
                      PCardinal(pi)^ := GetEnumValue(ASubType, AChild.AsString);
                  end;
              end;
            end;
          end;
        tkFloat:
          case GetTypeData(ASubType)^.FloatType of
            ftSingle:
              PSingle(pi)^ := AChild.AsFloat;
            ftDouble:
              PDouble(pi)^ := AChild.AsFloat;
            ftExtended:
              PExtended(pi)^ := AChild.AsFloat;
            ftComp:
              PComp(pi)^ := AChild.AsFloat;
            ftCurr:
              PCurrency(pi)^ := AChild.AsFloat;
          end;
        {$IFNDEF NEXTGEN}
        tkString:
          PShortString(pi)^ := ShortString(AChild.AsString);
        {$ENDIF !NEXTGEN}
        tkSet:
          begin
            case GetTypeData(ASubType)^.OrdType of
              otSByte:
                begin
                if AChild.FType = jdtInteger then
                  PShortint(pi)^ := AChild.AsInteger
                else
                  PShortint(pi)^ := StringToSet(ASubType, AChild.AsString);
                end;
              otUByte:
                begin
                  if AChild.FType = jdtInteger then
                    PByte(pi)^ := AChild.AsInteger
                  else
                    PByte(pi)^ := StringToSet(ASubType, AChild.AsString);
                end;
              otSWord:
                begin
                  if AChild.FType = jdtInteger then
                    PSmallint(pi)^ := AChild.AsInteger
                  else
                    PSmallint(pi)^ := StringToSet(ASubType, AChild.AsString);
                end;
              otUWord:
                begin
                  if AChild.FType = jdtInteger then
                    PWord(pi)^ := AChild.AsInteger
                  else
                    PWord(pi)^ := StringToSet(ASubType, AChild.AsString);
                end;
              otSLong:
                begin
                  if AChild.FType = jdtInteger then
                    PInteger(pi)^ := AChild.AsInteger
                  else
                    PInteger(pi)^ := StringToSet(ASubType, AChild.AsString);
                end;
              otULong:
                begin
                  if AChild.FType = jdtInteger then
                    PCardinal(pi)^ := AChild.AsInteger
                  else
                    PCardinal(pi)^ := StringToSet(ASubType, AChild.AsString);
                end;
            end;
          end;
        tkClass:
          LoadClass(PPointer(pi)^, AChild);
        tkWChar:
          PWideChar(pi)^ := PWideChar(AChild.AsString)[0];
        {$IFNDEF NEXTGEN}
        tkLString:
          PAnsiString(pi)^ := AnsiString(AChild.AsString);
        tkWString:
          PWideString(pi)^ := AChild.AsString;
        {$ENDIF}
        tkVariant:
          PVariant(pi)^ := AChild.AsVariant;
        tkArray, tkDynArray:
          readValue(AChild.AsJsonObject, pi, ASubType);
        tkRecord:
          readValue(AChild.AsJsonObject, pi, ASubType);
        tkInt64:
          PInt64(pi)^ := AChild.AsInt64;
        tkUString:
          PUnicodeString(pi)^ := AChild.AsString;
      end;
    end;
  end;
  {$ENDIF}
begin
  if (aDest <> nil) and (Assigned(aIn)) then begin
    {$IFDEF USE_UNICODE}
    if aType.Kind = tkRecord then
      ToRecord
    else if aType.Kind = tkClass then
      ToObject
    else if aType.Kind = tkDynArray then
      ToArray
    else if aType.Kind = tkArray then
      ToFixedArray
    {$ELSE}
    if aType.Kind = tkClass then
      ToObject
    {$ENDIF}
    else
      raise Exception.Create(SUnsupportPropertyType);
  end;
end;

{$IFDEF USE_UNICODE}
class function TYxdSerialize.writeToValue(aIn: PJSONValue): TValue;
begin
  case aIn.FType of
    jdtString:
      Result := aIn.AsString;
    jdtInteger:
      Result := aIn.AsInt64;
    jdtFloat:
      Result := aIn.AsFloat;
    jdtDateTime:
      Result := aIn.TryAsDatetime;
    jdtBoolean:
      Result := aIn.AsBoolean;
    jdtObject:
      Result := writeToValue(aIn.AsJsonObject);
  else
    Result := TValue.Empty;
  end;
end;
{$ENDIF}

{$IFDEF USE_UNICODE}
class function TYxdSerialize.writeToValue(aIn: JSONBase): TValue;
var
  AValues: array of TValue;
  I: Integer;
begin
  if not Assigned(aIn) then Exit;
  SetLength(AValues, aIn.Count);
  for I := 0 to aIn.Count - 1 do
    AValues[I] := writeToValue(aIn.Items[I]);
  Result := TValue.FromArray(TypeInfo(TValueArray), AValues);
end;
{$ENDIF}

{$IFDEF USEDataSet}
class procedure TYxdSerialize.WriteDataSet(AOut: JSONBase; const Key: JSONString;
  ADataSet: TDataSet; const PageIndex, PageSize: Integer; 
  Base64Blob: Boolean);
var
  BlobStream: TMemoryStream;

  procedure AddDataSetMeta(MetaItem: JSONArray; Field: TField);
  begin
    MetaItem.Add(Field.FieldName);
    if Field.DataType = ftAutoInc then
      MetaItem.Add(Ord(ftLargeint))
    else
      MetaItem.Add(Ord(Field.DataType));
    MetaItem.Add(Field.Size);
    MetaItem.Add(Field.Required);
    MetaItem.Add(Field.DisplayLabel);
  end;

  procedure AddDataSetRow(DS: TDataSet; Item: JSONArray);
  var
    Field: TField;
    I: Integer;
  begin
    for I := 0 to DS.Fields.Count - 1 do begin
      Field := DS.Fields[I];
      // �ж��ֶ��Ƿ���Ҫ����
      if Field.IsNull then
        Item.Add(null)
      else begin
        case Field.DataType of
          ftBoolean:
            Item.Add(Field.AsBoolean);
          ftDate, ftTime, ftDateTime, ftTimeStamp{$IFDEF USE_UNICODE}, ftTimeStampOffset{$ENDIF}:
            Item.AddDateTime(Field.AsDateTime);
          ftInteger, ftWord, ftSmallint{$IFDEF USE_UNICODE}, ftShortint{$ENDIF}:
            Item.Add(Field.AsInteger);
          ftLargeint, ftAutoInc:
            Item.Add({$IFDEF USE_UNICODE}Field.AsLargeInt{$ELSE}Field.AsInteger{$ENDIF});
          ftFloat, ftBCD: // ftSingle
            Item.Add(Field.AsFloat);
          ftString, ftWideString, ftGuid:
            Item.Add(Field.AsString);
          ftBlob, ftGraphic, ftMemo, ftTypedBinary:
            begin
              if not Assigned(BlobStream) then
                BlobStream := TMemoryStream.Create
              else
                BlobStream.Position := 0;
              TBlobField(Field).SaveToStream(BlobStream);
              Item.Add(BlobStreamToString(BlobStream.Memory, BlobStream.Position, Base64Blob));
            end;
        else
          Item.Add(Field.AsString);
        end;
      end;
    end;
  end;

  procedure AddDataSet(DS: TDataSet);
  var
    Data: JSONArray;
    MoveIndex, StepIndex, I: Integer;
  begin
    Data := JSONObject(aOut).AddChildArray('meta');
    for I := 0 to DS.Fields.Count - 1 do
      AddDataSetMeta(Data.AddChildArray(), DS.Fields[I]);

    BlobStream := nil;
    DS.DisableControls;
    try
      Data := JSONObject(aOut).AddChildArray('data');
      DS.First;
      // ��ҳ�ƶ���¼
      if (PageIndex > 0) and (PageSize > 0) then begin
        MoveIndex := (PageIndex - 1) * PageSize;
        DS.MoveBy(MoveIndex);
      end;
      StepIndex := 0;
      while not DS.Eof do begin
        AddDataSetRow(DS, Data.AddChildArray);
        if (PageSize > 0) then begin
          Inc(StepIndex);
          if StepIndex >= PageSize then
            Break;
        end;
        DS.Next;
      end;
    finally
      DS.EnableControls;
      if Assigned(BlobStream) then
        BlobStream.Free;
    end;
  end;

begin
  if aOut.IsJSONArray then
    aOut := JSONArray(aOut).AddChildObject()
  else if key <> '' then
    aOut := JSONObject(aOut).addChildObject(key);
  AddDataSet(ADataSet);
end;
{$ENDIF}

class procedure TYxdSerialize.writeValue(aOut: JSONBase; const key: JSONString; aSource: Pointer;
  aType: PTypeInfo);
{$IFDEF USE_UNICODE}var AValue: TValue;{$ENDIF}

  procedure AddStringsToArray(AParent:JSONArray; AData:TStrings);
  var
    J: Integer;
  begin
    for J := 0 to AData.Count-1 do
      AParent.Add(AData[J]);
  end;

  procedure AddCollection(AParent:JSONBase; ACollection:TCollection);
  var
    J: Integer;
  begin
    for J := 0 to ACollection.Count-1 do
      writeValue(AParent, '', ACollection.Items[J]{$IFNDEF USE_UNICODE}, GetObjectTypeInfo(ACollection.Items[J]){$ENDIF});
  end;

  {$IFDEF USE_UNICODE}
  procedure AddRecord;
  var
    AObj: TObject;
    AFieldItem: TRttiField;
    AContext: TRttiContext;
    AFields: TArray<TRttiField>;
    ARttiType: TRttiType;
    AFieldName: string;
    AFieldAttrItem: TCustomAttribute;
    II, J: Integer;
  begin
    AContext := TRttiContext.Create;
    ARttiType := AContext.GetType(AType);
    AFields := ARttiType.GetFields;
    //����Ǵӽṹ�壬���¼���Ա������Ƕ�����ֻ��¼�乫�������ԣ����⴦��TStrings��TCollection
    for J := Low(AFields) to High(AFields) do begin
      AFieldItem := AFields[J];
      if AFieldItem.FieldType <> nil then begin
        AFieldName := AFieldItem.Name;
        if AFieldItem.GetAttributes <> nil then begin
          for AFieldAttrItem in AFieldItem.GetAttributes do
            if AFieldAttrItem is FieldNameAttribute then begin
              AFieldName := FieldNameAttribute(AFieldAttrItem).Name;
              Break;
            end;
        end;

        case AFieldItem.FieldType.TypeKind of
          tkInteger:
            JSONObject(aOut).put(AFieldName, AFieldItem.GetValue(ASource).AsInteger);
          {$IFNDEF NEXTGEN}tkString,tkLString,tkWString,{$ENDIF !NEXTGEN}tkUString:
            JSONObject(aOut).put(AFieldName, AFieldItem.GetValue(ASource).AsString);
          tkEnumeration:
            begin
              if GetTypeData(AFieldItem.FieldType.Handle).BaseType^ = TypeInfo(Boolean) then
                JSONObject(aOut).put(AFieldName, AFieldItem.GetValue(ASource).AsBoolean)
              else if JsonRttiEnumAsInt then
                JSONObject(aOut).put(AFieldName, AFieldItem.GetValue(ASource).AsOrdinal)
              else
                JSONObject(aOut).put(AFieldName, AFieldItem.GetValue(ASource).ToString);
            end;
          tkSet:
            begin
              if JsonRttiEnumAsInt then
                JSONObject(aOut).put(AFieldName, SetAsOrd(AFieldItem.GetValue(ASource)))
              else
                JSONObject(aOut).put(AFieldName, AFieldItem.GetValue(ASource).ToString);
            end;
          tkChar,tkWChar:
            JSONObject(aOut).put(AFieldName, AFieldItem.GetValue(ASource).ToString);
          tkFloat:
            begin
              if (AFieldItem.FieldType.Handle = TypeInfo(TDateTime)) or
                (AFieldItem.FieldType.Handle = TypeInfo(TTime)) or
                (AFieldItem.FieldType.Handle = TypeInfo(TDate))
                 then
                JSONObject(aOut).putDateTime(AFieldName, AFieldItem.GetValue(ASource).AsExtended)
              else
                JSONObject(aOut).put(AFieldName, AFieldItem.GetValue(ASource).AsExtended);
            end;
          tkInt64:
            JSONObject(aOut).put(AFieldName, AFieldItem.GetValue(ASource).AsInt64);
          tkVariant:
            JSONObject(aOut).put(AFieldName, AFieldItem.GetValue(ASource).AsVariant);
          tkArray, tkDynArray:
            with JSONObject(aOut).addChildArray(AFieldName) do begin
              AValue := AFieldItem.GetValue(ASource);
              for II := 0 to AValue.GetArrayLength - 1 do
                putObjectValue('', AValue.GetArrayElement(II));
            end;
          tkClass:
            begin
              AObj := AFieldItem.GetValue(ASource).AsObject;
              if (AObj is TStrings) then
                JSONObject(aOut).put(AFieldName, TStrings(AObj).Text)
              else if AObj is TCollection then
                AddCollection(JSONObject(aOut).addChildArray(AFieldName), AObj as TCollection)
              else
                writeValue(aOut, AFieldName, AObj, AFieldItem.FieldType.Handle);
            end;
          tkRecord:
            writeValue(aOut, AFieldName, Pointer(IntPtr(ASource) + AFieldItem.Offset),
              AFieldItem.FieldType.Handle);
        end;
      end else
        raise Exception.CreateFmt(SMissRttiTypeDefine,[AFieldItem.Name]);
    end;
  end;
  {$ENDIF}

  procedure AddObject;
  var
    AName: JSONString;
    APropList: PPropList;
    ACount: Integer;
    AObj, AChildObj: TObject;
    J: Integer;
  begin
    AObj := ASource;
    ACount := GetPropList(AType,APropList);
    try
      for J := 0 to ACount - 1 do begin
        if APropList[J].PropType^.Kind in [tkMethod{$IFDEF USE_UNICODE}, tkProcedure{$ENDIF}] then
          Continue;
        if APropList[J].PropType^.Kind in
          [tkInterface{$IFDEF USE_UNICODE}, tkClassRef, tkPointer{$ENDIF}]
        then begin
          if IsDefaultPropertyValue(AObj, APropList[J], nil) then
            Continue;
        end;
        {$IF RTLVersion>25}
        AName := APropList[J].NameFld.ToString;
        {$ELSE}
        AName := String(APropList[J].Name);
        {$IFEND}
        case APropList[J].PropType^.Kind of
          tkClass:
            begin
              AChildObj := Pointer(GetOrdProp(AObj, APropList[J]));
              if AChildObj is TStrings then
                JSONObject(aOut).put(AName, (AChildObj as TStrings).Text)
              else if AChildObj is TCollection then
                AddCollection(JSONObject(aOut).addChildArray(AName), AChildObj as TCollection)
              else
                writeValue(aOut, AName, AChildObj{$IFNDEF USE_UNICODE}, GetObjectTypeInfo(AChildObj){$ENDIF});
            end;
          tkInteger:
            JSONObject(aOut).put(AName, GetOrdProp(AObj,APropList[J]));
          tkChar,tkString,tkWChar, tkLString, tkWString{$IFDEF USE_UNICODE}, tkUString{$ENDIF}:
            JSONObject(aOut).put(AName, GetStrProp(AObj,APropList[J]));
          tkEnumeration:
            begin
              if GetTypeData(APropList[J]^.PropType^)^.BaseType^ = TypeInfo(Boolean) then
                JSONObject(aOut).put(AName, GetOrdProp(AObj,APropList[J])<>0)
              else if JsonRttiEnumAsInt then
                JSONObject(aOut).put(AName, GetOrdProp(AObj,APropList[J]))
              else
                JSONObject(aOut).put(AName, GetEnumProp(AObj,APropList[J]));
            end;
          tkSet:
            begin
              if JsonRttiEnumAsInt then
                JSONObject(aOut).put(AName, GetOrdProp(AObj, APropList[J]))
              else
                JSONObject(aOut).put(AName, GetSetProp(AObj,APropList[J],True));
            end;
          tkVariant:
            {$IFDEF NEXTGEN}
            JSONObject(aOut).put(AName, GetPropValue(AObj, APropList[J]));
            {$ELSE}
            JSONObject(aOut).put(AName, GetPropValue(AObj, string(APropList[J].Name)));
            {$ENDIF}
          tkInt64:
            JSONObject(aOut).put(AName, GetInt64Prop(AObj,APropList[J]));
          tkFloat:
            JSONObject(aOut).Put(AName, GetFloatProp(AObj, APropList[J]));
          tkRecord, tkArray, tkDynArray://��¼�����顢��̬��������ϵͳҲ�����棬Ҳû�ṩ����̫�õĽӿ�
            raise Exception.Create(SUnsupportPropertyType);
        end;
      end;
    finally
      FreeMem(APropList);
    end;
  end;

  {$IFDEF USE_UNICODE}
  procedure AddArray;
  var
    I: Integer;
  begin
    TValue.Make(ASource, AType, AValue);
    for I := 0 to AValue.GetArrayLength - 1 do
      writeValue(aOut, '', AValue.GetArrayElement(I));
  end;
  {$ENDIF}
begin
  if not Assigned(ASource) then Exit;
  case AType.Kind of
    {$IFDEF USE_UNICODE}
    tkRecord:
      begin
        if aOut.IsJSONArray then
          aOut := JSONArray(aOut).AddChildObject()
        else begin
          if Key <> '' then
            aOut := JSONObject(aOut).addChildObject(key);
        end;
        AddRecord;
      end;
    {$ENDIF}
    tkClass:
      begin
        if TObject(ASource) is TStrings then begin
          if key = '' then begin
            if aOut.IsJSONArray then begin
              AddStringsToArray(JSONArray(AOut), TStrings(ASource))
            end else
              JSONObject(aOut).put('text', TStrings(ASource).Text)
          end else
            JSONObject(aOut).put(key, TStrings(ASource).Text)
        end else if TObject(ASource) is TCollection then
          AddCollection(aOut, TCollection(ASource))
        {$IFDEF USEDataSet}
        else if TObject(ASource) is TDataSet then
          WriteDataSet(aOut, Key, TDataSet(ASource), 0, -1)
        {$ENDIF}
        else begin
          if aOut.IsJSONArray then
            aOut := JSONArray(aOut).AddChildObject()
          else if key <> '' then
            aOut := JSONObject(aOut).addChildObject(key);
          AddObject;
        end;
      end;
    {$IFDEF USE_UNICODE}
    tkDynArray:
      begin
        if aOut.IsJSONArray then
          aOut := JSONArray(aOut).addChildArray()
        else
          aOut := JSONObject(aOut).addChildArray(key);
        AddArray;
      end;
    {$ENDIF}
  end;
end;

{$IFDEF USE_UNICODE}
class procedure TYxdSerialize.writeValue(aOut: JSONBase; const key: JSONString; aInstance: TValue);
var
  I,C:Integer;
begin
   if not Assigned(aOut) then Exit;
  case aInstance.Kind of
    tkClass:
      writeValue(aOut, key, aInstance.AsObject, aInstance.TypeInfo);
    tkRecord:
      writeValue(aOut, key, aInstance.GetReferenceToRawData, aInstance.TypeInfo);
    tkArray, tkDynArray:
      begin
        if not aOut.IsJSONArray then
          aOut := JSONObject(aOut).addChildArray(key)
        else
          aOut.Clear;
        C := aInstance.GetArrayLength;
        for I := 0 to C-1 do
          writeValue(aOut, '', AInstance.GetArrayElement(I));
      end;
    tkInteger, tkInt64:
      JSONObject(aOut).put(key, AInstance.AsInt64);
    tkChar, tkString,tkWChar, tkLString, tkWString, tkUString:
      JSONObject(aOut).put(key, aInstance.ToString);
    tkEnumeration:
      begin
        if GetTypeData(AInstance.TypeInfo)^.BaseType^ = TypeInfo(Boolean) then
          JSONObject(aOut).put(key, aInstance.AsBoolean)
        else if JsonRttiEnumAsInt then
          JSONObject(aOut).put(key, aInstance.AsOrdinal)
        else
          JSONObject(aOut).put(key, aInstance.ToString)
      end;
    tkSet:
      JSONObject(aOut).put(key, aInstance.ToString);
    tkVariant:
      JSONObject(aOut).put(key, aInstance.AsVariant)
  end;
end;
{$ENDIF} 

{ TMsgPackSerializeWriter }

procedure TMsgPackSerializeWriter.Add(const Value: Boolean);
begin

end;

procedure TMsgPackSerializeWriter.Add(const Value: Variant);
begin

end;

procedure TMsgPackSerializeWriter.Add(const Value: Cardinal);
begin

end;

procedure TMsgPackSerializeWriter.Add(const Value: Double);
begin

end;

procedure TMsgPackSerializeWriter.Add(const Value: Integer);
begin

end;

procedure TMsgPackSerializeWriter.Add(const Value: string);
begin

end;

procedure TMsgPackSerializeWriter.AddInt64(const Value: Int64);
begin

end;

procedure TMsgPackSerializeWriter.AddTime(const Value: TDateTime);
begin

end;

procedure TMsgPackSerializeWriter.BeginData(const Name: string;
  const IsArray: Boolean);
begin

end;

procedure TMsgPackSerializeWriter.BeginRoot;
begin

end;

constructor TMsgPackSerializeWriter.Create;
begin
  FData := TMemoryStream.Create;
  FData.Size := 16384; // 16K
  FDoEscape := True;
end;

destructor TMsgPackSerializeWriter.Destroy;
begin
  FreeAndNil(FData);
  inherited;
end;

procedure TMsgPackSerializeWriter.EndData;
begin

end;

procedure TMsgPackSerializeWriter.EndRoot;
begin

end;

function TMsgPackSerializeWriter.IsArray: Boolean;
begin
  Result := FIsArray;
end;

function TMsgPackSerializeWriter.SaveToStream(AStream: TStream): Integer;
begin
  Result := 0;
end;

function TMsgPackSerializeWriter.ToString: string;
begin

end;

procedure TMsgPackSerializeWriter.WriteBoolean(const Name: string;
  const Value: Boolean);
begin

end;

procedure TMsgPackSerializeWriter.WriteDateTime(const Name: string;
  const Value: TDateTime);
begin

end;

procedure TMsgPackSerializeWriter.WriteFloat(const Name: string;
  const Value: Double);
begin

end;

procedure TMsgPackSerializeWriter.WriteInt(const Name: string;
  const Value: Integer);
begin

end;

procedure TMsgPackSerializeWriter.WriteInt64(const Name: string;
  const Value: Int64);
begin

end;

procedure TMsgPackSerializeWriter.WriteName(const Name: string);
begin

end;

procedure TMsgPackSerializeWriter.WriteNull(const Name: string);
begin

end;

procedure TMsgPackSerializeWriter.WriteString(const Name, Value: string);
begin

end;

procedure TMsgPackSerializeWriter.WriteUInt(const Name: string;
  const Value: Cardinal);
begin

end;

procedure TMsgPackSerializeWriter.WriteVariant(const Name: string;
  const Value: Variant);
begin

end;

initialization
  CSPBlobs := PJSONChar(CSBlobs);
  CSPBlobs2 := CSPBlobs + 4;
  CSPBlobs3 := CSPBlobs2 + 2;

end.
