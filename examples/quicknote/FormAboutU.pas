unit FormAboutU;

interface

uses
  Classes,
  Controls,
  Forms,
  StdCtrls;

type
  TFormAbout = class(TForm)
    LabelAbout: TLabel;
    ButtonOk: TButton;
    LabelCopyright: TLabel;
    procedure ButtonOkClick(Sender: TObject);

  private

  public

  end;

var
  FormAbout: TFormAbout;

implementation

{$R *.dfm}

procedure TFormAbout.ButtonOkClick(Sender: TObject);
begin
  Close;
end;

end.
