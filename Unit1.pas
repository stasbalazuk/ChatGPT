unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ComObj, 
  YxdJson, YxdStr, IniFiles,
  AxCtrls,
  ActiveX,
  Mask,
  WinInet,
  clipbrd,
  StrUtils, ShellApi,
  StdCtrls, ComCtrls, ExtCtrls,
  Dialogs;


const
  MicrosoftTranslatorTranslateUri = 'http://api.microsofttranslator.com/v2/Http.svc/Translate?appId=%s&text=%s&from=%s&to=%s';
  MicrosoftTranslatorDetectUri    = 'http://api.microsofttranslator.com/v2/Http.svc/Detect?appId=%s&text=%s';
  MicrosoftTranslatorGetLngUri    = 'http://api.microsofttranslator.com/v2/Http.svc/GetLanguagesForTranslate?appId=%s';
  MicrosoftTranslatorGetSpkUri    = 'http://api.microsofttranslator.com/v2/Http.svc/GetLanguagesForSpeak?appId=%s';
  MicrosoftTranslatorSpeakUri     = 'http://api.microsofttranslator.com/v2/Http.svc/Speak?appId=%s&text=%s&language=%s';
  //this AppId if for demo only please be nice and use your own , it's easy get one from here http://msdn.microsoft.com/en-us/library/ff512386.aspx
  BingAppId                       = '73C8F474CA4D1202AD60747126813B731199ECEA';
  Msxml2_DOMDocument              = 'Msxml2.DOMDocument.6.0';


type
  TmyChatGPT = class(TForm)
    grp1: TGroupBox;
    Memo1: TMemo;
    grp2: TGroupBox;
    grpTrans: TGroupBox;
    spl1: TSplitter;
    Memo2: TMemo;
    mmo1: TMemo;
    spl2: TSplitter;
    pnl1: TPanel;
    g_query: TGroupBox;
    btn1: TButton;
    chksave: TCheckBox;
    grpClean: TGroupBox;
    lst2: TListBox;
    spl3: TSplitter;
    pnl2: TPanel;
    edt1: TEdit;
    stat1: TStatusBar;
    btnToken: TButton;
    procedure btn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure chksaveClick(Sender: TObject);
    procedure lst2Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure edt1KeyPress(Sender: TObject; var Key: Char);
    procedure FormActivate(Sender: TObject);
    procedure btnTokenClick(Sender: TObject);
  private
    { Private declarations }
    function PostParam(Metod: string; RequestURL: string; Params: string; Bearer: string): string;
    function PostTranslate(Metod: string; RequestURL: string; Params: string): string;
    { Setting ini file }
    procedure WriteIniFile(uFile: string; Section_Name: string; Key_Name: string; StrValue: string);
    function ReadIniFile(uFile: string; Section_Name: string; Key_Name: string) : string;
    procedure ReadAllSecIniFile(uFile: string);
    procedure EraseSecIniFile(uFile: string; Section_Name: string);
    procedure ReadValueSecIniFile(uFile: string; Section_Name: string);
    procedure ReadSecIniFile(uFile: string; Section_Name: string);
    procedure WMQueryEndSession(var Message: TMessage); message WM_QUERYENDSESSION;
  public
    { Public declarations }
    Url,ApiKey : string;
    lng       : TStringList;
    FileName  : string;
    temper : Integer;
    uToken : string;
  end;

var
  myChatGPT: TmyChatGPT;

implementation

{$R *.dfm}

uses uSetting;

procedure TmyChatGPT.WMQueryEndSession(var Message: TMessage);
begin
  Message.Result := 1;
  Application.Terminate;
end;

// Write values to a INI file
procedure TmyChatGPT.WriteIniFile(uFile: string; Section_Name: string; Key_Name: string; StrValue: string); //'c:\MyIni.ini'
 var
   ini: TIniFile;
begin
try
   // Create INI Object and open or create file test.ini
    ini := TIniFile.Create(uFile);
   try
     // Write a string value to the INI file.
    ini.WriteString(Section_Name, Key_Name, StrValue);
     // Write a integer value to the INI file.
     //ini.WriteInteger(Section_Name, Key_Name, IntValue);
     // Write a boolean value to the INI file.
     //ini.WriteBool(Section_Name, Key_Name, BoolValue);
   finally
     ini.Free;
   end;
