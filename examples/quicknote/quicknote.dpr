program quicknote;

uses
  Forms,
  FormMainU in 'FormMainU.pas' {FormMain},
  FormAboutU in 'FormAboutU.pas' {FormAbout},
  FormSplashU in 'FormSplashU.pas' {FormSplash};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'QuickNote';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
