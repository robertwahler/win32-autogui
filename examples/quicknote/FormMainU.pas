unit FormMainU;

interface

uses
  Windows,
  Classes,
  Controls,
  Forms,
  Menus,
  StdCtrls,
  ActnList,
  XPMan,
  ComCtrls,
  StrUtils,
  Dialogs;

type
  TFormMain = class(TForm)
    XPManifest: TXPManifest;
    StatusBar: TStatusBar;
    Memo: TMemo;

    FileOpenDialog: TOpenDialog;
    FileSaveDialog: TSaveDialog;

    ActionList: TActionList;
    ActionFileExit: TAction;
    ActionHelpAbout: TAction;
    ActionFileNew: TAction;
    ActionFileSave: TAction;
    ActionFileOpen: TAction;
    ActionFileSaveAs: TAction;

    MainMenu: TMainMenu;
    MenuFile: TMenuItem;
    MenuFileSaveAs: TMenuItem;
    MenuFileNew: TMenuItem;
    MenuFileOpen: TMenuItem;
    MenuFileSave: TMenuItem;
    MenuHelp: TMenuItem;
    MenuFileDividerAfterSaveAs: TMenuItem;
    MenuExit: TMenuItem;
    MenuHelpAbout: TMenuItem;

    procedure ActionFileExitExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ActionHelpAboutExecute(Sender: TObject);
    procedure MemoChange(Sender: TObject);
    procedure ActionFileNewExecute(Sender: TObject);
    procedure ActionFileOpenExecute(Sender: TObject);
    procedure ActionFileSaveExecute(Sender: TObject);
    procedure ActionFileSaveUpdate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ActionFileSaveAsExecute(Sender: TObject);

  private
    FDirtyFlag: Boolean;
    FFileName: String;

    function PromptAndSave: Integer;

    procedure SetDirty(Value: Boolean);
    procedure LoadTextFile(AFileName: String);
    procedure SaveTextFile(AFileName: String);
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
  FormAboutU,
  FormSplashU;

{$R *.dfm}

procedure TFormMain.ActionFileExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  SplashForm: TFormSplash;
  i: integer;
  splash: Boolean;
begin
  // defaults
  splash := true;

  // parse commandline
  if ParamCount >= 1 then
  begin
    for i := 1 to ParamCount do
    begin
      if AnsiStartsText('--NOSPLASH', ParamStr(i)) then
      begin
        splash := false;
      end;
    end;
  end;

  if splash then
  begin
    SplashForm := TFormSplash.Create(Application);
    try
      SplashForm.Show;
      // Simulate app creation work load
      for i:= 1 to 200 do
      begin
        Application.ProcessMessages;
        Sleep(10);
      end;
    finally
      // Enable a timer that will shutdown and release Splash
      // form after a short wait
      SplashForm.Timer.Enabled := True;
    end;
  end;  

  Reset;
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
  Dirty := True;
end;

procedure TFormMain.Reset;
begin
  Memo.Clear;
  FileName := 'untitled.txt';
  Dirty := False;
  UpdateTitleBar;
end;

procedure TFormMain.ActionFileNewExecute(Sender: TObject);
begin
  if PromptAndSave <> mrCancel then
  begin
    Reset;
  end;
end;

procedure TFormMain.ActionFileSaveAsExecute(Sender: TObject);
begin
  FileSaveDialog.Title := 'Text File Save';
  FileSaveDialog.Filter := 'Text Files (*.txt)|*.txt|All files (*.*)|*.*';

  if FileSaveDialog.Execute then
  begin
    SaveTextFile(FileSaveDialog.FileName);
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
    LoadTextFile(FileOpenDialog.FileName);
  end;
end;

procedure TFormMain.ActionFileSaveExecute(Sender: TObject);
begin
  SaveTextFile(FileName);
end;

procedure TFormMain.LoadTextFile(AFileName: String);
begin
  FileName := AFileName;
  Memo.Lines.LoadFromFile(FileName);
  Dirty := False;
  UpdateTitleBar;
end;

procedure TFormMain.SaveTextFile(AFileName: String);
begin
  FileName := AFileName;
  Memo.Lines.SaveToFile(FileName);
  Dirty := False;
  UpdateTitleBar;
end;

function TFormMain.PromptAndSave: Integer;
var
  Msg: String;
begin
  // Default
  Result := mrYes;

  if Dirty then
  begin
    Msg := 'Text has changed. Save changes to ' + FileName +'?';
    Result := MessageDlg(msg, mtConfirmation, mbYesNoCancel, 0);
    if Result = mrYes then
    begin
      ActionFileSaveExecute(self);
    end;
  end;
end;

procedure TFormMain.ActionFileSaveUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Dirty;
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  // Prompt user to save changes
  if PromptAndSave = mrCancel then
  begin
    CanClose := False;
  end;
end;

end.