except
  Exit;
end;
end;


 // Read values from an INI file
function TmyChatGPT.ReadIniFile(uFile: string; Section_Name: string; Key_Name: string) : string;
 var
   ini: TIniFile;
   res: string;
begin
try
     Result := '';
     // Create INI Object and open or create file test.ini
     ini := TIniFile.Create(uFile);
   try
     res := ini.ReadString(Section_Name, Key_Name, ''); //MessageDlg('Value of Section:  ' + res, mtInformation, [mbOK], 0);
     Result := res;
   finally
     ini.Free;
   end;
except
  Exit;
end;
end;

 // Read all sections
procedure TmyChatGPT.ReadAllSecIniFile(uFile: string);
 var
    ini: TIniFile;
    uList: TStringList;
begin
try
  try
     uList := TStringList.Create;
     ini := TIniFile.Create('MyIni.ini');
   try
     ini.ReadSections(uList);
     if uList.Count > 0 then MessageDlg('All Section:  ' + uList.Text, mtInformation, [mbOK], 0);
   finally
     ini.Free;
   end;
  finally
    uList.Free;
  end;
except
  Exit;
end;
end;

 // Read a section
procedure TmyChatGPT.ReadSecIniFile(uFile: string; Section_Name: string);
var
    ini: TIniFile;
    uList: TStringList;
begin
try
  try
    uList := TStringList.Create;
    ini := TIniFile.Create(uFile);
   try
    ini.ReadSection(Section_Name, uList);
    if uList.Count > 0 then MessageDlg('Read of Section:  ' + uList.Text, mtInformation, [mbOK], 0);
   finally
    ini.Free;
   end;
  finally
    uList.Free;
  end;
except
   Exit;
end;
end;

 // Read section values
procedure TmyChatGPT.ReadValueSecIniFile(uFile: string; Section_Name: string);
var
    ini: TIniFile;
    uList: TStringList;
begin
try
  try
    uList := TStringList.Create;
    ini := TIniFile.Create(uFile);
   try
    ini.ReadSectionValues(Section_Name, uList);
    if uList.Count > 0 then MessageDlg('Value of Section:  ' + uList.Text, mtInformation, [mbOK], 0);
   finally
    ini.Free;
   end;
  finally
    uList.Free;
  end;
except
   Exit;
end;
end;

 // Erase a section
procedure TmyChatGPT.EraseSecIniFile(uFile: string; Section_Name: string);
var
    ini: TIniFile;
begin
try
    ini := TIniFile.Create(uFile);
   try
    ini.EraseSection(Section_Name);
    MessageDlg('Erase of Section:  ' + Section_Name + ' successfully', mtInformation, [mbOK], 0);
   finally
    ini.Free;
   end;
except
   Exit;
end;
end;

procedure WinInet_HttpGet(const Url: string;Stream:TStream);overload;
const
BuffSize = 1024*1024;
var
  hInter   : HINTERNET;
  UrlHandle: HINTERNET;
  BytesRead: DWORD;
  Buffer   : Pointer;
