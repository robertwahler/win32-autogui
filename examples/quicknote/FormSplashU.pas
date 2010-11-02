unit FormSplashU;

interface

uses
  Classes,
  Controls,
  Forms,
  StdCtrls,
  ExtCtrls;

type
  TFormSplash = class(TForm)
    Timer: TTimer;
    LabelLoading: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure TimerTimer(Sender: TObject);

  private

  public

  end;

var
  FormSplash: TFormSplash;

implementation

{$R *.dfm}

procedure TFormSplash.FormCreate(Sender: TObject);
begin
  BorderIcons := [];
  BorderStyle := bsNone;
  BorderWidth := 1;
  FormStyle := fsStayOnTop;

  Position := poOwnerFormCenter;

  Timer.Enabled := False;
  Timer.Interval := 750;
end;

procedure TFormSplash.TimerTimer(Sender: TObject);
begin
  Close;
  Release;
end;

end.
