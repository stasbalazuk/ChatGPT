program ChatGPT;

uses
  Forms,
  uChatGPT in 'uChatGPT.pas' {myChatGPT},
  uSetting in 'uSetting.pas' {fSetting};

{$R *.res}
{$R Manifest.res}

begin
  Application.Initialize;
  Application.CreateForm(TmyChatGPT, myChatGPT);
  Application.CreateForm(TfSetting, fSetting);
  Application.Run;
end.