begin
  hInter := InternetOpen('', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if Assigned(hInter) then
    try
      Stream.Seek(0,0);
      GetMem(Buffer,BuffSize);
      try
          UrlHandle := InternetOpenUrl(hInter, PChar(Url), nil, 0, INTERNET_FLAG_RELOAD, 0);
          if Assigned(UrlHandle) then
          begin
            repeat
              InternetReadFile(UrlHandle, Buffer, BuffSize, BytesRead);
              if BytesRead>0 then
               Stream.WriteBuffer(Buffer^,BytesRead);
            until BytesRead = 0;
            InternetCloseHandle(UrlHandle);
          end;
      finally
        FreeMem(Buffer);
      end;
    finally
     InternetCloseHandle(hInter);
    end;
end;

function WinInet_HttpGet(const Url: string): string;overload;
Var
  StringStream : TStringStream;
begin
  Result:='';
    StringStream:=TStringStream.Create('');
    try
        WinInet_HttpGet(Url,StringStream);
        if StringStream.Size>0 then
        begin
          StringStream.Seek(0,0);
          Result:=StringStream.ReadString(StringStream.Size);
        end;
    finally
      StringStream.Free;
    end;
end;

function TranslateText(const AText,SourceLng,DestLng:string):string;
var
   XmlDoc : OleVariant;
   Node   : OleVariant;
begin
  Result:=WinInet_HttpGet(Format(MicrosoftTranslatorTranslateUri,[BingAppId,AText,SourceLng,DestLng]));
  XmlDoc:= CreateOleObject(Msxml2_DOMDocument);
  try
    XmlDoc.Async := False;
    XmlDoc.LoadXML(Result);
    if (XmlDoc.parseError.errorCode <> 0) then
     raise Exception.CreateFmt('Error in Xml Data %s',[XmlDoc.parseError]);
    Node:= XmlDoc.documentElement;
    if not VarIsClear(Node) then
     Result:=Utf8ToAnsi(XmlDoc.Text);
  finally
     XmlDoc:=Unassigned;
  end;
end;

function DetectLanguage(const AText:string ):string;
var
   XmlDoc : OleVariant;
   Node   : OleVariant;
begin
  Result:=WinInet_HttpGet(Format(MicrosoftTranslatorDetectUri,[BingAppId,AText]));
  XmlDoc:= CreateOleObject(Msxml2_DOMDocument);
  try
    XmlDoc.Async := False;
    XmlDoc.LoadXML(Result);
    if (XmlDoc.parseError.errorCode <> 0) then
     raise Exception.CreateFmt('Error in Xml Data %s',[XmlDoc.parseError]);
    Node:= XmlDoc.documentElement;
    if not VarIsClear(Node) then
      Result:=XmlDoc.Text;
  finally
     XmlDoc:=Unassigned;
  end;
end;

function GetLanguagesForTranslate: TStringList;
var
   XmlDoc : OleVariant;
   Node   : OleVariant;
   Nodes  : OleVariant;
   lNodes : Integer;
   i      : Integer;
   sValue : string;
begin
  Result:=TStringList.Create;
  sValue:=WinInet_HttpGet(Format(MicrosoftTranslatorGetLngUri,[BingAppId]));
  XmlDoc:= CreateOleObject(Msxml2_DOMDocument);
  try
    XmlDoc.Async := False;
    XmlDoc.LoadXML(sValue);
    if (XmlDoc.parseError.errorCode <> 0) then
     raise Exception.CreateFmt('Error in Xml Data %s',[XmlDoc.parseError]);
    Node:= XmlDoc.documentElement;
    if not VarIsClear(Node) then
    begin
      Nodes := Node.childNodes;
       if not VarIsClear(Nodes) then
       begin
         lNodes:= Nodes.Length;
           for i:=0 to lNodes-1 do
            Result.Add(Nodes.Item(i).Text);
       end;
    end;
  finally
     XmlDoc:=Unassigned;
  end;
end;

function GetLanguagesForSpeak: TStringList;
var
   XmlDoc : OleVariant;
   Node   : OleVariant;
   Nodes  : OleVariant;
   lNodes : Integer;
   i      : Integer;
   sValue : string;
begin
  Result:=TStringList.Create;
  sValue:=WinInet_HttpGet(Format(MicrosoftTranslatorGetSpkUri,[BingAppId]));
  XmlDoc:= CreateOleObject(Msxml2_DOMDocument);
  try
    XmlDoc.Async := False;
    XmlDoc.LoadXML(sValue);
    if (XmlDoc.parseError.errorCode <> 0) then
     raise Exception.CreateFmt('Error in Xml Data %s',[XmlDoc.parseError]);
    Node:= XmlDoc.documentElement;
    if not VarIsClear(Node) then
    begin
      Nodes := Node.childNodes;
       if not VarIsClear(Nodes) then
       begin
         lNodes:= Nodes.Length;
           for i:=0 to lNodes-1 do
            Result.Add(Nodes.Item(i).Text);
       end;
    end;
  finally
     XmlDoc:=Unassigned;
  end;
end;

procedure Speak(const FileName,AText,Lng:string);
var
  Stream : TFileStream;
begin
  Stream:=TFileStream.Create(FileName,fmCreate);
  try
    WinInet_HttpGet(Format(MicrosoftTranslatorSpeakUri,[BingAppId,AText,Lng]),Stream);
  finally
    Stream.Free;
  end;
end;


function GetDosOutput(CommandLine: string; Work: string = 'C:\'): string;  { Run a DOS program and retrieve its output dynamically while it is running. }
var
  SecAtrrs: TSecurityAttributes;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  pCommandLine: array[0..255] of AnsiChar;
  BytesRead: Cardinal;
  WorkDir: string;
  Handle: Boolean;
begin
  Result := '';
  with SecAtrrs do begin
    nLength := SizeOf(SecAtrrs);
    bInheritHandle := True;
    lpSecurityDescriptor := nil;
  end;
  CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SecAtrrs, 0);
  try
    with StartupInfo do
    begin
      FillChar(StartupInfo, SizeOf(StartupInfo), 0);
      cb := SizeOf(StartupInfo);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;
    WorkDir := Work;
    Handle := CreateProcess(nil, PChar('cmd.exe /C ' + CommandLine),
                            nil, nil, True, 0, nil,
                            PChar(WorkDir), StartupInfo, ProcessInfo);
    CloseHandle(StdOutPipeWrite);
    if Handle then
      try
        repeat
          WasOK := windows.ReadFile(StdOutPipeRead, pCommandLine, 255, BytesRead, nil);
          if BytesRead > 0 then
          begin
            pCommandLine[BytesRead] := #0;
            Result := Result + pCommandLine;
          end;
        until not WasOK or (BytesRead = 0);
        WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
      finally
        CloseHandle(ProcessInfo.hThread);
        CloseHandle(ProcessInfo.hProcess);
      end;
  finally
    CloseHandle(StdOutPipeRead);
  end;
end;

function MemoryStreamToString(M: TMemoryStream): string;
begin
  SetString(Result, PChar(M.Memory), M.Size div SizeOf(Char));
end;

procedure StringToStream(const AString: string; out AStream: TStream);
begin
  AStream := TStringStream.Create(AString);
end;

function StreamToString(Stream : TStream) : String;
var ms : TMemoryStream;
begin
  Result := '';
  ms := TMemoryStream.Create;
  try
    ms.LoadFromStream(Stream);
    SetString(Result,PChar(ms.memory),ms.Size);
  finally
    ms.free;
  end;
end;

//Translate
function TmyChatGPT.PostTranslate(Metod: string; RequestURL: string; Params: string): string;
var
  Req: OleVariant;
  OV: Variant;
  os: TOLEStream;
  im: TMemoryStream;
  Json : JSONBase;
  str : JSONString;
  ABuilder: TStringCatHelper;
begin
try
  Result:='';
  try
    Req:=CreateOleObject('WinHttp.WinHttpRequest.5.1');
    Req.Open(Metod, RequestURL, False);
    Req.SetRequestHeader('Content-Type','application/json; charset=utf-8');
    Req.SetRequestHeader('Cache-control','no-cache');
    Req.SetRequestHeader('Connection','Keep-Alive');
    Req.SetRequestHeader('Proxy-Connection','keep-alive');
    Req.SetRequestHeader('Accept','application/json');
    Req.Send(Params);
    Req.WaitForResponse;
  finally
    OV:=Req.ResponseStream;
    TVarData(OV).vType:=varUnknown;
    os:=TOLEStream.Create(IStream(TVarData(OV).VUnknown));
    im:=TMemoryStream.Create;
    im.CopyFrom(os,os.Size);
    im.Position:=0;
    str:=StreamToString(im);
    str:=Utf8ToAnsi(str);
    if Length(str)>0 then
     try
       ABuilder := TStringCatHelper.Create;
       Json := JSONBase.Parser(Trim(str), False);
       mmo1.Lines.Add(PChar(Trim(Json.ToString(4,False))));
       Result:=Trim(Json.GetSTS('content',Json,0,ABuilder,7));
     finally
       FreeAndNil(ABuilder);
     end;
  end;
except
  Result:='Error Out Json';
  Exit;
end;
end;

//авторизация
function TmyChatGPT.PostParam(Metod: string; RequestURL: string; Params: string; Bearer: string): string;
var
  Req: OleVariant;
  OV: Variant;
  os: TOLEStream;
  im: TMemoryStream;
  Json : JSONBase;
  str : JSONString;
  ABuilder: TStringCatHelper;
begin
try
  Result:='';
  try
    Req:=CreateOleObject('WinHttp.WinHttpRequest.5.1');
    Req.Open(Metod, RequestURL, False);
    Req.SetRequestHeader('Authorization', 'Bearer ' + Bearer); //Req.SetRequestHeader('OpenAI-Organization','org-bXVjI4KnG03UZemtwcyVmWoi');
    Req.SetRequestHeader('Content-Type','application/json; charset=utf-8');
    Req.SetRequestHeader('Cache-control','no-cache');
    Req.SetRequestHeader('Connection','Keep-Alive');
    Req.SetRequestHeader('Proxy-Connection','keep-alive');
    Req.SetRequestHeader('Accept','application/json');
    Req.Send(Params);
    Req.WaitForResponse;
  finally
    OV:=Req.ResponseStream;
    TVarData(OV).vType:=varUnknown;
    os:=TOLEStream.Create(IStream(TVarData(OV).VUnknown));
    im:=TMemoryStream.Create;
    im.CopyFrom(os,os.Size);
    im.Position:=0;
    str:=StreamToString(im);
    str:=Utf8ToAnsi(str);
    if Length(str)>0 then
     try
       ABuilder := TStringCatHelper.Create;
       Json := JSONBase.Parser(Trim(str), False);
       mmo1.Lines.Add(PChar(Trim(Json.ToString(4,False))));
       Result:=Trim(Json.GetSTS('content',Json,0,ABuilder,7));
     finally
       FreeAndNil(ABuilder);
     end;
  end;
except
  Result:='Error Out Json';
  Exit;
end;
end;

procedure CaptureConsoleOutput(const ACommand, AParameters: String; AMemo: TMemo);
 const
   CReadBuffer = 2400;
 var
   saSecurity: TSecurityAttributes;
   hRead: THandle;
   hWrite: THandle;
   suiStartup: TStartupInfo;
   piProcess: TProcessInformation;
   pBuffer: array[0..CReadBuffer] of AnsiChar;      //----- update
   dRead: DWord;
   dRunning: DWord;
begin
try
   saSecurity.nLength := SizeOf(TSecurityAttributes);
   saSecurity.bInheritHandle := True;  
   saSecurity.lpSecurityDescriptor := nil; 
   if CreatePipe(hRead, hWrite, @saSecurity, 0) then
   begin    
     FillChar(suiStartup, SizeOf(TStartupInfo), #0);
     suiStartup.cb := SizeOf(TStartupInfo);
     suiStartup.hStdInput := hRead;
     suiStartup.hStdOutput := hWrite;
     suiStartup.hStdError := hWrite;
     suiStartup.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;    
     suiStartup.wShowWindow := SW_HIDE;
     if CreateProcess(nil, PChar(ACommand + ' ' + AParameters), @saSecurity,
       @saSecurity, True, NORMAL_PRIORITY_CLASS, nil, nil, suiStartup, piProcess)
       then
     begin
       repeat
         dRunning  := WaitForSingleObject(piProcess.hProcess, 100);        
         Application.ProcessMessages(); 
         repeat
           dRead := 0;
           ReadFile(hRead, pBuffer[0], CReadBuffer, dRead, nil);          
           pBuffer[dRead] := #0;
           OemToAnsi(pBuffer, pBuffer);
           AMemo.Lines.Add(String(pBuffer));
         until (dRead < CReadBuffer);      
       until (dRunning <> WAIT_TIMEOUT);
       CloseHandle(piProcess.hProcess);
       CloseHandle(piProcess.hThread);    
     end;
     CloseHandle(hRead);
     CloseHandle(hWrite);
   end;
except
  Exit;
end;
end;

procedure TmyChatGPT.btn1Click(Sender: TObject);
begin
try
  Memo1.Clear;
  Memo2.Clear;
  if Length(Trim(ApiKey)) > 0 then PostParam('POST',url,'{"model": "text-davinci-003", "prompt": "Say this is a test", "temperature": 0, "max_tokens": 7}',ApiKey) else begin
     MessageBox(Handle,PChar('No token, please enter a token!'), PChar('Attention'), 64);
     btnToken.Click;
  end;
except
  Exit;
end;
end;

procedure TmyChatGPT.FormCreate(Sender: TObject);
begin
try
   Url := 'https://api.openai.com/v1/completions';
   if FileExists(FileName) then DeleteFile(FileName);
except
  Exit;
end;
end;

procedure TmyChatGPT.chksaveClick(Sender: TObject);
begin
  if chksave.Checked then begin
     lst2.Items.SaveToFile('Dialog.txt');
     mmo1.Lines.SaveToFile('Respons.txt');
     lst2.Items.Clear;
     mmo1.Lines.Clear;
     Sleep(500);
     stat1.SimpleText := 'Saved successfully';
  end else stat1.SimpleText := '';
end;

procedure TmyChatGPT.lst2Click(Sender: TObject);
begin
try
  Clipboard.AsText:=lst2.Items.Strings[lst2.ItemIndex]; Caption := 'Text copied to clipboard';
except
  Exit;
end;
end;

procedure TmyChatGPT.Memo1Change(Sender: TObject);
begin
  Caption := '';
end;

procedure TmyChatGPT.edt1KeyPress(Sender: TObject; var Key: Char);
var str,str0: string;  i : Integer; voice : OleVariant;
begin
if Key = #13 then
if Length(Trim(ApiKey)) > 0 then begin
try
    str:='';
    //str:=InputBox('Your question: ?','Hello','');
    str := edt1.Text; edt1.Clear;
    if Length(str) > 0 then begin
       Url := 'https://api.openai.com/v1/chat/completions';
       Memo1.Lines.Add(PostParam('POST',Url,'{  "model": "gpt-3.5-turbo",  "messages": [{"role": "user", "content": "'+str+'!"}]}',ApiKey));
       Memo2.Clear;        //Url := 'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=ru&hl=en-US&dt=t&dt=bd&dj=1&source=icon&tk=310461.310461&op=translate&q=';
       str := Trim(Memo1.Lines.Text);
       Memo2.Lines.Add(str);       //Memo2.Lines.Add(PostTranslate('POST',Url,''+Trim(str)+''));
     try
       CoInitialize(nil);
      try
      voice := CreateOleObject('SAPI.SpVoice');
      str0 := TranslateText(Trim(str),'en','ru');
      Memo2.Lines.Add(str0);
      lst2.Items.Add(Trim(str0));
      str0 := Trim(DetectLanguage(str));
      lng:=GetLanguagesForTranslate;
      lng:=GetLanguagesForSpeak; {}
      voice.speak(Trim(str));
      finally
        CoUninitialize;
      end;
     except
       on E:Exception do
          Writeln(E.Classname, ':', E.Message);
     end;
       lst2.Items.Add(Trim(Memo1.Lines.Text));
       Memo1.Clear;
    end;
except
  Exit;
end;
end else begin
  MessageBox(Handle,PChar('No token, please enter a token!'), PChar('Attention'), 64);
  btnToken.Click;
end;
end;

procedure TmyChatGPT.FormActivate(Sender: TObject);
begin
try
  edt1.SetFocus;
except
  Exit;
end;
end;

procedure TmyChatGPT.btnTokenClick(Sender: TObject);
begin
try
 try
  fSetting := TfSetting.Create(Self);
  fSetting.ShowModal;
  ApiKey := fSetting.uToken;
  temper := fSetting.temper;
  stat1.SimpleText := 'Token saved successfully';
 finally
  fSetting.Free;
 end;
except
  Exit;
end;
end;

end.
