unit FormMainU;

interface

uses
  Classes,
  Controls,
  Forms,
  Menus,
  StdCtrls,
  ActnList,
  XPMan,
  ComCtrls,
  Dialogs;

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
    MenuHelp: TMenuItem;
    ActionHelpAbout: TAction;
    About1: TMenuItem;
    ActionFileNew: TAction;
    ActionFileSave: TAction;
    ActionFileOpen: TAction;
    New1: TMenuItem;
    N1: TMenuItem;
    ActionFileOpen1: TMenuItem;
    Save1: TMenuItem;
    FileOpenDialog: TOpenDialog;
    FileSaveDialog: TSaveDialog;

    procedure ActionFileExitExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ActionHelpAboutExecute(Sender: TObject);
    procedure MemoChange(Sender: TObject);
    procedure ActionFileNewExecute(Sender: TObject);
    procedure ActionFileOpenExecute(Sender: TObject);
    procedure ActionFileSaveExecute(Sender: TObject);

  private
    FDirtyFlag: Boolean;
    FFileName: String;

    function PromptAndSave: Integer;

    procedure SetDirty(Value: Boolean);
    procedure OpenTextFile(AFileName: String);
    procedure UpdateTitleBar;
    procedure Reset;

    property Dirty: Boolean read FDirtyFlag write SetDirty;
    property FileName: String read FFileName write FFilename;

  public

  end;

var
  FormMain: TFormMain;

implementation

uses
  FormAboutU;

{$R *.dfm}

procedure TFormMain.ActionFileExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FFileName := 'untitled.txt';
  FDirtyFlag := False;
  UpdateTitleBar;
end;

procedure TFormMain.SetDirty(Value: Boolean);
begin

  if Value <> FDirtyFlag then
  begin
    FdirtyFlag := Value;
    UpdateTitleBar;
  end;

end;

procedure TFormMain.UpdateTitleBar;
var
  fileFlags: String;
begin

  if Dirty then
    fileFlags := '+'
  else
    fileFlags := '';

  FormMain.Caption := 'QuickNote' + ' - ' + fileFlags + FileName;
end;

procedure TFormMain.ActionHelpAboutExecute(Sender: TObject);
var
  FormAbout: TFormAbout;
begin

  FormAbout := TFormAbout.Create(Application);
  try
    FormAbout.ShowModal
  finally
    FormAbout.Release;
  end;

end;

procedure TFormMain.MemoChange(Sender: TObject);
begin
  SetDirty(True);
end;

procedure TFormMain.Reset;
begin
  Memo.Text := '';
  SetDirty(False);
end;

procedure TFormMain.ActionFileNewExecute(Sender: TObject);
begin
  if PromptAndSave <> mrCancel then
  begin
    Reset;
  end;
end;

procedure TFormMain.ActionFileOpenExecute(Sender: TObject);
begin

  FileOpenDialog.Title := 'Text File Open';
  FileOpenDialog.Filter := 'Text Files (*.txt)|*.txt|All files (*.*)|*.*';
  FileOpenDialog.DefaultExt := '';
  FileOpenDialog.FileName := '';
  FileOpenDialog.Files.Clear;

  if PromptAndSave = mrCancel then exit;

  if FileOpenDialog.Execute then
  begin
    OpenTextFile(FileOpenDialog.FileName);
  end;

end;

procedure TFormMain.ActionFileSaveExecute(Sender: TObject);
begin
  //
end;

procedure TFormMain.OpenTextFile(AFileName: String);
begin
  //
end;

function TFormMain.PromptAndSave: Integer;
var
  msg: String;
begin

  // Default
  Result := mrYes;

  if Dirty then
  begin
    msg := 'Text has changed. Save changes to ' + FileName +'?';
    Result := MessageDlg(msg, mtConfirmation, mbYesNoCancel, 0);
    if Result = mrYes then
    begin
      ActionFileSaveExecute(self);
    end;
  end;

end;


end.
