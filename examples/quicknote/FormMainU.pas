unit FormMainU;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  Menus,
  StdCtrls,
  ActnList,
  XPMan,
  ComCtrls;

type
  TFormMain = class(TForm)
    ActionList: TActionList;
    MainMenu: TMainMenu;
    ActionFileExit: TAction;
    MenuFile: TMenuItem;
    MenuExit: TMenuItem;
    XPManifest: TXPManifest;
    StatusBar: TStatusBar;
    Memo: TMemo;
    procedure ActionFileExitExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    dirtyFlag: Boolean;

  public

  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.ActionFileExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  dirtyFlag := False;
end;

end.
