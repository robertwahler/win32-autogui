program quicknote;

uses
  Forms,
  FormMainU in 'FormMainU.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'QuickNote';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
