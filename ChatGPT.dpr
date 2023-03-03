program ChatGPT;

uses
  Forms,
  only_one,
  uChatGPT in 'uChatGPT.pas' {myChatGPT},
  uSetting in 'uSetting.pas' {fSetting};

{$R *.res}
{$R Manifest.res}

const
  UniqueString = '#StalkerSTSChatGPT#';

begin
try
  if not init_mutex(UniqueString) then {Если я уже работаю}
  begin
       Exit;
       halt; {Остановить этот экземпляр}
  end;
  Application.Initialize;
  Application.CreateForm(TmyChatGPT, myChatGPT);
  Application.CreateForm(TfSetting, fSetting);
  Application.Run;
except
  Exit;
end;
end.
